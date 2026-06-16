import { NextRequest, NextResponse } from "next/server";
import { resolvePlaceById } from "@/lib/geocode.server";

export async function GET(request: NextRequest) {
  const placeId = request.nextUrl.searchParams.get("placeId")?.trim();
  if (!placeId) {
    return NextResponse.json({ error: "placeId required" }, { status: 400 });
  }

  try {
    const place = await resolvePlaceById(placeId);
    return NextResponse.json(place);
  } catch (error) {
    return NextResponse.json(
      { error: (error as Error).message || "Place not found" },
      { status: 502 }
    );
  }
}
