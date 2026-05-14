import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'conversation_entities.dart';

const _conversationsBox = 'conversations';
const _messagesBox = 'messages';

const _messagesSchemaKey = 'hive_chat_messages_schema_v2';

Future<void> initLocalDb() async {
  await Hive.initFlutter();

  final prefs = await SharedPreferences.getInstance();
  final schema = prefs.getInt(_messagesSchemaKey) ?? 1;
  if (schema < 2) {
    try {
      if (Hive.isBoxOpen(_messagesBox)) {
        await Hive.box<dynamic>(_messagesBox).close();
      }
    } catch (_) {}
    try {
      await Hive.deleteBoxFromDisk(_messagesBox);
    } catch (_) {}
    await prefs.setInt(_messagesSchemaKey, 2);
  }

  if (!Hive.isAdapterRegistered(11)) Hive.registerAdapter(ConversationAdapter());
  if (!Hive.isAdapterRegistered(12)) Hive.registerAdapter(ChatMessageAdapter());
  await Hive.openBox<ConversationEntity>(_conversationsBox);
  await Hive.openBox<ChatMessageEntity>(_messagesBox);
}

Box<ConversationEntity> conversationsBox() =>
    Hive.box<ConversationEntity>(_conversationsBox);

Box<ChatMessageEntity> messagesBox() => Hive.box<ChatMessageEntity>(_messagesBox);
