import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/conversation_entities.dart';
import '../../core/database/local_db.dart';
import '../models/chat_message_enums.dart';
import '../models/ui_chat_message.dart';

class ConversationLocalRepository {
  Box<ConversationEntity> get _c => conversationsBox();
  Box<ChatMessageEntity> get _m => messagesBox();

  List<ConversationEntity> listSorted() {
    final list = _c.values.toList();
    list.sort((a, b) => (b.updatedAt).compareTo(a.updatedAt));
    return list;
  }

  List<ConversationEntity> search(String q) {
    final qq = q.trim().toLowerCase();
    if (qq.isEmpty) return listSorted();
    return listSorted().where((c) {
      final inTitle = (c.title ?? '').toLowerCase().contains(qq);
      final inTopic = (c.topic ?? '').toLowerCase().contains(qq);
      final inCharName = (c.characterName ?? '').toLowerCase().contains(qq);
      final inLast = lastMessagePreview(c).toLowerCase().contains(qq);
      return inTitle || inTopic || inCharName || inLast;
    }).toList();
  }

  Future<void> upsertConversation(ConversationEntity e) async {
    await _c.put(e.id, e);
  }

  ConversationEntity? getConversation(String id) => _c.get(id);

  Future<String> appendUserMessage({
    required String conversationId,
    required String text,
    String? titleHint,
    String? topicId,
    String? characterId,
    String? characterName,
  }) async {
    const uuid = Uuid();
    final msgId = uuid.v4();
    final entity = ChatMessageEntity(
      id: msgId,
      conversationId: conversationId,
      message: text,
      role: ChatMessageRole.user,
      isFromBot: false,
      type: ChatMessageContentType.text,
    );
    await _m.put(entity.id, entity);

    final existing = _c.get(conversationId);
    final now = DateTime.now();
    final updated = ConversationEntity(
      id: conversationId,
      title: existing?.title ?? titleHint ?? _trimTitle(text),
      topic: existing?.topic ?? topicId,
      characterId: existing?.characterId ?? characterId,
      characterName: existing?.characterName ?? characterName,
      messages: [...?existing?.messages, entity],
      messageCount: (existing?.messages.length ?? 0) + 1,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    await _c.put(conversationId, updated);
    return msgId;
  }

  /// Persists streaming assistant replies; merges by [messageId] for deltas.
  Future<void> upsertAssistantMessage({
    required String conversationId,
    required String messageId,
    required ChatMessageRole role,
    String text = '',
    ChatMessageContentType type = ChatMessageContentType.text,
    String? imageUrl,
    String? imageRemoteSource,
  }) async {
    final now = DateTime.now();
    final prev = _m.get(messageId);
    final mergedText = prev == null
        ? text
        : ((prev.message + text).isEmpty ? prev.message : (prev.message + text));

    final mergedImage = imageUrl ?? prev?.imageUrl;
    final mergedRemote = imageRemoteSource ?? prev?.imageRemoteSource;
    final next = ChatMessageEntity(
      id: messageId,
      conversationId: conversationId,
      message: mergedText,
      role: role,
      isFromBot: true,
      type: prev?.type ?? type,
      imageUrl: mergedImage,
      imageRemoteSource: mergedRemote,
      createdAt: prev?.createdAt ?? now,
      updatedAt: now,
    );

    await _m.put(messageId, next);

    final conv = _c.get(conversationId);
    if (conv == null) return;

    final mergedMessages = [...conv.messages];
    final existingMessageIdx = mergedMessages.indexWhere((m) => m.id == messageId);
    if (existingMessageIdx >= 0) {
      mergedMessages[existingMessageIdx] = next;
    } else {
      mergedMessages.add(next);
    }

    await _c.put(
      conversationId,
      ConversationEntity(
        id: conv.id,
        title: conv.title,
        topic: conv.topic,
        characterId: conv.characterId,
        characterName: conv.characterName,
        messages: mergedMessages,
        messageCount: mergedMessages.length,
        createdAt: conv.createdAt,
        updatedAt: now,
      ),
    );
  }

  List<UiChatMessage> uiMessages(String conversationId) {
    final rows = _c.get(conversationId)?.messages.toList() ??
        _m.values.where((x) => x.conversationId == conversationId).toList();
    rows.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return rows
        .map(
          (e) => UiChatMessage(
            id: e.id,
            content: e.message,
            role: e.role,
            imageUrl: e.imageUrl,
            imageRemoteSource: e.imageRemoteSource,
            createdAt: e.createdAt,
          ),
        )
        .toList();
  }

  String lastMessagePreview(ConversationEntity conversation) {
    if (conversation.messages.isEmpty) return 'No message';
    final userMessages =
    conversation.messages.where((m) => !m.isFromBot).toList();
    final row = userMessages.last;
    if (row.type == ChatMessageContentType.image && row.message.trim().isEmpty) {
      return '[Image]';
    }
    final text = row.message.trim();
    return text.isEmpty ? 'No message' : text;
  }

  Future<void> deleteConversation(String conversationId) async {
    final ids =
        _m.values.where((msg) => msg.conversationId == conversationId).map((e) => e.id).toList();
    await _m.deleteAll(ids);
    await _c.delete(conversationId);
  }

  Future<void> clearAll() async {
    await _m.clear();
    await _c.clear();
  }

  String _trimTitle(String text) {
    final t = text.trim();
    if (t.isEmpty) return 'Chat';
    if (t.length <= 48) return t;
    return t.substring(0, 48);
  }
}
