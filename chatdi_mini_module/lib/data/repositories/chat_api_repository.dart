import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../models/api_message_turn.dart';

enum SendMessageVariant { ask, textToImage, character }

/// REST layer for `/message*` (docs/03-api-by-screen.md).
class ChatApiRepository {
  ChatApiRepository(this._api);

  final ApiClient _api;

  Future<void> stopGeneration({
    required String sessionId,
    required String messageId,
  }) async {
    await _api.postJson(
      ApiConstants.messageStop,
      {'message_id': messageId},
      sessionId: sessionId,
    );
  }

  Future<dynamic> send({
    required SendMessageVariant variant,
    required String sessionId,
    String? chatId,
    required List<ApiMessageTurn> conversation,
    required String content,
    String topics = '',
    String? style,
    String? characterId,
  }) async {
    final convJson = conversation.map((e) => e.toJson()).toList();
    Map<String, dynamic> body = {
      'conversation': convJson,
      'content': content,
    };

    switch (variant) {
      case SendMessageVariant.ask:
        body = {
          ...body,
          if (chatId != null && chatId.isNotEmpty) 'chat_id': chatId,
          'topics': topics,
        };
        break;
      case SendMessageVariant.textToImage:
        body = {
          ...body,
          if (chatId != null && chatId.isNotEmpty) 'chat_id': chatId,
          if (style != null && style.isNotEmpty) 'style': style,
        };
        break;
      case SendMessageVariant.character:
        body = {
          ...body,
          'character_id': characterId!,
        };
        break;
    }

    final path = variant == SendMessageVariant.textToImage
        ? ApiConstants.messageTextToImage
        : variant == SendMessageVariant.character
            ? ApiConstants.messageCharacter
            : ApiConstants.message;

    return _api.postJson(path, body, sessionId: sessionId);
  }
}
