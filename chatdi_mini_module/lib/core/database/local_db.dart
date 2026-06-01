import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'conversation_isar.dart';

const _dbName = 'chatdi_local';

Isar? _isar;

Future<void> initLocalDb() async {
  if (_isar?.isOpen == true) return;

  final dir = await getApplicationDocumentsDirectory();
  _isar = await Isar.open(
    [ConversationIsarSchema, ChatMessageIsarSchema],
    directory: dir.path,
    name: _dbName,
  );
}

Isar get isar {
  final db = _isar;
  if (db == null || !db.isOpen) {
    throw StateError('Local DB not initialized. Call initLocalDb() first.');
  }
  return db;
}
