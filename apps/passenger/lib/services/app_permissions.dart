import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';

import 'local_notification_service.dart';

class AppPermissions {
  AppPermissions._();

  /// Native system prompts shown at the end of onboarding.
  static Future<void> requestOnboardingPermissions({
    required bool requestLocation,
  }) async {
    await LocalNotificationService.instance.initialize();

    // Let the custom dialog close before showing OS sheets.
    await SchedulerBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 350));

    await LocalNotificationService.instance.requestPermission();

    if (!requestLocation) return;

    // Android/iOS need a beat between consecutive permission dialogs.
    await Future<void>.delayed(const Duration(milliseconds: 450));
    await Geolocator.requestPermission();
  }

  static Future<bool> hasNotificationPermission() {
    return LocalNotificationService.instance.hasPermission();
  }
}
