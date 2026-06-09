import 'dart:async';

import 'package:flutter/foundation.dart' hide Category;
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

import '../data/models/api_message_turn.dart';
import '../data/models/chat_message_enums.dart';
import '../data/models/category.dart';
import '../data/models/character.dart';
import '../data/models/image_style.dart';
import '../data/models/ui_chat_message.dart';
import '../data/repositories/catalog_repository.dart';
import '../data/repositories/chat_api_repository.dart';
import '../data/repositories/conversation_local_repository.dart';
import '../data/services/chat_image_storage.dart';
import 'chat_launch_args.dart';
import 'session_provider.dart';

/// Chat orchestration aligned with docs/03 + docs/04.
class ChatProvider extends ChangeNotifier {
  ChatProvider(
    this._chatApi,
    this._local,
    this._catalog,
    ChatImageStorage imageStorage,
  ) : _imageStorage = imageStorage;

  final ChatApiRepository _chatApi;
  final ConversationLocalRepository _local;
  final CatalogRepository _catalog;
  final ChatImageStorage _imageStorage;

  SessionProvider? _session;
  ChatLaunchArgs? args;
  late String conversationId;

  Category? topicCategory;
  CharacterModel? character;
  bool isImageTab = false;

  List<UiChatMessage> persisted = [];
  List<ImageStyle> imageStyles = [];

  UiChatMessage? streamingBubble;

  ImageStyle? selectedStyle;
  bool isSending = false;

  final ImagePicker _picker = ImagePicker();

  XFile? selectedImage;

  Future<void> mount(ChatLaunchArgs launch, SessionProvider session) async {
    args = launch;
    _session = session;
    topicCategory = launch.topicCategory ?? launch.effectiveCategory;
    character = launch.character;
    isImageTab = launch.tabIndex == 1;
    conversationId = launch.conversationId ?? const Uuid().v4();
    persisted = _local.uiMessages(conversationId);

    session.ssePayloadListener = _onServerEvent;
    await session.startChatLifecycle();

    await _catalog.getImageStyles().then((v) {
      imageStyles = v;
      notifyListeners();
    }).catchError((_) {});

    notifyListeners();
  }

  Future<void> unmount() async {
    _session?.ssePayloadListener = null;
    await _session?.stopChatLifecycle();
    _session = null;
  }

  bool get isSendEnabled =>
      (_session?.canSendMessages ?? false) &&
      !isSending &&
      streamingBubble == null;

  bool get canStopStream =>
      _session?.sessionId?.isNotEmpty == true &&
      streamingBubble?.id.isNotEmpty == true;

  List<UiChatMessage> get visibleMessages =>
      [...persisted, if (streamingBubble != null) streamingBubble!];

  void setTabAsk() {
    isImageTab = false;
    notifyListeners();
  }

  void setTabImage() {
    isImageTab = true;
    notifyListeners();
  }

  void selectStyle(ImageStyle? style) {
    selectedStyle = style;
    notifyListeners();
  }

