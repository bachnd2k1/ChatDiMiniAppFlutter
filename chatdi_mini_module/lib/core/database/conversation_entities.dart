import 'package:hive/hive.dart';

/// Local conversation row (see docs/05-models Realm section).
class ConversationEntity {
  ConversationEntity({
    required this.id,
    this.title,
    this.topic,
    this.characterId,
    this.characterName,
    this.lastMessage,
    DateTime? lastMessageTime,
    this.messageCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : lastMessageTime = lastMessageTime ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String? title;
  final String? topic;
  final String? characterId;
  final String? characterName;
  final String? lastMessage;
  final DateTime? lastMessageTime;
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
    this.type = 'text',
    this.imageUrl,
    this.imageRemoteSource,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String conversationId;
  final String message;
  final String role;
  final String type;
  /// Đường dẫn file cục bộ (ưu tiên hiển thị) hoặc URL tạm nếu chưa tải xong.
  final String? imageUrl;
  /// Payload gốc từ SSE (URL / data-uri / base64) để gửi lại API khi cần.
  final String? imageRemoteSource;
  final DateTime createdAt;
  final DateTime updatedAt;
}

String? _readOptStr(BinaryReader r) => r.readBool() ? r.readString() : null;

void _writeOptStr(BinaryWriter w, String? v) {
  w.writeBool(v != null);
  if (v != null) w.writeString(v);
}

DateTime? _readOptDt(BinaryReader r) =>
    r.readBool() ? DateTime.fromMillisecondsSinceEpoch(r.readInt()) : null;

void _writeOptDt(BinaryWriter w, DateTime? v) {
  w.writeBool(v != null);
  if (v != null) w.writeInt(v.millisecondsSinceEpoch);
}

class ConversationAdapter extends TypeAdapter<ConversationEntity> {
  @override
  final int typeId = 11;

  @override
  ConversationEntity read(BinaryReader reader) {
    return ConversationEntity(
      id: reader.readString(),
      title: _readOptStr(reader),
      topic: _readOptStr(reader),
      characterId: _readOptStr(reader),
      characterName: _readOptStr(reader),
      lastMessage: _readOptStr(reader),
      lastMessageTime: _readOptDt(reader),
      messageCount: reader.readInt(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, ConversationEntity obj) {
    writer.writeString(obj.id);
    _writeOptStr(writer, obj.title);
    _writeOptStr(writer, obj.topic);
    _writeOptStr(writer, obj.characterId);
    _writeOptStr(writer, obj.characterName);
    _writeOptStr(writer, obj.lastMessage);
    _writeOptDt(writer, obj.lastMessageTime);
    writer.writeInt(obj.messageCount);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeInt(obj.updatedAt.millisecondsSinceEpoch);
  }
}

class ChatMessageAdapter extends TypeAdapter<ChatMessageEntity> {
  @override
  final int typeId = 12;

  @override
  ChatMessageEntity read(BinaryReader reader) {
    return ChatMessageEntity(
      id: reader.readString(),
      conversationId: reader.readString(),
      message: reader.readString(),
      role: reader.readString(),
      type: reader.readString(),
      imageUrl: _readOptStr(reader),
      imageRemoteSource: _readOptStr(reader),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessageEntity obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.conversationId);
    writer.writeString(obj.message);
    writer.writeString(obj.role);
    writer.writeString(obj.type);
    _writeOptStr(writer, obj.imageUrl);
    _writeOptStr(writer, obj.imageRemoteSource);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeInt(obj.updatedAt.millisecondsSinceEpoch);
  }
}
