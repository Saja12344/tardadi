"use client";

import dynamic from "next/dynamic";
import type { LocationPlace } from "@tardadi/shared";

const LocationPickerInner = dynamic(() => import("./LocationPickerInner"), {
  ssr: false,
  loading: () => (
    <div className="location-picker location-picker-loading">
      جاري تحميل الخريطة...
    </div>
  ),
});

type LocationPickerProps = {
  label: string;
  hint?: string;
  pinColor?: string;
  value: LocationPlace | null;
  onChange: (place: LocationPlace | null) => void;
};

export default function LocationPicker(props: LocationPickerProps) {
  return <LocationPickerInner {...props} />;
}
