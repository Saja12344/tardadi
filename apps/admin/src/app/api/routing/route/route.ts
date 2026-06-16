import { NextRequest, NextResponse } from "next/server";
import type { LocationPlace } from "@tardadi/shared";
import { encodePolyline, fetchRoadRoute } from "@/lib/routing.server";

function parsePlace(raw: unknown, label: string): LocationPlace | null {
  if (!raw || typeof raw !== "object") return null;
  const p = raw as Record<string, unknown>;
  if (
    typeof p.address !== "string" ||
    typeof p.latitude !== "number" ||
    typeof p.longitude !== "number"
  ) {
    return null;
  }
  if (!p.address.trim()) return null;
  return {
    address: p.address,
    latitude: p.latitude,
    longitude: p.longitude,
  };
}

export async function POST(request: NextRequest) {
  let body: unknown;
  try {
    body = await request.json();
  } catch {
    return NextResponse.json({ error: "Invalid JSON" }, { status: 400 });
  }

  const payload = body as Record<string, unknown>;
  const from = parsePlace(payload.from, "from");
  const to = parsePlace(payload.to, "to");

  if (!from || !to) {
    return NextResponse.json(
      { error: "from and to locations are required" },
      { status: 400 }
    );
  }

  try {
    const route = await fetchRoadRoute(from, to);
    return NextResponse.json({
      coordinates: route.coordinates,
      distanceMeters: route.distanceMeters,
      durationSeconds: route.durationSeconds,
      polyline: encodePolyline(route.coordinates),
    });
  } catch (error) {
    return NextResponse.json(
      { error: (error as Error).message || "Routing failed" },
      { status: 502 }
    );
  }
}
