class RouteModel {
  const RouteModel({
    required this.routeId,
    required this.name,
    required this.code,
    required this.colorHex,
    required this.status,
  });

  final String routeId;
  final String name;
  final String code;
  final String colorHex;
  final String status;

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      routeId: json['routeId'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      colorHex: json['colorHex'] as String? ?? '#FF6B00',
      status: json['status'] as String? ?? 'active',
    );
  }
}

class StopModel {
  const StopModel({
    required this.stopId,
    required this.routeId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.sequenceNo,
  });

  final String stopId;
  final String routeId;
  final String name;
  final double latitude;
  final double longitude;
  final int sequenceNo;

  factory StopModel.fromJson(Map<String, dynamic> json) {
    return StopModel(
      stopId: json['stopId'] as String? ?? json['id'] as String? ?? '',
      routeId: json['routeId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      sequenceNo: json['sequenceNo'] as int? ?? 0,
    );
  }
}

class BusModel {
  const BusModel({
    required this.busId,
    required this.label,
    required this.plateNo,
    required this.status,
    this.currentLocation,
    this.lastSeenAt,
  });

  final String busId;
  final String label;
  final String plateNo;
  final String status;
  final GeoPoint? currentLocation;
  final String? lastSeenAt;

  factory BusModel.fromJson(Map<String, dynamic> json) {
    final location = json['currentLocation'] as Map<String, dynamic>?;
    return BusModel(
      busId: json['busId'] as String? ?? json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      plateNo: json['plateNo'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      currentLocation: location == null
          ? null
          : GeoPoint(
              latitude: (location['latitude'] as num).toDouble(),
              longitude: (location['longitude'] as num).toDouble(),
            ),
      lastSeenAt: json['lastSeenAt'] as String?,
    );
  }
}

class DriverModel {
  const DriverModel({
    required this.driverId,
    required this.driverCode,
    required this.name,
    this.assignedRouteId,
    this.assignedBusId,
    required this.status,
  });

  final String driverId;
  final String driverCode;
  final String name;
  final String? assignedRouteId;
  final String? assignedBusId;
  final String status;

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      driverId: json['driverId'] as String? ?? json['id'] as String? ?? '',
      driverCode: json['driverCode'] as String? ?? '',
      name: json['name'] as String? ?? '',
      assignedRouteId: json['assignedRouteId'] as String?,
      assignedBusId: json['assignedBusId'] as String?,
      status: json['status'] as String? ?? 'active',
    );
  }
}

class TripModel {
  const TripModel({
    required this.tripId,
    required this.busId,
    required this.driverId,
    required this.routeId,
    required this.tripStatus,
    this.startedAt,
  });

  final String tripId;
  final String busId;
  final String driverId;
  final String routeId;
  final String tripStatus;
  final String? startedAt;

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      tripId: json['tripId'] as String? ?? json['id'] as String? ?? '',
      busId: json['busId'] as String? ?? '',
      driverId: json['driverId'] as String? ?? '',
      routeId: json['routeId'] as String? ?? '',
      tripStatus: json['tripStatus'] as String? ?? 'scheduled',
      startedAt: json['startedAt'] as String?,
    );
  }
}

class GeoPoint {
  const GeoPoint({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

class DriverSession {
  const DriverSession({
    required this.driver,
    required this.bus,
    required this.route,
    required this.stops,
    this.tripId,
  });

  final DriverModel driver;
  final BusModel bus;
  final RouteModel route;
  final List<StopModel> stops;
  final String? tripId;

  DriverSession copyWith({String? tripId}) {
    return DriverSession(
      driver: driver,
      bus: bus,
      route: route,
      stops: stops,
      tripId: tripId ?? this.tripId,
    );
  }
}
