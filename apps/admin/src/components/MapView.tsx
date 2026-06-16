"use client";

import dynamic from "next/dynamic";
import type { LatLngExpression } from "leaflet";
import type { MapMarker } from "@/lib/mapUtils";

const MapViewInner = dynamic(() => import("./MapViewInner"), {
  ssr: false,
  loading: () => (
    <div className="map-loading" style={{ height: 360 }}>
      جاري تحميل الخريطة...
    </div>
  ),
});

type MapViewProps = {
  markers?: MapMarker[];
  polyline?: LatLngExpression[];
  className?: string;
  height?: number | string;
};

export default function MapView(props: MapViewProps) {
  return <MapViewInner {...props} />;
}
