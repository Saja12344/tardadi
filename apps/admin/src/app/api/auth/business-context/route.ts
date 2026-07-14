import { NextRequest, NextResponse } from "next/server";
import { BUSINESS_CONTEXT_COOKIE } from "@/lib/auth.constants";
import { getSession } from "@/lib/auth.server";

export async function POST(request: NextRequest) {
  const session = await getSession();
  if (!session || session.user.role !== "super_admin") {
    return NextResponse.json(
      { success: false, error: "ليس لديك صلاحية لتغيير الشركة." },
      { status: 403 }
    );
  }

  const { businessId } = (await request.json()) as { businessId?: string };
  if (!businessId) {
    return NextResponse.json(
      { success: false, error: "حدّد الشركة." },
      { status: 400 }
    );
  }

  const response = NextResponse.json({ success: true, data: { businessId } });
  response.cookies.set(BUSINESS_CONTEXT_COOKIE, businessId, {
    httpOnly: true,
    sameSite: "lax",
    secure: process.env.NODE_ENV === "production",
    path: "/",
    maxAge: 60 * 60 * 24 * 7,
  });
  return response;
}
