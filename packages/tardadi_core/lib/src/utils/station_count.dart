import '../models/models.dart';

/// Start + intermediate + end.
int totalStationCount({
  required int intermediateStops,
  bool hasFrom = true,
  bool hasTo = true,
}) {
  return intermediateStops + (hasFrom ? 1 : 0) + (hasTo ? 1 : 0);
}

int routeTotalStations(RouteModel route) {
  if (route.stopsCount != null) return route.stopsCount!;
  return totalStationCount(
    intermediateStops: 0,
    hasFrom: route.fromLocation != null,
    hasTo: route.toLocation != null,
  );
}
