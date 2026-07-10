import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tardadi_core/tardadi_core.dart';

import '../l10n/app_localizations.dart';
import '../models/route_list_item.dart';
import '../services/app_permissions.dart';
import '../services/local_notification_service.dart';
import '../services/passenger_api.dart';
import '../services/user_session.dart';

/// Exactly three passenger notifications per enabled bus:
/// 1) bell enabled, 2) real ETA ≤ 5 min, 3) driver marked arrived.
class BusArrivalNotificationService {
  BusArrivalNotificationService._();

  static final BusArrivalNotificationService instance =
      BusArrivalNotificationService._();

  final _enabledBusIds = <String>{};
  final _enabledAt = <String, DateTime>{};
  final _notifiedFiveMin = <String>{};
  final _notifiedArrived = <String>{};
  final _reminderIds = <String, String>{};
  final _listeners = <VoidCallback>{};

  TardadiApi? _api;
  GlobalKey<ScaffoldMessengerState>? _messengerKey;

  void attachMessenger(GlobalKey<ScaffoldMessengerState> key) {
    _messengerKey = key;
  }

  bool isEnabled(String busId) => _enabledBusIds.contains(busId);

  void addListener(VoidCallback listener) => _listeners.add(listener);

  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  Future<void> toggle({
    required String busId,
    required String busName,
    required String routeId,
  }) async {
    if (_enabledBusIds.contains(busId)) {
      await disable(busId);
    } else {
      await enable(
        busId: busId,
        busName: busName,
        routeId: routeId,
      );
    }
  }

  Future<void> enable({
    required String busId,
    required String busName,
    required String routeId,
  }) async {
    if (!await AppPermissions.hasNotificationPermission()) {
      final granted = await LocalNotificationService.instance.requestPermission();
      if (!granted) {
        _showInAppFallback(_l10n.notificationsPermissionDenied);
        return;
      }
    }

    _enabledBusIds.add(busId);
    _enabledAt[busId] = DateTime.now();
    _notifiedFiveMin.remove(busId);
    _notifiedArrived.remove(busId);
    _notifyListeners();

    await _registerBackendReminder(busId: busId, routeId: routeId);
    await _showSystemNotification(
      _l10n.notificationsOn(busName),
      notificationId: _notificationId(busId, 1),
    );
  }

  Future<void> disable(String busId) async {
    _enabledBusIds.remove(busId);
    _enabledAt.remove(busId);
    _notifiedFiveMin.remove(busId);
    _notifiedArrived.remove(busId);

    final reminderId = _reminderIds.remove(busId);
    if (reminderId != null) {
      try {
        _api ??= createPassengerApi();
        await _api!.cancelReminder(reminderId);
      } catch (_) {}
    }

    _notifyListeners();
  }

  void updateFromLive({
    required List<BusArrivalItem> buses,
    required List<StopModel> stops,
  }) {
    if (_enabledBusIds.isEmpty || stops.isEmpty) return;

    final target = stops.first;
    final targetPoint = GeoPoint(
      latitude: target.latitude,
      longitude: target.longitude,
    );

    for (final bus in buses) {
      if (!_enabledBusIds.contains(bus.id)) continue;

      final enabledAt = _enabledAt[bus.id];
      if (enabledAt == null) continue;

      if (bus.lastArrivedAt != null && !_notifiedArrived.contains(bus.id)) {
        final arrival = DateTime.tryParse(bus.lastArrivedAt!);
        if (arrival != null && arrival.isAfter(enabledAt)) {
          _notifiedArrived.add(bus.id);
          unawaited(_showSystemNotification(
            _l10n.busArrived(bus.name),
            notificationId: _notificationId(bus.id, 3),
          ));
          continue;
        }
      }

      if (_notifiedFiveMin.contains(bus.id)) continue;

      final location = bus.currentLocation;
      if (location == null) continue;

      final eta = estimateEtaMinutes(location, targetPoint);
      if (eta <= 5) {
        _notifiedFiveMin.add(bus.id);
        unawaited(_showSystemNotification(
          _l10n.busMinutesAway(bus.name, eta),
          notificationId: _notificationId(bus.id, 2),
        ));
      }
    }
  }

  Future<void> _registerBackendReminder({
    required String busId,
    required String routeId,
  }) async {
    try {
      _api ??= createPassengerApi();
      final routeData = await _api!.getRoute(routeId);
      if (routeData.stops.isEmpty) return;

      final userId = UserSession.instance.phoneNumber ?? 'passenger-local';
      final reminderId = await _api!.createReminder(
        userId: userId,
        busId: busId,
        routeId: routeId,
        stopId: routeData.stops.first.stopId,
        fcmToken: 'local-notifications',
      );
      _reminderIds[busId] = reminderId;
    } catch (_) {}
  }

  int _notificationId(String busId, int kind) => Object.hash(busId, kind);

  Future<void> _showSystemNotification(
    String body, {
    int? notificationId,
  }) async {
    await LocalNotificationService.instance.show(
      title: _l10n.appName,
      body: body,
      id: notificationId,
    );
  }

  void _showInAppFallback(String message) {
    final messenger = _messengerKey?.currentState;
    if (messenger == null) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  AppLocalizations get _l10n =>
      AppLocalizations(UserSession.instance.language);
}
