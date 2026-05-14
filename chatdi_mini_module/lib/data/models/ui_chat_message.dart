import 'package:uuid/uuid.dart';

/// Bubble shown in chat UI.
class UiChatMessage {
  UiChatMessage({
    required this.id,
    required this.content,
    required this.role,
    this.imageUrl,
    this.imageRemoteSource,
    DateTime? createdAt,
    this.pending = false,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UiChatMessage.userText(String content) => UiChatMessage(
        id: const Uuid().v4(),
        content: content,
        role: 'user',
      );

  final String id;
  final String content;
  /// `user` | `assistant`
  final String role;
  /// Hiển thị: đường local sau khi tải, hoặc URL/data-uri tạm từ SSE.
  final String? imageUrl;
  /// SSE gốc (URL/base64…) — gửi lại API và lưu DB.
  final String? imageRemoteSource;
  final DateTime createdAt;

  /// True while optimistic / waiting for persistence
  final bool pending;

  bool get isUser => role == 'user';

  UiChatMessage copyWith({
    String? content,
    String? role,
    String? imageUrl,
    String? imageRemoteSource,
    bool? pending,
  }) =>
      UiChatMessage(
        id: id,
        content: content ?? this.content,
        role: role ?? this.role,
        imageUrl: imageUrl ?? this.imageUrl,
        imageRemoteSource: imageRemoteSource ?? this.imageRemoteSource,
        createdAt: createdAt,
        pending: pending ?? this.pending,
      );
}
