import type { LatLngExpression } from "leaflet";
import type { GeoPoint, LocationPlace, Route, Stop } from "@tardadi/shared";

/** Default map center — Riyadh */
export const DEFAULT_MAP_CENTER: LatLngExpression = [24.7136, 46.6753];
export const DEFAULT_MAP_ZOOM = 12;

export type MapMarker = {
  id: string;
  position: LatLngExpression;
  label: string;
  color?: string;
  kind?: "stop" | "bus" | "from" | "to";
};

export function locationToLatLng(place: LocationPlace): LatLngExpression {
  return [place.latitude, place.longitude];
}

export function stopsToMarkers(stops: Stop[]): MapMarker[] {
  return stops.map((stop) => ({
    id: stop.stopId,
    position: [stop.latitude, stop.longitude],
    label: `${stop.sequenceNo}. ${stop.name}`,
    kind: "stop" as const,
  }));
}

export function routeEndpointsToMarkers(
  fromLocation?: LocationPlace | null,
  toLocation?: LocationPlace | null
): MapMarker[] {
  const markers: MapMarker[] = [];
  if (fromLocation) {
    markers.push({
      id: "from",
      position: locationToLatLng(fromLocation),
      label: `من: ${fromLocation.address}`,
      kind: "from",
    });
  }
  if (toLocation) {
    markers.push({
      id: "to",
      position: locationToLatLng(toLocation),
      label: `إلى: ${toLocation.address}`,
      kind: "to",
    });
  }
  return markers;
}

export function buildRoutePolyline(
  fromLocation?: LocationPlace | null,
  toLocation?: LocationPlace | null,
  stops: Stop[] = []
): LatLngExpression[] | undefined {
  const points: LatLngExpression[] = [];
  if (fromLocation) points.push(locationToLatLng(fromLocation));
  for (const stop of [...stops].sort((a, b) => a.sequenceNo - b.sequenceNo)) {
    points.push([stop.latitude, stop.longitude]);
  }
  if (toLocation) points.push(locationToLatLng(toLocation));
  return points.length > 1 ? points : undefined;
}

export function routeToMapData(route: Route, stops: Stop[] = []) {
  return {
    markers: [
      ...routeEndpointsToMarkers(route.fromLocation, route.toLocation),
      ...stopsToMarkers(stops),
    ],
    polyline: buildRoutePolyline(route.fromLocation, route.toLocation, stops),
  };
}

export function geoPointToLatLng(point: GeoPoint): LatLngExpression {
  return [point.latitude, point.longitude];
}
