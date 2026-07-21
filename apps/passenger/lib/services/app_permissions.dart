import 'dart:io';

import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';

import 'local_notification_service.dart';

class AppPermissions {
  AppPermissions._();

  /// End of onboarding: each platform shows its own native permission UI only.
  ///
  /// iOS location uses Core Location (`requestWhenInUseAuthorization`) via
  /// [Geolocator.requestPermission]. Android uses the runtime location
  /// permission dialog for `ACCESS_FINE_LOCATION`.
  static Future<void> requestOnboardingPermissions({
    required bool requestLocation,
  }) async {
    await LocalNotificationService.instance.initialize();
    await SchedulerBinding.instance.endOfFrame;

    await _requestNativeNotificationPermission();

    if (!requestLocation) return;

    // iOS presents one system sheet at a time.
    if (Platform.isIOS) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }

    await _requestNativeLocationPermission();
  }

  /// iOS: Core Location when-in-use authorization sheet.
  /// Android: system runtime location permission dialog.
  static Future<void> _requestNativeLocationPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

  static Future<bool> _requestNativeNotificationPermission() {
    return LocalNotificationService.instance.requestPermission();
  }

  static Future<bool> hasNotificationPermission() {
    return LocalNotificationService.instance.hasPermission();
  }
}
