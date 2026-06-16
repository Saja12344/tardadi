"use client";

import { useEffect, useRef, useState } from "react";
import type { LocationPlace } from "@tardadi/shared";

type SearchResult = LocationPlace & {
  placeId?: string;
  source?: "google" | "osm";
};

type LocationSearchFieldProps = {
  label: string;
  placeholder?: string;
  value: LocationPlace | null;
  onChange: (place: LocationPlace | null) => void;
  onFocus?: () => void;
  accent?: "from" | "to";
};

export default function LocationSearchField({
  label,
  placeholder = "ابحث عن مكان...",
  value,
  onChange,
  onFocus,
  accent = "from",
}: LocationSearchFieldProps) {
  const [query, setQuery] = useState(value?.address ?? "");
  const [results, setResults] = useState<SearchResult[]>([]);
  const [searchProvider, setSearchProvider] = useState<"google" | "osm">("osm");
  const [isOpen, setIsOpen] = useState(false);
  const [isSearching, setIsSearching] = useState(false);
  const [isResolving, setIsResolving] = useState(false);
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const wrapperRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    setQuery(value?.address ?? "");
  }, [value]);

  useEffect(() => {
    if (debounceRef.current) clearTimeout(debounceRef.current);

    if (query.trim().length < 2 || (value && query === value.address)) {
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
        if (data.provider === "google" || data.provider === "osm") {
          setSearchProvider(data.provider);
        }
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
  }, [query, value]);

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

  async function selectResult(result: SearchResult) {
    setIsResolving(true);
    try {
      let place: LocationPlace = result;

      if (
        result.placeId &&
        (result.latitude === 0 || result.longitude === 0)
      ) {
        const response = await fetch(
          `/api/geocode/place?placeId=${encodeURIComponent(result.placeId)}`
        );
        const data = await response.json();
        if (!response.ok) throw new Error(data.error);
        place = { ...data, address: result.address };
      }

      onChange(place);
      setQuery(place.address);
      setResults([]);
      setIsOpen(false);
    } catch {
      onChange(result);
      setQuery(result.address);
      setResults([]);
      setIsOpen(false);
    } finally {
      setIsResolving(false);
    }
  }

  return (
    <div className={`location-search-field accent-${accent}`}>
      <div className="location-search-field-label">
        <span className={`accent-dot accent-dot-${accent}`} />
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
        <span className="location-search-icon" aria-hidden="true">
          🔍
        </span>
        <input
          className="location-search-input"
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          onFocus={() => {
            onFocus?.();
            if (results.length > 0) setIsOpen(true);
          }}
          placeholder={placeholder}
          autoComplete="off"
        />
        {(isSearching || isResolving) && (
          <span className="location-search-status">...</span>
        )}

        {isOpen && results.length > 0 && (
          <ul className="location-search-results" role="listbox">
            {results.map((result) => (
              <li
                key={result.placeId ?? `${result.latitude}-${result.address}`}
              >
                <button type="button" onClick={() => selectResult(result)}>
                  <span className="result-pin">📍</span>
                  <span className="result-text">{result.address}</span>
                </button>
              </li>
            ))}
          </ul>
        )}
      </div>

      {searchProvider === "osm" && (
        <p className="search-provider-hint">
          نتائج OpenStreetMap — لنتائج مثل Google Maps أضف{" "}
          <code>GOOGLE_MAPS_API_KEY</code>
        </p>
      )}
    </div>
  );
}
