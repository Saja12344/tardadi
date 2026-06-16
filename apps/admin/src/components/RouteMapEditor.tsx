"use client";

import dynamic from "next/dynamic";
import type { LatLngExpression } from "leaflet";
import type { LocationPlace } from "@tardadi/shared";
import type { MapMarker } from "@/lib/mapUtils";
import type { PickMode } from "./RouteMapEditorInner";

const RouteMapEditorInner = dynamic(() => import("./RouteMapEditorInner"), {
  ssr: false,
  loading: () => (
    <div className="route-map-editor route-map-loading">
      جاري تحميل الخريطة...
    </div>
  ),
});

type RouteMapEditorProps = {
  fromLocation: LocationPlace | null;
  toLocation: LocationPlace | null;
  pickMode: PickMode;
  roadPolyline?: LatLngExpression[];
  extraMarkers?: MapMarker[];
  onMapPick: (lat: number, lng: number) => void;
  onMarkerDrag: (kind: "from" | "to", lat: number, lng: number) => void;
};

export default function RouteMapEditor(props: RouteMapEditorProps) {
  return <RouteMapEditorInner {...props} />;
}

export type { PickMode };
