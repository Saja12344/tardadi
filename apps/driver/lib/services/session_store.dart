import 'package:tardadi_core/tardadi_core.dart';

class SessionStore {
  SessionStore._();

  static final SessionStore instance = SessionStore._();

  DriverSession? _session;
  String? _selectedVehicle;

  DriverSession? get session => _session;
  String? get selectedVehicle => _selectedVehicle;

  void set(DriverSession session) {
    _session = session;
  }

  void setVehicle(String vehicle) {
    _selectedVehicle = vehicle;
  }

  void clear() {
    _session = null;
    _selectedVehicle = null;
  }

  void updateTripId(String? tripId) {
    if (_session == null) return;
    _session = _session!.copyWith(
      tripId: tripId,
      clearTripId: tripId == null,
    );
  }

  void updateRoute(RouteModel route, List<StopModel> stops) {
    if (_session == null) return;
    _session = DriverSession(
      driver: _session!.driver,
      bus: _session!.bus,
      route: route,
      stops: stops,
      tripId: _session!.tripId,
    );
  }
}
