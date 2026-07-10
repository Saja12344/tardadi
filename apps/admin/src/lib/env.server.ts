/**
 * Server-only environment variables.
 * Never import this file from client components ("use client").
 */

const DEFAULT_API_URL =
  "http://127.0.0.1:5001/tardadi-5bd8e/us-central1/api";
const DEFAULT_ORG_ID = "demo-org";

/** Allowed API path prefixes for the admin BFF proxy (extend here as features grow). */
export const ADMIN_PROXY_ALLOWLIST = [
  "routes",
  "buses",
  "drivers",
  "trips",
  "health",
] as const;

export type AdminProxyResource = (typeof ADMIN_PROXY_ALLOWLIST)[number];

export function getServerApiUrl(): string {
  return (
    process.env.TARDADI_API_URL ||
    process.env.NEXT_PUBLIC_API_URL ||
    DEFAULT_API_URL
  ).replace(/\/$/, "");
}

export function getServerOrgId(): string {
  return (
    process.env.TARDADI_ORG_ID ||
    process.env.NEXT_PUBLIC_ORG_ID ||
    DEFAULT_ORG_ID
  );
}

export function isAllowedProxyPath(segments: string[]): boolean {
  // Paths mirror backend: /api/routes, /api/buses, …
  if (segments.length < 2 || segments[0] !== "api") return false;
  const resource = segments[1] as AdminProxyResource;
  return (ADMIN_PROXY_ALLOWLIST as readonly string[]).includes(resource);
}
