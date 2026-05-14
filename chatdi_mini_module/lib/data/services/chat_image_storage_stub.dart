import 'package:http/http.dart' as http;

/// Web: không lưu file cục bộ trong triển khai này.
class ChatImageStorage {
  ChatImageStorage({http.Client? client});

  Future<String?> saveSsePayload(String payload, {required String messageId}) async =>
      null;

  bool isProbablyLocalSavedPath(String raw) => false;
}
