import type { LocationPlace } from "@tardadi/shared";

const NOMINATIM_BASE = "https://nominatim.openstreetmap.org";
const USER_AGENT = "TardadiAdmin/1.0 (bus-location-picker)";

/** Riyadh metro — search biased here (ترددي operates in Riyadh). */
const RIYADH_VIEWBOX = "46.35,24.45,47.15,25.05";
const RIYADH_CENTER = { lat: 24.7136, lng: 46.6753 };

export type SearchPlaceResult = LocationPlace & {
  placeId?: string;
  source: "google" | "osm";
};

type NominatimSearchResult = {
  display_name: string;
  lat: string;
  lon: string;
  importance?: number;
};

type NominatimReverseResult = {
  display_name: string;
  lat: string;
  lon: string;
};

function toPlace(result: {
  display_name: string;
  lat: string;
  lon: string;
}): LocationPlace {
  return {
    address: result.display_name,
    latitude: Number.parseFloat(result.lat),
    longitude: Number.parseFloat(result.lon),
  };
}

function distanceKm(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number {
  const R = 6371;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

function rankOsmResults(
  query: string,
  results: NominatimSearchResult[]
): NominatimSearchResult[] {
  const q = query.trim().toLowerCase();

  return [...results].sort((a, b) => {
    const score = (r: NominatimSearchResult) => {
      let s = (r.importance ?? 0) * 10;
      const name = r.display_name.toLowerCase();
      if (name.includes("riyadh") || name.includes("الرياض")) s += 100;
      if (name.includes("jeddah") || name.includes("jiddah") || name.includes("جدة"))
        s -= 80;
      if (name.includes(q)) s += 30;
      s -= distanceKm(
        RIYADH_CENTER.lat,
        RIYADH_CENTER.lng,
        Number.parseFloat(r.lat),
        Number.parseFloat(r.lon)
      );
      return s;
    };
    return score(b) - score(a);
  });
}

export function sanitizeSearchQuery(raw: string): string | null {
  const query = raw.trim().slice(0, 120);
  if (query.length < 2) return null;
  return query;
}

export function sanitizeCoordinates(
  latRaw: string,
  lngRaw: string
): { lat: number; lng: number } | null {
  const lat = Number.parseFloat(latRaw);
  const lng = Number.parseFloat(lngRaw);
  if (!Number.isFinite(lat) || !Number.isFinite(lng)) return null;
  if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;
  return { lat, lng };
}

async function searchNominatim(query: string): Promise<SearchPlaceResult[]> {
  const params = new URLSearchParams({
    q: query,
    format: "json",
    limit: "10",
    countrycodes: "sa",
    viewbox: RIYADH_VIEWBOX,
    bounded: "0",
    "accept-language": "ar,en",
  });

  const response = await fetch(`${NOMINATIM_BASE}/search?${params}`, {
    headers: { "User-Agent": USER_AGENT },
    next: { revalidate: 0 },
  });

  if (!response.ok) {
    throw new Error("تعذّر البحث عن الموقع. حاول مرة أخرى.");
  }

  const data = (await response.json()) as NominatimSearchResult[];
  const ranked = rankOsmResults(query, data).slice(0, 6);

  return ranked.map((r) => ({
    ...toPlace(r),
    source: "osm" as const,
  }));
}

async function resolveGooglePlace(
  placeId: string,
  apiKey: string
): Promise<LocationPlace | null> {
  const params = new URLSearchParams({
    place_id: placeId,
    key: apiKey,
    fields: "geometry,formatted_address,name",
    language: "ar",
  });

  const response = await fetch(
    `https://maps.googleapis.com/maps/api/place/details/json?${params}`,
    { next: { revalidate: 0 } }
  );

  if (!response.ok) return null;

  const data = (await response.json()) as {
    status: string;
    result?: {
      formatted_address?: string;
      name?: string;
      geometry?: { location?: { lat: number; lng: number } };
    };
  };

  if (data.status !== "OK" || !data.result?.geometry?.location) return null;

  const { lat, lng } = data.result.geometry.location;
  return {
    address:
      data.result.formatted_address ||
      data.result.name ||
      `${lat}, ${lng}`,
    latitude: lat,
    longitude: lng,
  };
}

async function searchGooglePlaces(
  query: string,
  apiKey: string
): Promise<SearchPlaceResult[]> {
  const params = new URLSearchParams({
    input: query,
    key: apiKey,
    language: "ar",
    components: "country:sa",
    location: `${RIYADH_CENTER.lat},${RIYADH_CENTER.lng}`,
    radius: "80000",
  });

  const response = await fetch(
    `https://maps.googleapis.com/maps/api/place/autocomplete/json?${params}`,
    { next: { revalidate: 0 } }
  );

  if (!response.ok) {
    throw new Error("تعذّر البحث عن الموقع. حاول مرة أخرى.");
  }

  const data = (await response.json()) as {
    status: string;
    predictions?: Array<{ description: string; place_id: string }>;
    error_message?: string;
  };

  if (data.status !== "OK" && data.status !== "ZERO_RESULTS") {
    throw new Error("تعذّر البحث في Google Maps. حاول مرة أخرى.");
  }

  const predictions = data.predictions?.slice(0, 6) ?? [];
  const resolved = await Promise.all(
    predictions.map(async (p) => {
      const place = await resolveGooglePlace(p.place_id, apiKey);
      if (!place) {
        return {
          address: p.description,
          latitude: 0,
          longitude: 0,
          placeId: p.place_id,
          source: "google" as const,
        };
      }
      return {
        ...place,
        address: p.description,
        placeId: p.place_id,
        source: "google" as const,
      };
    })
  );

  return resolved.filter(Boolean);
}

/** Search places — Google Places if API key set, else OpenStreetMap (Riyadh-biased). */
export async function searchPlaces(query: string): Promise<SearchPlaceResult[]> {
  const googleKey = process.env.GOOGLE_MAPS_API_KEY;
  if (googleKey) {
    try {
      const googleResults = await searchGooglePlaces(query, googleKey);
      if (googleResults.length > 0) return googleResults;
    } catch {
      // fall through to OSM
    }
  }
  return searchNominatim(query);
}

export async function resolvePlaceById(placeId: string): Promise<LocationPlace> {
  const googleKey = process.env.GOOGLE_MAPS_API_KEY;
  if (!googleKey) {
    throw new Error("البحث المتقدم يحتاج مفتاح Google Maps API.");
  }
  const place = await resolveGooglePlace(placeId, googleKey);
  if (!place) throw new Error("لم نتمكن من العثور على هذا الموقع. جرّب البحث مرة أخرى.");
  return place;
}

export async function reverseGeocode(
  lat: number,
  lng: number
): Promise<LocationPlace> {
  const params = new URLSearchParams({
    lat: String(lat),
    lon: String(lng),
    format: "json",
    "accept-language": "ar,en",
  });

  const response = await fetch(`${NOMINATIM_BASE}/reverse?${params}`, {
    headers: { "User-Agent": USER_AGENT },
    next: { revalidate: 0 },
  });

  if (!response.ok) {
    throw new Error("تعذّر تحديد العنوان.");
  }

  const data = (await response.json()) as NominatimReverseResult;
  return toPlace(data);
}

export function getSearchProvider(): "google" | "osm" {
  return process.env.GOOGLE_MAPS_API_KEY ? "google" : "osm";
}
