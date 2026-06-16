import { NextRequest, NextResponse } from "next/server";
import { getSearchProvider, searchPlaces, sanitizeSearchQuery } from "@/lib/geocode.server";

export async function GET(request: NextRequest) {
  const query = sanitizeSearchQuery(
    request.nextUrl.searchParams.get("q") ?? ""
  );

  if (!query) {
    return NextResponse.json({ results: [], provider: getSearchProvider() });
  }

  try {
    const results = await searchPlaces(query);
    return NextResponse.json({ results, provider: getSearchProvider() });
  } catch {
    return NextResponse.json(
      { error: "تعذّر البحث عن الموقع. حاول مرة أخرى." },
      { status: 502 }
    );
  }
}
