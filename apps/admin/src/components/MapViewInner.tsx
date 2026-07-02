"use client";

import { useEffect } from "react";
import {
  MapContainer,
  Marker,
  Polyline,
  Popup,
  TileLayer,
  useMap,
} from "react-leaflet";
import L from "leaflet";
import type { LatLngExpression } from "leaflet";
import "leaflet/dist/leaflet.css";
import { MAP_TILES, ROUTE_LINE } from "@/lib/mapConfig";
import {
  DEFAULT_MAP_CENTER,
  DEFAULT_MAP_ZOOM,
  type MapMarker,
} from "@/lib/mapUtils";

const endpointIcon = (kind: "from" | "to") =>
  L.divIcon({
    className: "endpoint-marker",
    html: `<span class="endpoint-pin endpoint-pin-${kind}"></span>`,
    iconSize: [20, 20],
    iconAnchor: [10, 10],
  });

const stopIcon = L.divIcon({
  className: "stop-marker",
  html: `<span class="stop-pin"></span>`,
  iconSize: [14, 14],
  iconAnchor: [7, 7],
});

const busIcon = L.divIcon({
  className: "bus-marker",
  html: `<span class="bus-pin" aria-hidden="true"></span>`,
  iconSize: [28, 28],
  iconAnchor: [14, 14],
});

function FitBounds({ points }: { points: LatLngExpression[] }) {
  const map = useMap();

  useEffect(() => {
    if (points.length === 0) return;
    if (points.length === 1) {
      map.setView(points[0], DEFAULT_MAP_ZOOM);
      return;
    }
    const bounds = L.latLngBounds(points);
    map.fitBounds(bounds, { padding: [40, 40], maxZoom: 15 });
  }, [map, points]);

  return null;
}

type MapViewProps = {
  markers?: MapMarker[];
  polyline?: LatLngExpression[];
  className?: string;
  height?: number | string;
};

export default function MapViewInner({
  markers = [],
  polyline,
  className = "",
  height = 360,
}: MapViewProps) {
  const points = markers.map((m) => m.position);
  const linePoints =
    polyline && polyline.length > 1
      ? polyline
      : markers.length > 1
        ? markers.map((m) => m.position)
        : undefined;

  return (
    <div
      className={`map-container ${className}`}
      style={{ height, width: "100%" }}
    >
      <MapContainer
        center={DEFAULT_MAP_CENTER}
        zoom={DEFAULT_MAP_ZOOM}
        scrollWheelZoom
        style={{ height: "100%", width: "100%", borderRadius: 12 }}
      >
        <TileLayer
          attribution={MAP_TILES.attribution}
          url={MAP_TILES.url}
          subdomains={MAP_TILES.subdomains}
        />

        <FitBounds points={points} />

        {linePoints && linePoints.length > 1 && (
          <Polyline
            positions={linePoints}
            pathOptions={{
              color: ROUTE_LINE.color,
              weight: ROUTE_LINE.weight,
              opacity: ROUTE_LINE.opacity,
            }}
          />
        )}

        {markers.map((marker) => (
          <Marker
            key={marker.id}
            position={marker.position}
            icon={
              marker.kind === "bus"
                ? busIcon
                : marker.kind === "from"
                  ? endpointIcon("from")
                  : marker.kind === "to"
                    ? endpointIcon("to")
                    : stopIcon
            }
          >
            <Popup>{marker.label}</Popup>
          </Marker>
        ))}
      </MapContainer>
    </div>
  );
}
