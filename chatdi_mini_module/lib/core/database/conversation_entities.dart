import '../../data/models/chat_message_enums.dart';

/// Local conversation row (see docs/05-models Realm section).
class ConversationEntity {
  ConversationEntity({
    required this.id,
    this.title,
    this.topic,
    this.characterId,
    this.characterName,
    List<ChatMessageEntity>? messages,
    this.messageCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : messages = List.unmodifiable(messages ?? const <ChatMessageEntity>[]),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String? title;
  final String? topic;
  final String? characterId;
  final String? characterName;
  final List<ChatMessageEntity> messages;
  final int messageCount;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class ChatMessageEntity {
  ChatMessageEntity({
    required this.id,
    required this.conversationId,
    required this.message,
    required this.role,
    required this.isFromBot,
    this.type = ChatMessageContentType.text,
    this.imageUrl,
    this.imageRemoteSource,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String conversationId;
  final String message;
  final ChatMessageRole role;
  final bool isFromBot;
  final ChatMessageContentType type;
  /// Đường dẫn file cục bộ (ưu tiên hiển thị) hoặc URL tạm nếu chưa tải xong.
  final String? imageUrl;
  /// Payload gốc từ SSE (URL / data-uri / base64) để gửi lại API khi cần.
  final String? imageRemoteSource;
  final DateTime createdAt;
  final DateTime updatedAt;
}
