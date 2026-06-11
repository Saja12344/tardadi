import { GEOFENCE_MAX_DISTANCE_M } from "./constants";
import type { GeoPoint } from "./types";

const EARTH_RADIUS_M = 6_371_000;

function toRadians(degrees: number): number {
  return (degrees * Math.PI) / 180;
}

export function haversineDistanceM(a: GeoPoint, b: GeoPoint): number {
  const dLat = toRadians(b.latitude - a.latitude);
  const dLng = toRadians(b.longitude - a.longitude);
  const lat1 = toRadians(a.latitude);
  const lat2 = toRadians(b.latitude);

  const h =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLng / 2) ** 2;

  return 2 * EARTH_RADIUS_M * Math.asin(Math.sqrt(h));
}

export function isWithinGeofence(
  point: GeoPoint,
  stops: GeoPoint[],
  maxDistanceM = GEOFENCE_MAX_DISTANCE_M
): boolean {
  if (stops.length === 0) {
    return true;
  }

  return stops.some((stop) => haversineDistanceM(point, stop) <= maxDistanceM);
}

export function estimateEtaMinutes(
  busLocation: GeoPoint,
  stopLocation: GeoPoint,
  speedKmh = 30
): number {
  const distanceM = haversineDistanceM(busLocation, stopLocation);
  const speedMs = Math.max(speedKmh, 5) / 3.6;
  return Math.ceil(distanceM / speedMs / 60);
}
