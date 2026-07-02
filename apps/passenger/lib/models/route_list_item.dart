enum VehicleType { golfCar, bus, vanCar }

class RouteListItem {
  const RouteListItem({
    required this.routeId,
    required this.name,
    required this.frequencyLabel,
    required this.busCountLabel,
    required this.stationsCountLabel,
    required this.isBusiness,
  });

  final String routeId;
  final String name;
  final String frequencyLabel;
  final String busCountLabel;
  final String stationsCountLabel;
  final bool isBusiness;

  static List<RouteListItem> demoRoutes() {
    return const [
      RouteListItem(
        routeId: 'business-1',
        name: 'Tkaful alrajhin',
        frequencyLabel: 'Every 5 min',
        busCountLabel: '2 Buses',
        stationsCountLabel: '5 Stations',
        isBusiness: true,
      ),
      RouteListItem(
        routeId: 'public-1',
        name: 'Roshan',
        frequencyLabel: 'Every 5 min',
        busCountLabel: '2 Buses',
        stationsCountLabel: '4 Stations',
        isBusiness: false,
      ),
      RouteListItem(
        routeId: 'public-2',
        name: 'Diriyah',
        frequencyLabel: 'Every 2 min',
        busCountLabel: '12 Buses',
        stationsCountLabel: '8 Stations',
        isBusiness: false,
      ),
      RouteListItem(
        routeId: 'public-3',
        name: 'Avindar',
        frequencyLabel: 'Every 5 min',
        busCountLabel: '2 Buses',
        stationsCountLabel: '3 Stations',
        isBusiness: false,
      ),
    ];
  }
}

class BusArrivalItem {
  const BusArrivalItem({
    required this.id,
    required this.name,
    required this.vehicleType,
    required this.arrivalLabel,
    required this.crowdingLabel,
    this.isActive = false,
  });

  final String id;
  final String name;
  final VehicleType vehicleType;
  final String arrivalLabel;
  final String crowdingLabel;
  final bool isActive;

  int get minutesAway {
    final match = RegExp(r'(\d+)').firstMatch(arrivalLabel);
    return match != null ? int.parse(match.group(1)!) : 5;
  }

  String get formattedArrivalLabel =>
      '${minutesAway.toString().padLeft(2, '0')} min';

  static List<BusArrivalItem> demoForRoute(String routeName) {
    if (routeName.toLowerCase().contains('tkaful')) {
      return const [
        BusArrivalItem(
          id: 'tkaful-golf-1',
          name: 'Golf car',
          vehicleType: VehicleType.golfCar,
          arrivalLabel: '05 min',
          crowdingLabel: 'Medium',
          isActive: true,
        ),
        BusArrivalItem(
          id: 'tkaful-van-1',
          name: 'Van car',
          vehicleType: VehicleType.vanCar,
          arrivalLabel: '09 min',
          crowdingLabel: 'Low',
        ),
        BusArrivalItem(
          id: 'tkaful-golf-2',
          name: 'Golf car',
          vehicleType: VehicleType.golfCar,
          arrivalLabel: '18 min',
          crowdingLabel: 'High',
        ),
      ];
    }

    return const [
      BusArrivalItem(
        id: 'bus-12',
        name: 'Bus 12',
        vehicleType: VehicleType.bus,
        arrivalLabel: '04 min',
        crowdingLabel: 'Medium',
        isActive: true,
      ),
      BusArrivalItem(
        id: 'van-3',
        name: 'Van car',
        vehicleType: VehicleType.vanCar,
        arrivalLabel: '08 min',
        crowdingLabel: 'Low',
      ),
      BusArrivalItem(
        id: 'bus-7',
        name: 'Bus 7',
        vehicleType: VehicleType.bus,
        arrivalLabel: '11 min',
        crowdingLabel: 'Low',
      ),
    ];
  }
}
