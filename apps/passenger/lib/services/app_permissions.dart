import 'package:geolocator/geolocator.dart';

import 'local_notification_service.dart';

class AppPermissions {
  AppPermissions._();

  /// Native OS location prompt only — shown after map onboarding.
  static Future<void> requestOnboardingLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    final current = await Geolocator.checkPermission();
    if (current == LocationPermission.whileInUse ||
        current == LocationPermission.always) {
      return;
    }

    if (current == LocationPermission.deniedForever) return;

    await Geolocator.requestPermission();
  }

  static Future<bool> hasNotificationPermission() {
    return LocalNotificationService.instance.hasPermission();
  }

  static Future<bool> requestNotificationPermission() {
    return LocalNotificationService.instance.requestPermission();
  }
}
