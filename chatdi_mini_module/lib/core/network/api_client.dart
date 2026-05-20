import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_constants.dart';
import '../utils/json_api.dart';

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    String acceptLanguage = 'en',
    Future<String>? deviceIdFuture,
  })  : _http = httpClient ?? http.Client(),
        _acceptLanguage = acceptLanguage,
        _deviceIdFuture = deviceIdFuture;

  final http.Client _http;
  String _acceptLanguage;

  String get acceptLanguage => _acceptLanguage;

  void setAcceptLanguage(String languageCode) {
    _acceptLanguage = languageCode.isEmpty ? 'en' : languageCode;
  }
  Future<String>? _deviceIdFuture;

  /// Gửi `x-premium: true|false` — mặc định `false` (docs/backend).
  bool _premium = false;

  bool get premium => _premium;

  void setDeviceIdFuture(Future<String> future) {
    _deviceIdFuture = future;
  }

  void setPremium(bool value) {
    _premium = value;
  }

  Map<String, String> get _commonHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json, application/problem+json',
        'Accept-Language': _acceptLanguage,
      };

  Future<Map<String, String>> _withSession({
    String? sessionId,
    bool deviceOnly = false,
  }) async {
    final headers = Map<String, String>.from(_commonHeaders);
    if (_deviceIdFuture != null) {
      headers['x-device-id'] = await _deviceIdFuture!;
    }
    if (!deviceOnly &&
        sessionId != null &&
        sessionId.isNotEmpty) {
      headers['x-session-id'] = sessionId;
    }
    headers['x-premium'] = _premium ? 'true' : 'false';
    return headers;
  }

  Uri _uri(String path) => Uri.parse('${ApiConstants.baseUrl}$path');

  Future<dynamic> getJson(String path, {String? sessionId}) async {
    final res = await _http.get(
      _uri(path),
      headers: await _withSession(
        sessionId: sessionId,
        deviceOnly: sessionId == null || sessionId.isEmpty,
      ),
    );
    final map = decodeMap(res.body);
    if (res.statusCode < 200 || res.statusCode >= 300 || map == null) {
      throw ApiException(statusCode: res.statusCode, body: res.body);
    }
    return unwrapApiJson(map);
  }

  Future<dynamic> postJson(
    String path,
    Map<String, dynamic> body, {
    String? sessionId,
  }) async {
    final headers = await _withSession(sessionId: sessionId);
    final res = await _http.post(
      _uri(path),
      headers: headers,
      body: jsonEncode(body),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(statusCode: res.statusCode, body: res.body);
    }
    if (res.body.trim().isEmpty) return null;
    final map = decodeMap(res.body);
    return map != null ? unwrapApiJson(map) : null;
  }

  Future<StreamedSSE> openSse() async {
    final req = http.Request('GET', _uri(ApiConstants.ssePath));
    req.headers.addAll(await _withSession(deviceOnly: true));
    req.headers['Accept'] = 'text/event-stream';
    final streamed = await _http.send(req);
    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      final text = await streamed.stream.bytesToString();
      throw ApiException(statusCode: streamed.statusCode, body: text);
    }
    return StreamedSSE(streamed.stream);
  }

  void close() => _http.close();
}

class StreamedSSE {
  StreamedSSE(this.stream);
  final http.ByteStream stream;
}

class ApiException implements Exception {
  ApiException({required this.statusCode, required this.body});
  final int statusCode;
  final String body;

  @override
  String toString() => 'ApiException($statusCode): $body';
}
