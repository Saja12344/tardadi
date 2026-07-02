import type { LocationPlace } from "@tardadi/shared";

const OSRM_BASE = "https://router.project-osrm.org";

export type RoadRouteResult = {
  /** [lat, lng][] — ready for Leaflet */
  coordinates: [number, number][];
  distanceMeters: number;
  durationSeconds: number;
};

function isValidPlace(place: LocationPlace): boolean {
  return (
    Number.isFinite(place.latitude) &&
    Number.isFinite(place.longitude) &&
    place.latitude >= -90 &&
    place.latitude <= 90 &&
    place.longitude >= -180 &&
    place.longitude <= 180
  );
}

export async function fetchRoadRoute(
  from: LocationPlace,
  to: LocationPlace
): Promise<RoadRouteResult> {
  if (!isValidPlace(from) || !isValidPlace(to)) {
    throw new Error("إحداثيات الموقع غير صحيحة. اختر الموقع من الخريطة مرة أخرى.");
  }

  const coords = `${from.longitude},${from.latitude};${to.longitude},${to.latitude}`;
  const params = new URLSearchParams({
    overview: "full",
    geometries: "geojson",
    steps: "false",
  });

  const response = await fetch(
    `${OSRM_BASE}/route/v1/driving/${coords}?${params}`,
    { headers: { "User-Agent": "TardadiAdmin/1.0" }, next: { revalidate: 0 } }
  );

  if (!response.ok) {
    throw new Error("تعذّر حساب المسار الآن. حاول مرة أخرى.");
  }

  const data = (await response.json()) as {
    code: string;
    routes?: Array<{
      distance: number;
      duration: number;
      geometry: { coordinates: [number, number][] };
    }>;
  };

  if (data.code !== "Ok" || !data.routes?.[0]) {
    throw new Error("لم نجد مسار طريق بين النقطتين. جرّب اختيار نقاط أقرب للطريق.");
  }

  const route = data.routes[0];
  const coordinates = route.geometry.coordinates.map(
    ([lng, lat]) => [lat, lng] as [number, number]
  );

  return {
    coordinates,
    distanceMeters: route.distance,
    durationSeconds: route.duration,
  };
}

export function encodePolyline(coords: [number, number][]): string {
  return JSON.stringify(coords);
}

export function decodePolyline(raw?: string | null): [number, number][] {
  if (!raw) return [];
  try {
    const parsed = JSON.parse(raw) as unknown;
    if (!Array.isArray(parsed)) return [];
    return parsed.filter(
      (p): p is [number, number] =>
        Array.isArray(p) &&
        p.length === 2 &&
        typeof p[0] === "number" &&
        typeof p[1] === "number"
    );
  } catch {
    return [];
  }
}
