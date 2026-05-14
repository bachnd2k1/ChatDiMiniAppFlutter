import 'package:flutter/services.dart';

/// Set to `true` only when the Dart entrypoint [miniAppMain] runs (native mini app).
bool chatDiMiniAppEmbeddedInNativeHost = false;

/// Asks the iOS/Android host to close the mini app surface (modal, nav pop, etc.).
Future<void> requestChatDiMiniAppHostClose() async {
  const channel = MethodChannel('chatdi/mini_app');
  try {
    await channel.invokeMethod<void>('close');
  } on MissingPluginException {
    // Standalone `flutter run` — no native handler.
  }
}
