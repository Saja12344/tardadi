import 'package:tardadi_core/tardadi_core.dart';

class SessionStore {
  SessionStore._();

  static final SessionStore instance = SessionStore._();

  DriverSession? _session;

  DriverSession? get session => _session;

  void set(DriverSession session) {
    _session = session;
  }

  void clear() {
    _session = null;
  }

  void updateTripId(String? tripId) {
    if (_session == null) return;
    _session = _session!.copyWith(tripId: tripId);
  }
}
