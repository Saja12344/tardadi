import 'dart:convert';
import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import '../models/models.dart';

/// Decodes admin-stored polyline JSON: `[[lat, lng], ...]`.
List<LatLng> decodeRoutePolyline(String? raw) {
  if (raw == null || raw.trim().isEmpty) return [];
  try {
    final parsed = jsonDecode(raw);
    if (parsed is! List) return [];
    return parsed
        .whereType<List>()
        .where((point) => point.length >= 2)
        .map(
          (point) => LatLng(
            (point[0] as num).toDouble(),
            (point[1] as num).toDouble(),
          ),
        )
        .toList();
  } catch (_) {
    return [];
  }
}

List<LatLng> buildFallbackRoutePoints({
  LocationPlace? from,
  LocationPlace? to,
  required List<StopModel> stops,
}) {
  final ordered = [...stops]..sort((a, b) => a.sequenceNo.compareTo(b.sequenceNo));
  final points = <LatLng>[];
  if (from != null) {
    points.add(LatLng(from.latitude, from.longitude));
  }
  for (final stop in ordered) {
    points.add(LatLng(stop.latitude, stop.longitude));
  }
  if (to != null) {
    points.add(LatLng(to.latitude, to.longitude));
  }
  return points;
}

List<LatLng> resolveRoutePoints(RouteModel route, List<StopModel> stops) {
  final decoded = decodeRoutePolyline(route.polyline);
  if (decoded.length >= 2) return decoded;
  return buildFallbackRoutePoints(
    from: route.fromLocation,
    to: route.toLocation,
    stops: stops,
  );
}

/// First point on the route — trip start for map/GPS alignment in dev.
LatLng? resolveRouteStart(RouteModel route, List<StopModel> stops) {
  final points = resolveRoutePoints(route, stops);
  if (points.isNotEmpty) return points.first;
  final from = route.fromLocation;
  if (from != null) return LatLng(from.latitude, from.longitude);
  final ordered = [...stops]..sort((a, b) => a.sequenceNo.compareTo(b.sequenceNo));
  if (ordered.isEmpty) return null;
  return LatLng(ordered.first.latitude, ordered.first.longitude);
}

String? encodeRoutePolyline(List<LatLng> points) {
  if (points.length < 2) return null;
  return jsonEncode(
    points.map((point) => [point.latitude, point.longitude]).toList(),
  );
}

RouteModel reverseRouteModel(RouteModel route) {
  final points = decodeRoutePolyline(route.polyline);
  return RouteModel(
    routeId: route.routeId,
    name: route.name,
    code: route.code,
    colorHex: route.colorHex,
    status: route.status,
    fromLocation: route.toLocation,
    toLocation: route.fromLocation,
    polyline: points.length >= 2
        ? encodeRoutePolyline(points.reversed.toList())
        : route.polyline,
    nameAr: route.nameAr,
    stopsCount: route.stopsCount,
    activeBusCount: route.activeBusCount,
    liveBusCount: route.liveBusCount,
  );
}

List<StopModel> reverseStops(List<StopModel> stops) {
  final ordered = [...stops]..sort((a, b) => a.sequenceNo.compareTo(b.sequenceNo));
  final reversed = ordered.reversed.toList();
  return [
    for (var i = 0; i < reversed.length; i++)
      StopModel(
        stopId: reversed[i].stopId,
        routeId: reversed[i].routeId,
        name: reversed[i].name,
        latitude: reversed[i].latitude,
        longitude: reversed[i].longitude,
        sequenceNo: i + 1,
        nameAr: reversed[i].nameAr,
      ),
  ];
}

int nearestPointIndex(List<LatLng> route, LatLng point) {
  if (route.isEmpty) return 0;
  var bestIndex = 0;
  var bestDistance = double.infinity;
  const distance = Distance();
  for (var i = 0; i < route.length; i++) {
    final meters = distance.as(LengthUnit.Meter, route[i], point);
    if (meters < bestDistance) {
      bestDistance = meters;
      bestIndex = i;
    }
  }
  return bestIndex;
}

double distanceToRouteMeters(List<LatLng> route, LatLng point) {
  if (route.isEmpty) return 0;
  const distance = Distance();
  var best = double.infinity;
  for (final node in route) {
    final meters = distance.as(LengthUnit.Meter, node, point);
    if (meters < best) best = meters;
  }
  for (var i = 0; i < route.length - 1; i++) {
    final start = route[i];
    final end = route[i + 1];
    final segment = distance.as(LengthUnit.Meter, start, end);
    if (segment == 0) continue;
    final toStart = distance.as(LengthUnit.Meter, point, start);
    final toEnd = distance.as(LengthUnit.Meter, point, end);
    final projection = math.min(toStart, toEnd);
    if (projection < best) best = projection;
  }
  return best;
}
