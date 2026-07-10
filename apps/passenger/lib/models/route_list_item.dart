import 'package:tardadi_core/tardadi_core.dart';

enum VehicleType { golfCar, bus, vanCar }

class RouteListItem {
  const RouteListItem({
    required this.routeId,
    required this.name,
    required this.frequencyLabel,
    required this.busCountLabel,
    required this.stationsCountLabel,
    required this.isBusiness,
    this.nameAr,
    this.route,
    this.stopsCount = 0,
    this.activeBusCount = 0,
    this.liveBusCount = 0,
  });

  final String routeId;
  final String name;
  final String? nameAr;
  final String frequencyLabel;
  final String busCountLabel;
  final String stationsCountLabel;
  final bool isBusiness;
  final RouteModel? route;
  final int stopsCount;
  final int activeBusCount;
  final int liveBusCount;

  factory RouteListItem.fromRoute(RouteModel route) {
    final stations = routeTotalStations(route);
    final active = route.activeBusCount ?? 0;
    final live = route.liveBusCount ?? 0;
    return RouteListItem(
      routeId: route.routeId,
      name: route.name,
      nameAr: route.nameAr,
      frequencyLabel: live > 0 ? 'Live' : 'Scheduled',
      busCountLabel: live > 0 ? '$live live / $active' : '$active Buses',
      stationsCountLabel: '$stations Stations',
      isBusiness: route.isBusiness,
      route: route,
      stopsCount: stations,
      activeBusCount: active,
      liveBusCount: live,
    );
  }
}

class BusArrivalItem {
  const BusArrivalItem({
    required this.id,
    required this.name,
    required this.vehicleType,
    required this.minutesAway,
    required this.crowdingLabel,
    this.isLive = false,
    this.currentLocation,
    this.lastArrivedAt,
  });

  final String id;
  final String name;
  final VehicleType vehicleType;
  final int minutesAway;
  final String crowdingLabel;
  final bool isLive;
  final GeoPoint? currentLocation;
  final String? lastArrivedAt;

  factory BusArrivalItem.fromBus(
    BusModel bus, {
    required int minutesAway,
  }) {
    final label = bus.label.toLowerCase();
    final vehicleType = label.contains('golf')
        ? VehicleType.golfCar
        : label.contains('van')
            ? VehicleType.vanCar
            : VehicleType.bus;

    return BusArrivalItem(
      id: bus.busId,
      name: bus.label,
      vehicleType: vehicleType,
      minutesAway: minutesAway,
      crowdingLabel: bus.crowdLevel ?? 'medium',
      isLive: bus.isLive,
      currentLocation: bus.currentLocation,
      lastArrivedAt: bus.lastArrivedAt,
    );
  }
}