  Future<void> sendUserMessage(String trimmed) async {
    final session = _session;
    if (session == null || !session.canSendMessages) return;

    await _local.appendUserMessage(
      conversationId: conversationId,
      text: trimmed,
      titleHint: character?.name ?? topicCategory?.name ?? args?.overrideTitle,
      topicId: topicCategory?.id,
      characterId: character?.id,
      characterName: character?.name,
    );

    persisted = _local.uiMessages(conversationId);
    notifyListeners();

    final variant = _pickVariant();

    try {
      isSending = true;
      notifyListeners();
      await _chatApi.send(
        variant: variant,
        sessionId: session.sessionId!,
        chatId: variant == SendMessageVariant.character ? null : conversationId,
        conversation: _buildConversationPayload(),
        content: trimmed,
        topics: topicCategory?.id ?? '',
        style: variant == SendMessageVariant.textToImage ? selectedStyle?.id : null,
        characterId: variant == SendMessageVariant.character ? character?.id : null,
      );
    } catch (e) {
      debugPrint('send failed: $e');
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  Future<void> stopGeneration() async {
    final session = _session;
    final sid = session?.sessionId;
    final mid = streamingBubble?.id;
    if (sid == null || sid.isEmpty || mid == null || mid.isEmpty) return;
    try {
      await _chatApi.stopGeneration(
        sessionId: sid,
        messageId: mid,
      );
    } catch (_) {}
  }

  SendMessageVariant _pickVariant() {
    if (character != null) return SendMessageVariant.character;
    if (isImageTab) return SendMessageVariant.textToImage;
    return SendMessageVariant.ask;
  }

  List<ApiMessageTurn> _buildConversationPayload() => persisted
      .map(
        (m) => ApiMessageTurn(
          content: _serializedModelContent(m),
          role: m.role,
        ),
      )
      .toList();

  String _serializedModelContent(UiChatMessage m) {
    if (m.isUser) return m.content;
    final remote = m.imageRemoteSource?.trim();
    if (remote != null && remote.isNotEmpty) return remote;
    final img = m.imageUrl?.trim();
    if (img != null &&
        img.isNotEmpty &&
        (img.startsWith('http://') ||
            img.startsWith('https://') ||
            img.startsWith('data:'))) {
      return img;
    }
    return m.content;
  }

  void _onServerEvent(Map<String, dynamic> data) {
    switch (SseEventType.fromPayload(data)) {
      case SseEventType.errorReset:
        return;
      case SseEventType.start:
        final sid = '${data['id'] ?? ''}'.trim();
        if (sid.isEmpty) break;
        streamingBubble = UiChatMessage(
          id: sid,
          content: '',
          role: ChatMessageRole.assistant,
        );
        notifyListeners();
        break;
      case SseEventType.delta:
        if (streamingBubble == null) break;
        final piece = '${data['content'] ?? ''}';
        streamingBubble = streamingBubble!.copyWith(
          content: streamingBubble!.content + piece,
        );
        notifyListeners();
        break;
      case SseEventType.deltaTextToImage:
        if (streamingBubble == null) break;
        final payload = '${data['content'] ?? ''}';
        streamingBubble = streamingBubble!.copyWith(
          imageUrl: payload,
          imageRemoteSource: payload,
        );
        notifyListeners();
        unawaited(_materializeStreamingImage(payload));
        break;
      case SseEventType.stop:
        unawaited(_finalizeAssistantMessage());
        break;
      case SseEventType.unknown:
        debugPrint('[chat] sse $data');
        break;
    }
  }

  Future<void> _materializeStreamingImage(String ssePayload) async {
    final mid = streamingBubble?.id;
    if (mid == null || mid.isEmpty) return;
    final path = await _imageStorage.saveSsePayload(ssePayload, messageId: mid);
    if (path == null || streamingBubble?.id != mid) return;
    final b = streamingBubble;
    if (b == null || b.id != mid) return;
    streamingBubble = b.copyWith(imageUrl: path);
    notifyListeners();
  }

  Future<void> _finalizeAssistantMessage() async {
    final bubble = streamingBubble;
    final mid = bubble?.id;
    if (bubble != null && mid != null && mid.isNotEmpty) {
      final remoteSeed = bubble.imageRemoteSource ?? bubble.imageUrl;
      final trimmedRemote = remoteSeed?.trim() ?? '';
      final hasImage = trimmedRemote.isNotEmpty;

      String pathOut = bubble.imageUrl?.trim() ?? trimmedRemote;

      if (hasImage && !_imageStorage.isProbablyLocalSavedPath(pathOut)) {
        final saved = await _imageStorage.saveSsePayload(pathOut, messageId: mid);
        if (saved != null) {
          pathOut = saved;
        }
      }

      var remoteStored = bubble.imageRemoteSource?.trim();
      if (hasImage && (remoteStored == null || remoteStored.isEmpty)) {
        final cand = bubble.imageUrl?.trim() ?? '';
        if (cand.startsWith('http://') ||
            cand.startsWith('https://') ||
            cand.startsWith('data:')) {
          remoteStored = cand;
        } else {
          remoteStored = trimmedRemote.isNotEmpty &&
                  (trimmedRemote.startsWith('http') || trimmedRemote.startsWith('data:'))
              ? trimmedRemote
              : null;
        }
      }

      await _local.upsertAssistantMessage(
        conversationId: conversationId,
        messageId: mid,
        role: bubble.role,
        text: bubble.content,
        type: hasImage ? ChatMessageContentType.image : ChatMessageContentType.text,
        imageUrl: hasImage ? pathOut : null,
        imageRemoteSource: hasImage ? remoteStored : null,
      );
    }

    streamingBubble = null;
    persisted = _local.uiMessages(conversationId);
    notifyListeners();
  }

  Future<void> pickImages() async {
    selectedImage = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    notifyListeners();
  }

  void clearImages() {
    selectedImage = null;
    notifyListeners();
  }
}
