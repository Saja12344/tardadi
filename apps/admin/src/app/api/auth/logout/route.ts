import { NextResponse } from "next/server";
import {
  BUSINESS_CONTEXT_COOKIE,
  SESSION_COOKIE,
} from "@/lib/auth.constants";

export async function POST() {
  const response = NextResponse.json({ success: true });
  response.cookies.set(SESSION_COOKIE, "", { maxAge: 0, path: "/" });
  response.cookies.set(BUSINESS_CONTEXT_COOKIE, "", { maxAge: 0, path: "/" });
  return response;
}
