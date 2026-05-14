/// One turn in REST `conversation` payloads (docs/05-models-and-types.md).
class ApiMessageTurn {
  ApiMessageTurn({required this.content, required this.role});

  factory ApiMessageTurn.fromJson(Map<String, dynamic> json) => ApiMessageTurn(
        content: '${json['content'] ?? ''}',
        role: '${json['role'] ?? 'user'}',
      );

  final String content;
  /// `user` or `assistant`
  final String role;

  Map<String, dynamic> toJson() => {'content': content, 'role': role};
}
