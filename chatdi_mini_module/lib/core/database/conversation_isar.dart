import 'package:isar_community/isar.dart';

import '../../data/models/chat_message_enums.dart';
import 'conversation_entities.dart';

part 'conversation_isar.g.dart';

@embedded
class ChatMessageEmbedded {
  late String id;
  late String conversationId;
  late String message;
  late String role;
  late bool isFromBot;
  late String type;
  String? imageUrl;
  String? imageRemoteSource;
  late DateTime createdAt;
  late DateTime updatedAt;
}

@collection
class ConversationIsar {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  String? title;
  String? topic;
  String? characterId;
  String? characterName;
  List<ChatMessageEmbedded> messages = [];
  int messageCount = 0;
  late DateTime createdAt;
  late DateTime updatedAt;
}

@collection
class ChatMessageIsar {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  @Index()
  late String conversationId;

  late String message;
  late String role;
  late bool isFromBot;
  late String type;
  String? imageUrl;
  String? imageRemoteSource;
  late DateTime createdAt;
  late DateTime updatedAt;
}

ChatMessageEmbedded chatMessageToEmbedded(ChatMessageEntity entity) {
  return ChatMessageEmbedded()
    ..id = entity.id
    ..conversationId = entity.conversationId
    ..message = entity.message
    ..role = entity.role.wireValue
    ..isFromBot = entity.isFromBot
    ..type = entity.type.wireValue
    ..imageUrl = entity.imageUrl
    ..imageRemoteSource = entity.imageRemoteSource
    ..createdAt = entity.createdAt
    ..updatedAt = entity.updatedAt;
}

ChatMessageEntity chatMessageFromEmbedded(ChatMessageEmbedded embedded) {
  return ChatMessageEntity(
    id: embedded.id,
    conversationId: embedded.conversationId,
    message: embedded.message,
    role: ChatMessageRole.fromWire(embedded.role),
    isFromBot: embedded.isFromBot,
    type: ChatMessageContentType.fromWire(embedded.type),
    imageUrl: embedded.imageUrl,
    imageRemoteSource: embedded.imageRemoteSource,
    createdAt: embedded.createdAt,
    updatedAt: embedded.updatedAt,
  );
}

ConversationIsar conversationToIsar(ConversationEntity entity) {
  return ConversationIsar()
    ..id = entity.id
    ..title = entity.title
    ..topic = entity.topic
    ..characterId = entity.characterId
    ..characterName = entity.characterName
    ..messages = entity.messages.map(chatMessageToEmbedded).toList()
    ..messageCount = entity.messageCount
    ..createdAt = entity.createdAt
    ..updatedAt = entity.updatedAt;
}

ConversationEntity conversationFromIsar(ConversationIsar row) {
  return ConversationEntity(
    id: row.id,
    title: row.title,
    topic: row.topic,
    characterId: row.characterId,
    characterName: row.characterName,
    messages: row.messages.map(chatMessageFromEmbedded).toList(),
    messageCount: row.messageCount,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}

ChatMessageIsar chatMessageToIsar(ChatMessageEntity entity) {
  return ChatMessageIsar()
    ..id = entity.id
    ..conversationId = entity.conversationId
    ..message = entity.message
    ..role = entity.role.wireValue
    ..isFromBot = entity.isFromBot
    ..type = entity.type.wireValue
    ..imageUrl = entity.imageUrl
    ..imageRemoteSource = entity.imageRemoteSource
    ..createdAt = entity.createdAt
    ..updatedAt = entity.updatedAt;
}

ChatMessageEntity chatMessageFromIsar(ChatMessageIsar row) {
  return ChatMessageEntity(
    id: row.id,
    conversationId: row.conversationId,
    message: row.message,
    role: ChatMessageRole.fromWire(row.role),
    isFromBot: row.isFromBot,
    type: ChatMessageContentType.fromWire(row.type),
    imageUrl: row.imageUrl,
    imageRemoteSource: row.imageRemoteSource,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}
