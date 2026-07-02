import { NextRequest, NextResponse } from "next/server";
import { resolvePlaceById } from "@/lib/geocode.server";

export async function GET(request: NextRequest) {
  const placeId = request.nextUrl.searchParams.get("placeId")?.trim();
  if (!placeId) {
    return NextResponse.json(
      { error: "اختر نتيجة موقع من القائمة أولًا." },
      { status: 400 }
    );
  }

  try {
    const place = await resolvePlaceById(placeId);
    return NextResponse.json(place);
  } catch (error) {
    return NextResponse.json(
      { error: (error as Error).message || "لم نتمكن من العثور على هذا الموقع. جرّب البحث مرة أخرى." },
      { status: 502 }
    );
  }
}
