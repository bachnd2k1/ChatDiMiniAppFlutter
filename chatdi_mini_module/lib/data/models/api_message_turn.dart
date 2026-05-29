import 'chat_message_enums.dart';

/// One turn in REST `conversation` payloads (docs/05-models-and-types.md).
class ApiMessageTurn {
  ApiMessageTurn({required this.content, required this.role});

  factory ApiMessageTurn.fromJson(Map<String, dynamic> json) => ApiMessageTurn(
        content: '${json['content'] ?? ''}',
        role: ChatMessageRole.fromWire('${json['role']}'),
      );

  final String content;
  final ChatMessageRole role;

  Map<String, dynamic> toJson() => {'content': content, 'role': role.wireValue};
}
