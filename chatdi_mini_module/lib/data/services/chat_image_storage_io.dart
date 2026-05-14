import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ChatImageStorage {
  ChatImageStorage({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<String?> saveSsePayload(String payload, {required String messageId}) async {
    final raw = payload.trim();
    if (raw.isEmpty) return null;

    final root = await getApplicationDocumentsDirectory();
    final dirPath = p.join(root.path, 'chat_images');
    await Directory(dirPath).create(recursive: true);

    final ext = _guessExtension(raw);
    final name = '${messageId}_${DateTime.now().millisecondsSinceEpoch}$ext';
    final outPath = p.join(dirPath, name);

    try {
      if (raw.startsWith('http://') || raw.startsWith('https://')) {
        final res = await _client.get(Uri.parse(raw));
        if (res.statusCode < 200 || res.statusCode >= 300) return null;
        await File(outPath).writeAsBytes(res.bodyBytes);
        return outPath;
      }

      final bytes = _decodeBase64Image(raw);
      if (bytes != null) {
        await File(outPath).writeAsBytes(bytes);
        return outPath;
      }
    } catch (e, st) {
      debugPrint('[ChatImageStorage] save failed: $e $st');
    }
    return null;
  }

  Uint8List? _decodeBase64Image(String raw) {
    try {
      var payload = raw;
      if (raw.startsWith('data:image')) {
        final comma = raw.indexOf(',');
        if (comma < 0) return null;
        payload = raw.substring(comma + 1);
      }
      return Uint8List.fromList(base64Decode(payload.replaceAll(RegExp(r'\s'), '')));
    } catch (_) {
      return null;
    }
  }

  String _guessExtension(String raw) {
    if (raw.startsWith('data:image/png')) return '.png';
    if (raw.startsWith('data:image/webp')) return '.webp';
    if (raw.contains('image/png')) return '.png';
    if (raw.contains('image/jpeg') || raw.contains('image/jpg')) return '.jpg';
    return '.jpg';
  }

  bool isProbablyLocalSavedPath(String raw) {
    final p = raw.trim();
    if (p.isEmpty || p.startsWith('http://') || p.startsWith('https://') || p.startsWith('data:')) {
      return false;
    }
    try {
      return File(p).existsSync();
    } catch (_) {
      return false;
    }
  }
}
