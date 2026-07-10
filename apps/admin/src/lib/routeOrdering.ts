import type { LocationPlace } from "@tardadi/shared";

/** Sort intermediate stops from nearest-to-start → nearest-to-end along the route axis. */
export function sortPlacesAlongRoute(
  from: LocationPlace,
  to: LocationPlace,
  places: LocationPlace[]
): LocationPlace[] {
  if (places.length <= 1) return places;

  const dx = to.longitude - from.longitude;
  const dy = to.latitude - from.latitude;
  const lenSq = dx * dx + dy * dy || 1;

  const progress = (place: LocationPlace) =>
    ((place.longitude - from.longitude) * dx +
      (place.latitude - from.latitude) * dy) /
    lenSq;

  return [...places].sort((a, b) => progress(a) - progress(b));
}

/** Snap each stop to its nearest index on a road polyline [lat, lng][]. */
export function sortPlacesAlongPolyline(
  polyline: [number, number][],
  places: LocationPlace[]
): LocationPlace[] {
  if (places.length <= 1 || polyline.length < 2) return places;

  const progress = (place: LocationPlace) => {
    let best = 0;
    let bestDist = Number.POSITIVE_INFINITY;
    for (let i = 0; i < polyline.length; i++) {
      const [lat, lng] = polyline[i];
      const dLat = lat - place.latitude;
      const dLng = lng - place.longitude;
      const dist = dLat * dLat + dLng * dLng;
      if (dist < bestDist) {
        bestDist = dist;
        best = i;
      }
    }
    return best;
  };

  return [...places].sort((a, b) => progress(a) - progress(b));
}
