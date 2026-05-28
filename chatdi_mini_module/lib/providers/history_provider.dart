import 'package:flutter/foundation.dart';

import '../core/database/conversation_entities.dart';
import '../data/repositories/conversation_local_repository.dart';

class HistoryProvider extends ChangeNotifier {
  HistoryProvider(this._repository);

  final ConversationLocalRepository _repository;

  String _query = '';

  List<ConversationEntity> get items => _repository.search(_query);

  String lastMessagePreview(ConversationEntity entity) {
    return _repository.lastMessagePreview(entity);
  }

  void updateQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<void> deleteConversation(String conversationId) async {
    await _repository.deleteConversation(conversationId);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _repository.clearAll();
    notifyListeners();
  }
}
