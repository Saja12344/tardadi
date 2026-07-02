import { NextRequest, NextResponse } from "next/server";
import {
  getServerApiUrl,
  getServerOrgId,
  isAllowedProxyPath,
} from "@/lib/env.server";

const MUTATION_METHODS = new Set(["POST", "PUT", "PATCH", "DELETE"]);

async function proxyRequest(
  request: NextRequest,
  pathSegments: string[]
): Promise<NextResponse> {
  if (!isAllowedProxyPath(pathSegments)) {
    return NextResponse.json(
      { success: false, error: "ليس لديك صلاحية للوصول لهذا الطلب." },
      { status: 403 }
    );
  }

  const apiUrl = getServerApiUrl();
  const orgId = getServerOrgId();
  const pathname = pathSegments.join("/");
  const targetUrl = new URL(`${apiUrl}/${pathname}`);

  request.nextUrl.searchParams.forEach((value, key) => {
    if (key !== "organizationId") {
      targetUrl.searchParams.set(key, value);
    }
  });
  targetUrl.searchParams.set("organizationId", orgId);

  const headers = new Headers();
  const contentType = request.headers.get("content-type");
  if (contentType) {
    headers.set("Content-Type", contentType);
  }

  // Future: attach admin session token here — never expose it to the browser.
  const adminToken = process.env.ADMIN_API_TOKEN;
  if (adminToken) {
    headers.set("Authorization", `Bearer ${adminToken}`);
  }

  const init: RequestInit = {
    method: request.method,
    headers,
    cache: "no-store",
  };

  if (MUTATION_METHODS.has(request.method)) {
    init.body = await request.text();
  }

  let upstream: Response;
  try {
    upstream = await fetch(targetUrl.toString(), init);
  } catch {
    return NextResponse.json(
      {
        success: false,
        error: "تعذّر الاتصال بالخادم. تأكد أن الباكند شغال ثم حدّث الصفحة.",
      },
      { status: 502 }
    );
  }

  const body = await upstream.text();
  return new NextResponse(body, {
    status: upstream.status,
    headers: {
      "Content-Type":
        upstream.headers.get("content-type") || "application/json",
    },
  });
}

type RouteContext = { params: Promise<{ path: string[] }> };

export async function GET(request: NextRequest, context: RouteContext) {
  const { path } = await context.params;
  return proxyRequest(request, path);
}

export async function POST(request: NextRequest, context: RouteContext) {
  const { path } = await context.params;
  return proxyRequest(request, path);
}

export async function PUT(request: NextRequest, context: RouteContext) {
  const { path } = await context.params;
  return proxyRequest(request, path);
}

export async function PATCH(request: NextRequest, context: RouteContext) {
  const { path } = await context.params;
  return proxyRequest(request, path);
}

export async function DELETE(request: NextRequest, context: RouteContext) {
  const { path } = await context.params;
  return proxyRequest(request, path);
}
