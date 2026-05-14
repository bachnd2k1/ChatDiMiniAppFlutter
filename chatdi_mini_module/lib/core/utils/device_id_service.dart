import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const _kDeviceIdKey = 'chatdi_device_id';

/// Persists a stable device id used for `x-device-id`.
class DeviceIdService {
  DeviceIdService._();
  static final DeviceIdService instance = DeviceIdService._();

  String? _cached;

  Future<String> getOrCreate() async {
    if (_cached != null) return _cached!;
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_kDeviceIdKey);
    if (existing != null && existing.isNotEmpty) {
      _cached = existing;
      return existing;
    }
    const uuid = Uuid();
    final id = uuid.v4();
    await prefs.setString(_kDeviceIdKey, id);
    _cached = id;
    return id;
  }
}
