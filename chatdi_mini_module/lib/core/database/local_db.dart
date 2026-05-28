import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'conversation_entities.dart';

const _conversationsBox = 'conversations';
const _messagesBox = 'messages';


Future<void> initLocalDb() async {
  await Hive.initFlutter();

  try {
    if (Hive.isBoxOpen(_conversationsBox)) {
      await Hive.box(_conversationsBox).close();
    }
    await Hive.deleteBoxFromDisk(_conversationsBox);
  } catch (_) {}

  try {
    if (Hive.isBoxOpen(_messagesBox)) {
      await Hive.box(_messagesBox).close();
    }
    await Hive.deleteBoxFromDisk(_messagesBox);
  } catch (_) {}

  if (!Hive.isAdapterRegistered(11)) Hive.registerAdapter(ConversationAdapter());
  if (!Hive.isAdapterRegistered(12)) Hive.registerAdapter(ChatMessageAdapter());
  await Hive.openBox<ConversationEntity>(_conversationsBox);
  await Hive.openBox<ChatMessageEntity>(_messagesBox);
}

Box<ConversationEntity> conversationsBox() =>
    Hive.box<ConversationEntity>(_conversationsBox);

Box<ChatMessageEntity> messagesBox() => Hive.box<ChatMessageEntity>(_messagesBox);
