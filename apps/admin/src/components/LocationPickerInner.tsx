"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import {
  MapContainer,
  Marker,
  TileLayer,
  useMap,
  useMapEvents,
} from "react-leaflet";
import L from "leaflet";
import type { LatLngExpression } from "leaflet";
import type { LocationPlace } from "@tardadi/shared";
import "leaflet/dist/leaflet.css";
import { DEFAULT_MAP_CENTER, DEFAULT_MAP_ZOOM } from "@/lib/mapUtils";

const pinIcon = (color: string) =>
  L.divIcon({
    className: "location-pin-marker",
    html: `<span class="location-pin" style="--pin-color:${color}"></span>`,
    iconSize: [28, 28],
    iconAnchor: [14, 28],
  });

function FlyTo({ position }: { position: LatLngExpression }) {
  const map = useMap();
  useEffect(() => {
    map.flyTo(position, Math.max(map.getZoom(), 14), { duration: 0.6 });
  }, [map, position]);
  return null;
}

function MapClickHandler({
  onPick,
}: {
  onPick: (lat: number, lng: number) => void;
}) {
  useMapEvents({
    click(event) {
      onPick(event.latlng.lat, event.latlng.lng);
    },
  });
  return null;
}

type SearchResult = LocationPlace;

type LocationPickerInnerProps = {
  label: string;
  hint?: string;
  pinColor?: string;
  value: LocationPlace | null;
  onChange: (place: LocationPlace | null) => void;
};

export default function LocationPickerInner({
  label,
  hint = "ابحث عن مكان أو حرّك الدبوس على الخريطة",
  pinColor = "#EB4F26",
  value,
  onChange,
}: LocationPickerInnerProps) {
  const [query, setQuery] = useState(value?.address ?? "");
  const [results, setResults] = useState<SearchResult[]>([]);
  const [isOpen, setIsOpen] = useState(false);
  const [isSearching, setIsSearching] = useState(false);
  const [isResolving, setIsResolving] = useState(false);
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const wrapperRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    setQuery(value?.address ?? "");
  }, [value]);

  const position: LatLngExpression = value
    ? [value.latitude, value.longitude]
    : DEFAULT_MAP_CENTER;

  const reverseGeocode = useCallback(
    async (lat: number, lng: number) => {
      setIsResolving(true);
      try {
        const response = await fetch(
          `/api/geocode/reverse?lat=${lat}&lng=${lng}`
        );
        const data = await response.json();
        if (!response.ok) throw new Error(data.error);
        onChange(data as LocationPlace);
        setQuery(data.address);
      } catch {
        const fallback: LocationPlace = {
          address: `${lat.toFixed(5)}, ${lng.toFixed(5)}`,
          latitude: lat,
          longitude: lng,
        };
        onChange(fallback);
        setQuery(fallback.address);
      } finally {
        setIsResolving(false);
      }
    },
    [onChange]
  );

  const handleMapPick = useCallback(
    (lat: number, lng: number) => {
      void reverseGeocode(lat, lng);
      setIsOpen(false);
    },
    [reverseGeocode]
  );

  useEffect(() => {
    if (debounceRef.current) clearTimeout(debounceRef.current);

    if (query.trim().length < 2) {
      setResults([]);
      setIsSearching(false);
      return;
    }

    setIsSearching(true);
    debounceRef.current = setTimeout(async () => {
      try {
        const response = await fetch(
          `/api/geocode/search?q=${encodeURIComponent(query.trim())}`
        );
        const data = await response.json();
        setResults(Array.isArray(data.results) ? data.results : []);
        setIsOpen(true);
      } catch {
        setResults([]);
      } finally {
        setIsSearching(false);
      }
    }, 350);

    return () => {
      if (debounceRef.current) clearTimeout(debounceRef.current);
    };
  }, [query]);

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (
        wrapperRef.current &&
        !wrapperRef.current.contains(event.target as Node)
      ) {
        setIsOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  function selectResult(place: SearchResult) {
    onChange(place);
    setQuery(place.address);
    setResults([]);
    setIsOpen(false);
  }

  return (
    <div className="location-picker">
      <div className="location-picker-header">
        <label>{label}</label>
        {value && (
          <button
            type="button"
            className="location-clear"
            onClick={() => {
              onChange(null);
              setQuery("");
            }}
          >
            مسح
          </button>
        )}
      </div>

      <div className="location-search-wrap" ref={wrapperRef}>
        <span className="location-search-icon" aria-hidden="true" />
        <input
          className="location-search-input"
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          onFocus={() => results.length > 0 && setIsOpen(true)}
          placeholder="ابحث: مثال الملز، روشن، جامعة الملك سعود..."
          autoComplete="off"
        />
        {(isSearching || isResolving) && (
          <span className="location-search-status">...</span>
        )}

        {isOpen && results.length > 0 && (
          <ul className="location-search-results" role="listbox">
            {results.map((result) => (
              <li key={`${result.latitude}-${result.longitude}-${result.address}`}>
                <button
                  type="button"
                  role="option"
                  onClick={() => selectResult(result)}
                >
                  <span className="result-pin" aria-hidden="true" />
                  <span className="result-text">{result.address}</span>
                </button>
              </li>
            ))}
          </ul>
        )}
      </div>

      <p className="map-hint">{hint}</p>

      <div className="map-container location-picker-map">
        {!value && (
          <div className="location-map-hint">
            <span>اضغط على الخريطة لوضع الدبوس</span>
          </div>
        )}
        <MapContainer
          center={position}
          zoom={value ? 14 : DEFAULT_MAP_ZOOM}
          scrollWheelZoom
          style={{ height: 220, width: "100%", borderRadius: 12 }}
        >
          <TileLayer
            attribution='&copy; OpenStreetMap'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />
          <MapClickHandler onPick={handleMapPick} />
          {value && (
            <>
              <FlyTo position={position} />
              <Marker
                position={position}
                icon={pinIcon(pinColor)}
                draggable
                eventHandlers={{
                  dragend(event) {
                    const marker = event.target;
                    const { lat, lng } = marker.getLatLng();
                    void reverseGeocode(lat, lng);
                  },
                }}
              />
            </>
          )}
        </MapContainer>
      </div>

      {value && (
        <p className="location-coords">
          {value.latitude.toFixed(5)}, {value.longitude.toFixed(5)}
        </p>
      )}
    </div>
  );
}
