class LocationPlace {
  const LocationPlace({
    required this.address,
    required this.latitude,
    required this.longitude,
    this.addressAr,
  });

  final String address;
  final double latitude;
  final double longitude;
  final String? addressAr;

  factory LocationPlace.fromJson(Map<String, dynamic> json) {
    return LocationPlace(
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      addressAr: json['addressAr'] as String?,
    );
  }

  GeoPoint toGeoPoint() =>
      GeoPoint(latitude: latitude, longitude: longitude);
}

class RouteModel {
  const RouteModel({
    required this.routeId,
    required this.name,
    required this.code,
    required this.colorHex,
    required this.status,
    this.fromLocation,
    this.toLocation,
    this.polyline,
    this.nameAr,
    this.stopsCount,
    this.activeBusCount,
    this.liveBusCount,
    this.accessMode = 'public',
  });

  final String routeId;
  final String name;
  final String code;
  final String colorHex;
  final String status;
  final LocationPlace? fromLocation;
  final LocationPlace? toLocation;
  final String? polyline;
  final String? nameAr;
  final int? stopsCount;
  final int? activeBusCount;
  final int? liveBusCount;
  final String accessMode;

  bool get isBusiness => accessMode == 'private';

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    final from = json['fromLocation'] as Map<String, dynamic>?;
    final to = json['toLocation'] as Map<String, dynamic>?;
    return RouteModel(
      routeId: json['routeId'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      colorHex: json['colorHex'] as String? ?? '#FF6B00',
      status: json['status'] as String? ?? 'active',
      fromLocation: from == null ? null : LocationPlace.fromJson(from),
      toLocation: to == null ? null : LocationPlace.fromJson(to),
      polyline: json['polyline'] as String?,
      nameAr: json['nameAr'] as String?,
      stopsCount: (json['stopsCount'] as num?)?.toInt(),
      activeBusCount: (json['activeBusCount'] as num?)?.toInt(),
      liveBusCount: (json['liveBusCount'] as num?)?.toInt(),
      accessMode: json['accessMode'] as String? ?? 'public',
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
    this.nameAr,
  });

  final String stopId;
  final String routeId;
  final String name;
  final double latitude;
  final double longitude;
  final int sequenceNo;
  final String? nameAr;

  factory StopModel.fromJson(Map<String, dynamic> json) {
    return StopModel(
      stopId: json['stopId'] as String? ?? json['id'] as String? ?? '',
      routeId: json['routeId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      sequenceNo: json['sequenceNo'] as int? ?? 0,
      nameAr: json['nameAr'] as String?,
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
    this.crowdLevel,
    this.currentTripId,
    this.tripId,
    this.lastArrivedAt,
    this.lastArrivedStopId,
  });

  final String busId;
  final String label;
  final String plateNo;
  final String status;
  final GeoPoint? currentLocation;
  final String? lastSeenAt;
  final String? crowdLevel;
  final String? currentTripId;
  final String? tripId;
  final String? lastArrivedAt;
  final String? lastArrivedStopId;

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
      crowdLevel: json['crowdLevel'] as String?,
      currentTripId: json['currentTripId'] as String?,
      tripId: json['tripId'] as String?,
      lastArrivedAt: json['lastArrivedAt'] as String?,
      lastArrivedStopId: json['lastArrivedStopId'] as String?,
    );
  }

  bool get isLive {
    if (lastSeenAt == null) return false;
    final seen = DateTime.tryParse(lastSeenAt!);
    if (seen == null) return false;
    return DateTime.now().difference(seen).inSeconds <= 60;
  }
}

class DriverModel {
  const DriverModel({
    required this.driverId,
    required this.name,
    required this.phone,
    this.driverCode,
    this.assignedRouteId,
    this.assignedBusId,
    required this.status,
    this.nameAr,
  });

  final String driverId;
  final String name;
  final String phone;
  final String? driverCode;
  final String? assignedRouteId;
  final String? assignedBusId;
  final String status;
  final String? nameAr;

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      driverId: json['driverId'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      driverCode: json['driverCode'] as String?,
      assignedRouteId: json['assignedRouteId'] as String?,
      assignedBusId: json['assignedBusId'] as String?,
      status: json['status'] as String? ?? 'active',
      nameAr: json['nameAr'] as String?,
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

  DriverSession copyWith({String? tripId, bool clearTripId = false}) {
    return DriverSession(
      driver: driver,
      bus: bus,
      route: route,
      stops: stops,
      tripId: clearTripId ? null : (tripId ?? this.tripId),
    );
  }
}

class RouteLiveSnapshot {
  const RouteLiveSnapshot({
    required this.route,
    required this.stops,
    required this.buses,
    required this.liveBusCount,
  });

  final RouteModel route;
  final List<StopModel> stops;
  final List<BusModel> buses;
  final int liveBusCount;

  factory RouteLiveSnapshot.fromJson(Map<String, dynamic> json) {
    return RouteLiveSnapshot(
      route: RouteModel.fromJson(json['route'] as Map<String, dynamic>),
      stops: (json['stops'] as List)
          .map((e) => StopModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      buses: (json['buses'] as List)
          .map((e) => BusModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      liveBusCount: (json['liveBusCount'] as num?)?.toInt() ?? 0,
    );
  }
}
