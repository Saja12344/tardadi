"use client";

import { useCallback, useEffect } from "react";
import {
  MapContainer,
  Marker,
  Polyline,
  Popup,
  TileLayer,
  useMap,
  useMapEvents,
} from "react-leaflet";
import L from "leaflet";
import type { LatLngExpression } from "leaflet";
import type { LocationPlace } from "@tardadi/shared";
import "leaflet/dist/leaflet.css";
import { MAP_TILES, ROUTE_LINE } from "@/lib/mapConfig";
import { DEFAULT_MAP_CENTER, DEFAULT_MAP_ZOOM, type MapMarker } from "@/lib/mapUtils";

export type PickMode = "from" | "to" | null;

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

function FitBounds({ points }: { points: LatLngExpression[] }) {
  const map = useMap();
  useEffect(() => {
    if (points.length === 0) return;
    if (points.length === 1) {
      map.setView(points[0], 14);
      return;
    }
    map.fitBounds(L.latLngBounds(points), { padding: [48, 48], maxZoom: 15 });
  }, [map, points]);
  return null;
}

function MapClickHandler({
  enabled,
  onPick,
}: {
  enabled: boolean;
  onPick: (lat: number, lng: number) => void;
}) {
  useMapEvents({
    click(event) {
      if (enabled) onPick(event.latlng.lat, event.latlng.lng);
    },
  });
  return null;
}

type RouteMapEditorInnerProps = {
  fromLocation: LocationPlace | null;
  toLocation: LocationPlace | null;
  pickMode: PickMode;
  roadPolyline?: LatLngExpression[];
  extraMarkers?: MapMarker[];
  onMapPick: (lat: number, lng: number) => void;
  onMarkerDrag: (kind: "from" | "to", lat: number, lng: number) => void;
};

export default function RouteMapEditorInner({
  fromLocation,
  toLocation,
  pickMode,
  roadPolyline,
  extraMarkers = [],
  onMapPick,
  onMarkerDrag,
}: RouteMapEditorInnerProps) {
  const points: LatLngExpression[] = [];
  if (fromLocation) points.push([fromLocation.latitude, fromLocation.longitude]);
  if (toLocation) points.push([toLocation.latitude, toLocation.longitude]);
  for (const m of extraMarkers) points.push(m.position);

  const reverseGeocode = useCallback(
    async (kind: "from" | "to", lat: number, lng: number) => {
      onMarkerDrag(kind, lat, lng);
    },
    [onMarkerDrag]
  );

  return (
    <div className="route-map-editor">
      {pickMode && (
        <div className={`route-map-banner banner-${pickMode}`}>
          {pickMode === "from"
            ? "اضغط على الخريطة لتحديد نقطة البداية"
            : "اضغط على الخريطة لتحديد نقطة النهاية"}
        </div>
      )}

      <MapContainer
        center={DEFAULT_MAP_CENTER}
        zoom={DEFAULT_MAP_ZOOM}
        scrollWheelZoom
        className="route-map-canvas"
      >
        <TileLayer
          attribution={MAP_TILES.attribution}
          url={MAP_TILES.url}
          subdomains={MAP_TILES.subdomains}
        />

        <FitBounds points={points} />
        <MapClickHandler enabled={pickMode !== null} onPick={onMapPick} />

        {roadPolyline && roadPolyline.length > 1 && (
          <Polyline
            positions={roadPolyline}
            pathOptions={{
              color: ROUTE_LINE.color,
              weight: ROUTE_LINE.weight,
              opacity: ROUTE_LINE.opacity,
            }}
          />
        )}

        {fromLocation && (
          <Marker
            position={[fromLocation.latitude, fromLocation.longitude]}
            icon={endpointIcon("from")}
            draggable
            eventHandlers={{
              dragend(e) {
                const { lat, lng } = e.target.getLatLng();
                void reverseGeocode("from", lat, lng);
              },
            }}
          >
            <Popup>من: {fromLocation.address}</Popup>
          </Marker>
        )}

        {toLocation && (
          <Marker
            position={[toLocation.latitude, toLocation.longitude]}
            icon={endpointIcon("to")}
            draggable
            eventHandlers={{
              dragend(e) {
                const { lat, lng } = e.target.getLatLng();
                void reverseGeocode("to", lat, lng);
              },
            }}
          >
            <Popup>إلى: {toLocation.address}</Popup>
          </Marker>
        )}

        {extraMarkers.map((marker) => (
          <Marker
            key={marker.id}
            position={marker.position}
            icon={stopIcon}
          >
            <Popup>{marker.label}</Popup>
          </Marker>
        ))}
      </MapContainer>
    </div>
  );
}
