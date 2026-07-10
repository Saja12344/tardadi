import 'package:shared_preferences/shared_preferences.dart';

/// Local prefs for per-driver onboarding (vehicle pick on first login).
class DriverPrefs {
  DriverPrefs._();

  static final DriverPrefs instance = DriverPrefs._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static const _localeKey = 'app_locale';

  String _setupKey(String driverKey) => 'vehicle_setup_done_$driverKey';
  String _vehicleKey(String driverKey) => 'selected_vehicle_$driverKey';

  Future<String?> getLocaleCode() async {
    await init();
    return _prefs!.getString(_localeKey);
  }

  Future<void> saveLocaleCode(String code) async {
    await init();
    await _prefs!.setString(_localeKey, code);
  }

  static String driverKey({required String phone, required String driverId}) {
    final normalized = phone.replaceAll(RegExp(r'\s+'), '');
    if (normalized.isNotEmpty) return normalized;
    if (driverId.isNotEmpty) return driverId;
    return 'unknown';
  }

  Future<bool> hasCompletedVehicleSetup(String driverKey) async {
    await init();
    return _prefs!.getBool(_setupKey(driverKey)) ?? false;
  }

  Future<String?> getSelectedVehicle(String driverKey) async {
    await init();
    return _prefs!.getString(_vehicleKey(driverKey));
  }

  Future<void> saveVehicleSetup({
    required String driverKey,
    required String vehicle,
  }) async {
    await init();
    await _prefs!.setBool(_setupKey(driverKey), true);
    await _prefs!.setString(_vehicleKey(driverKey), vehicle);
  }
}
