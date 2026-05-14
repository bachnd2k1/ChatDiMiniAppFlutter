import 'dart:convert';

/// Backend may wrap payloads in `{ "data": ... }` or return raw arrays/objects.
dynamic unwrapApiJson(dynamic decoded) {
  if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
    return decoded['data'];
  }
  return decoded;
}

List<Map<String, dynamic>> asJsonObjectList(dynamic value) {
  if (value is! List) return [];
  return value.whereType<Map<String, dynamic>>().toList();
}

Map<String, dynamic>? decodeMap(String body) {
  final decoded = jsonDecode(body);
  if (decoded is Map<String, dynamic>) return decoded;
  return null;
}
