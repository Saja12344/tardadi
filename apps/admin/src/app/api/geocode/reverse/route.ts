import { NextRequest, NextResponse } from "next/server";
import {
  reverseGeocode,
  sanitizeCoordinates,
} from "@/lib/geocode.server";

export async function GET(request: NextRequest) {
  const latRaw = request.nextUrl.searchParams.get("lat") ?? "";
  const lngRaw = request.nextUrl.searchParams.get("lng") ?? "";
  const coords = sanitizeCoordinates(latRaw, lngRaw);

  if (!coords) {
    return NextResponse.json(
      { error: "إحداثيات الموقع غير صحيحة. اختر الموقع من الخريطة مرة أخرى." },
      { status: 400 }
    );
  }

  try {
    const place = await reverseGeocode(coords.lat, coords.lng);
    return NextResponse.json(place);
  } catch {
    return NextResponse.json(
      { error: "تعذّر تحديد العنوان." },
      { status: 502 }
    );
  }
}
