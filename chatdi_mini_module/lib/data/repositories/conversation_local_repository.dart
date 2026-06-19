import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/conversation_entities.dart';
import '../../core/database/conversation_isar.dart';
import '../../core/database/local_db.dart';
import '../models/chat_message_enums.dart';
import '../models/ui_chat_message.dart';

/// Paged UI messages result used by [ConversationLocalRepository].
class UiMessagesPage {
  final List<UiChatMessage> items;
  final bool hasMore;
  UiMessagesPage({required this.items, required this.hasMore});
}

class ConversationLocalRepository {
  Isar get _db => isar;

  List<ConversationEntity> listSorted() {
    final list = _db.conversationIsars.where().findAllSync().map(conversationFromIsar).toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
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
    await _db.writeTxn(() async {
      await _db.conversationIsars.put(conversationToIsar(e));
    });
  }

  ConversationEntity? getConversation(String id) {
    final row = _db.conversationIsars.getByIdSync(id);
    return row == null ? null : conversationFromIsar(row);
  }

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

    final existing = getConversation(conversationId);
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

    await _db.writeTxn(() async {
      await _db.chatMessageIsars.put(chatMessageToIsar(entity));
      await _db.conversationIsars.put(conversationToIsar(updated));
    });
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
    final prevRow = _db.chatMessageIsars.getByIdSync(messageId);
    final prev = prevRow == null ? null : chatMessageFromIsar(prevRow);
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

    final conv = getConversation(conversationId);
    if (conv == null) {
      await _db.writeTxn(() async {
        await _db.chatMessageIsars.put(chatMessageToIsar(next));
      });
      return;
    }

    final mergedMessages = [...conv.messages];
    final existingMessageIdx = mergedMessages.indexWhere((m) => m.id == messageId);
    if (existingMessageIdx >= 0) {
      mergedMessages[existingMessageIdx] = next;
    } else {
      mergedMessages.add(next);
    }

    final updatedConv = ConversationEntity(
      id: conv.id,
      title: conv.title,
      topic: conv.topic,
      characterId: conv.characterId,
      characterName: conv.characterName,
      messages: mergedMessages,
      messageCount: mergedMessages.length,
      createdAt: conv.createdAt,
      updatedAt: now,
    );

    await _db.writeTxn(() async {
      await _db.chatMessageIsars.put(chatMessageToIsar(next));
      await _db.conversationIsars.put(conversationToIsar(updatedConv));
    });
  }

  List<UiChatMessage> uiMessages(String conversationId) {
    final conv = getConversation(conversationId);
    final rows = conv?.messages.toList() ??
        _db.chatMessageIsars
            .where()
            .conversationIdEqualTo(conversationId)
            .findAllSync()
            .map(chatMessageFromIsar)
            .toList();
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

  /// Returns a page of UI messages for [conversationId].
  ///
  /// - `pageSize` defaults to 20.
  /// - If `before` is null, returns the most recent `pageSize` messages.
  /// - If `before` is provided, returns up to `pageSize` messages older than `before`.
  UiMessagesPage uiMessagesPage(
    String conversationId, {
    int pageSize = 20,
    DateTime? before,
  }) {
    final conv = getConversation(conversationId);
    final rows = conv?.messages.toList() ??
        _db.chatMessageIsars
            .where()
            .conversationIdEqualTo(conversationId)
            .findAllSync()
            .map(chatMessageFromIsar)
            .toList();

    // Ensure chronological order (oldest -> newest)
    rows.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Filter by `before` if provided
    final filtered = (before == null)
        ? rows
        : rows.where((r) => r.createdAt.isBefore(before)).toList();

    final total = filtered.length;
    if (total == 0) {
      return UiMessagesPage(items: [], hasMore: rows.isNotEmpty);
    }

    // Take the last `pageSize` items from filtered (the newest in that window)
    final start = total <= pageSize ? 0 : total - pageSize;
    final pageItems = filtered.sublist(start, total);

    final hasMore = start > 0;

    final ui = pageItems
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

    return UiMessagesPage(items: ui, hasMore: hasMore);
  }

  String lastMessagePreview(ConversationEntity conversation) {
    if (conversation.messages.isEmpty) return 'No message';
    final userMessages = conversation.messages.where((m) => !m.isFromBot).toList();
    final row = userMessages.last;
    if (row.type == ChatMessageContentType.image && row.message.trim().isEmpty) {
      return '[Image]';
    }
    final text = row.message.trim();
    return text.isEmpty ? 'No message' : text;
  }

  Future<void> deleteConversation(String conversationId) async {
    await _db.writeTxn(() async {
      await _db.chatMessageIsars
          .where()
          .conversationIdEqualTo(conversationId)
          .deleteAll();
      await _db.conversationIsars.deleteById(conversationId);
    });
  }

  Future<void> clearAll() async {
    await _db.writeTxn(() async {
      await _db.chatMessageIsars.clear();
      await _db.conversationIsars.clear();
    });
  }

  String _trimTitle(String text) {
    final t = text.trim();
    if (t.isEmpty) return 'Chat';
    if (t.length <= 48) return t;
    return t.substring(0, 48);
  }
}
