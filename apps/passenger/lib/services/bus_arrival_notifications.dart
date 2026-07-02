import 'dart:async';

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/user_session.dart';
import 'package:tardadi_core/tardadi_core.dart';

class BusArrivalNotificationService {
  BusArrivalNotificationService._();

  static final BusArrivalNotificationService instance =
      BusArrivalNotificationService._();

  static const _approachThresholds = [5, 3, 1, 0];

  final _enabledBusIds = <String>{};
  final _timers = <String, Timer>{};
  final _remainingMinutes = <String, int>{};
  final _notifiedThresholds = <String, Set<int>>{};
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
    required int initialMinutes,
  }) async {
    if (_enabledBusIds.contains(busId)) {
      await disable(busId, busName: busName);
    } else {
      await enable(
        busId: busId,
        busName: busName,
        routeId: routeId,
        initialMinutes: initialMinutes,
      );
    }
  }

  Future<void> enable({
    required String busId,
    required String busName,
    required String routeId,
    required int initialMinutes,
  }) async {
    _enabledBusIds.add(busId);
    _remainingMinutes[busId] = initialMinutes;
    _notifiedThresholds[busId] = {};
    _notifyListeners();

    await _registerBackendReminder(
      busId: busId,
      routeId: routeId,
    );

    _showMessage(_l10n.notificationsOn(busName));
    _checkApproachThresholds(busId: busId, busName: busName);

    _timers[busId]?.cancel();
    _timers[busId] = Timer.periodic(const Duration(seconds: 20), (_) {
      final remaining = _remainingMinutes[busId];
      if (remaining == null) return;

      if (remaining > 0) {
        _remainingMinutes[busId] = remaining - 1;
      }

      _checkApproachThresholds(busId: busId, busName: busName);

      if (_remainingMinutes[busId] == 0) {
        disable(busId);
      }
    });
  }

  Future<void> disable(String busId, {String? busName}) async {
    _timers.remove(busId)?.cancel();
    _enabledBusIds.remove(busId);
    _remainingMinutes.remove(busId);
    _notifiedThresholds.remove(busId);

    final reminderId = _reminderIds.remove(busId);
    if (reminderId != null) {
      try {
        _api ??= TardadiApi(config: AppConfig.dev());
        await _api!.cancelReminder(reminderId);
      } catch (_) {}
    }

    _notifyListeners();

    if (busName != null) {
      _showMessage(_l10n.notificationsOff(busName));
    }
  }

  Future<void> _registerBackendReminder({
    required String busId,
    required String routeId,
  }) async {
    try {
      _api ??= TardadiApi(config: AppConfig.dev());
      final routeData = await _api!.getRoute(routeId);
      if (routeData.stops.isEmpty) return;

      final reminderId = await _api!.createReminder(
        userId: 'passenger-demo',
        busId: busId,
        routeId: routeId,
        stopId: routeData.stops.first.stopId,
        fcmToken: 'fcm-token-demo',
      );
      _reminderIds[busId] = reminderId;
    } catch (_) {}
  }

  void _checkApproachThresholds({
    required String busId,
    required String busName,
  }) {
    final remaining = _remainingMinutes[busId];
    if (remaining == null) return;

    final notified = _notifiedThresholds.putIfAbsent(busId, () => {});

    for (final threshold in _approachThresholds) {
      if (remaining > threshold || notified.contains(threshold)) continue;

      notified.add(threshold);
      if (threshold == 0) {
        _showMessage(_l10n.busArrived(busName));
      } else {
        _showMessage(_l10n.busMinutesAway(busName, threshold));
      }
    }
  }

  void _showMessage(String message) {
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
