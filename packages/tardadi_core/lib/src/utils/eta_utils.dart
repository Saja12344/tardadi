import 'dart:math' as math;

import '../models/models.dart';

const _earthRadiusM = 6371000.0;

double haversineMeters(GeoPoint a, GeoPoint b) {
  final dLat = _toRadians(b.latitude - a.latitude);
  final dLng = _toRadians(b.longitude - a.longitude);
  final lat1 = _toRadians(a.latitude);
  final lat2 = _toRadians(b.latitude);

  final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1) *
          math.cos(lat2) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);

  return 2 * _earthRadiusM * math.asin(math.sqrt(h));
}

double _toRadians(double degrees) => degrees * math.pi / 180;

int estimateEtaMinutes(
  GeoPoint bus,
  GeoPoint target, {
  double speedKmh = 30,
}) {
  final meters = haversineMeters(bus, target);
  final speedMs = math.max(speedKmh, 5) / 3.6;
  return (meters / speedMs / 60).ceil().clamp(1, 99);
}
