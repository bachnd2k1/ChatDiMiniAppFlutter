import 'dart:async';
import 'dart:convert';

import 'api_client.dart';

typedef SseConnectionHandler = void Function(String sessionId);
typedef SseMessageHandler = void Function(Map<String, dynamic> data);
typedef SseErrorHandler = void Function(Object error, StackTrace st);

/// Parses Server-Sent Events from a byte stream (see docs/04-sse.md).
class SseService {
  SseService(this._client);

  final ApiClient _client;

  StreamSubscription<List<int>>? _sub;

  Future<void> start({
    required SseConnectionHandler onConnection,
    required SseMessageHandler onMessage,
    SseErrorHandler? onError,
  }) async {
    await stop();
    StreamedSSE sse;
    try {
      sse = await _client.openSse();
    } catch (e, st) {
      onError?.call(e, st);
      return;
    }
    var buffer = '';
    _sub = sse.stream.listen(
      (chunk) {
        buffer += utf8.decode(chunk, allowMalformed: true);
        while (true) {
          final crlf = buffer.indexOf('\r\n\r\n');
          final lf = buffer.indexOf('\n\n');
          final int delimStart;
          final int delimLen;
          if (crlf >= 0 && (lf < 0 || crlf <= lf)) {
            delimStart = crlf;
            delimLen = 4;
          } else if (lf >= 0) {
            delimStart = lf;
            delimLen = 2;
          } else {
            break;
          }
          final raw = buffer.substring(0, delimStart).trimRight();
          buffer = buffer.substring(delimStart + delimLen);
          _dispatchBlock(raw, onConnection, onMessage);
        }
      },
      onError: (e, st) => onError?.call(e, st),
      cancelOnError: false,
    );
  }

  void _dispatchBlock(
    String block,
    SseConnectionHandler onConnection,
    SseMessageHandler onMessage,
  ) {
    String? eventName;
    final dataLines = <String>[];
    for (final line in block.split(RegExp(r'\r?\n'))) {
      if (line.startsWith('event:')) {
        eventName = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        dataLines.add(line.substring(5).trimLeft());
      }
    }
    if (dataLines.isEmpty) return;
    final payload = dataLines.join('\n');
    Map<String, dynamic>? json;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) json = decoded;
    } catch (_) {
      return;
    }
    if (json == null) return;
    final ev = eventName ?? 'message';
    if (ev == 'connection' && json.containsKey('session_id')) {
      onConnection(json['session_id']! as String);
      return;
    }
    if (ev == 'message' || json.containsKey('type')) {
      onMessage(json);
    }
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }
}
