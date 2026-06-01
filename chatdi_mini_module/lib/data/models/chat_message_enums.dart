/// Wire values for REST `conversation[].role` and local Isar `role`.
enum ChatMessageRole {
  user,
  assistant;

  String get wireValue => name;

  static ChatMessageRole fromWire(String? raw) {
    final s = (raw ?? '').trim();
    return ChatMessageRole.values.firstWhere(
      (e) => e.wireValue == s,
      orElse: () => ChatMessageRole.user,
    );
  }

  bool get isUser => this == ChatMessageRole.user;
}

/// Content shape stored in local DB (`ChatMessageEntity.type`).
enum ChatMessageContentType {
  text,
  image;

  String get wireValue => name;

  static ChatMessageContentType fromWire(String? raw) {
    final s = (raw ?? '').trim();
    return ChatMessageContentType.values.firstWhere(
      (e) => e.wireValue == s,
      orElse: () => ChatMessageContentType.text,
    );
  }
}

/// SSE payload `type` field (see docs/04-sse.md).
enum SseEventType {
  start,
  delta,
  deltaTextToImage,
  stop,
  errorReset,
  unknown;

  String get wireValue => switch (this) {
        SseEventType.start => 'start',
        SseEventType.delta => 'delta',
        SseEventType.deltaTextToImage => 'delta-text-to-image',
        SseEventType.stop => 'stop',
        SseEventType.errorReset => 'error-reset',
        SseEventType.unknown => '',
      };

  static SseEventType fromWire(String? raw) {
    final s = (raw ?? '').trim();
    if (s.isEmpty) return SseEventType.unknown;
    return switch (s) {
      'start' => SseEventType.start,
      'delta' => SseEventType.delta,
      'delta-text-to-image' => SseEventType.deltaTextToImage,
      'stop' => SseEventType.stop,
      'error-reset' => SseEventType.errorReset,
      _ => SseEventType.unknown,
    };
  }

  static SseEventType fromPayload(Map<String, dynamic> data) =>
      fromWire(data['type']?.toString());
}
