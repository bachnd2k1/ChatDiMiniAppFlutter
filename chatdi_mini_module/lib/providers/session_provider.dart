import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../core/network/sse_service.dart';
import '../core/utils/device_id_service.dart';

/// SSE lifecycle + stable device id (`x-device-id`).
class SessionProvider extends ChangeNotifier {
  SessionProvider(ApiClient api)
      : _api = api,
        _sse = SseService(api);

  final ApiClient _api;
  final SseService _sse;

  String? sessionId;
  bool isConnected = false;
  String? deviceId;

  void Function(Map<String, dynamic>)? ssePayloadListener;

  Timer? _reconnectTimer;
  bool _lifecycleActive = false;

  bool get canSendMessages =>
      _lifecycleActive &&
      isConnected &&
      (sessionId?.isNotEmpty ?? false) &&
      (deviceId?.isNotEmpty ?? false);

  Future<String?> ensureConnectedSession({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    if (canSendMessages) return sessionId;

    if (!_lifecycleActive || !isConnected || sessionId == null || sessionId!.isEmpty) {
      await startChatLifecycle();
    }
    if (canSendMessages) return sessionId;

    final completer = Completer<String?>();
    void waitForConnection() {
      if (!completer.isCompleted && canSendMessages) {
        completer.complete(sessionId);
      }
    }

    addListener(waitForConnection);
    waitForConnection();
    try {
      return await completer.future.timeout(timeout, onTimeout: () => null);
    } finally {
      removeListener(waitForConnection);
    }
  }

  Future<void> startChatLifecycle() async {
    _lifecycleActive = true;
    deviceId = await DeviceIdService.instance.getOrCreate();
    _api.setDeviceIdFuture(DeviceIdService.instance.getOrCreate());
    _reconnectTimer?.cancel();
    await _sse.stop();
    sessionId = null;
    isConnected = false;
    notifyListeners();
    await _openSse();
  }

  Future<void> stopChatLifecycle() async {
    _lifecycleActive = false;
    _reconnectTimer?.cancel();
    await _sse.stop();
    sessionId = null;
    isConnected = false;
    notifyListeners();
  }

  Future<void> _openSse() async {
    if (!_lifecycleActive) return;
    await _sse.start(
      onConnection: (sid) {
        sessionId = sid;
        isConnected = true;
        notifyListeners();
      },
      onMessage: _onSsePayload,
      onConnectionLost: (error, stackTrace) {
        if (error != null) {
          debugPrint('[sse-lost] $error $stackTrace');
        } else {
          debugPrint('[sse-lost] stream closed');
        }
        _handleSseDisconnect();
      },
    );
  }

  void _handleSseDisconnect() {
    if (!_lifecycleActive) return;
    isConnected = false;
    sessionId = null;
    notifyListeners();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (!_lifecycleActive) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(milliseconds: 1000), () {
      if (!_lifecycleActive) return;
      _openSse();
    });
  }

  void _onSsePayload(Map<String, dynamic> data) {
    ssePayloadListener?.call(data);
    notifyListeners();
  }
}
