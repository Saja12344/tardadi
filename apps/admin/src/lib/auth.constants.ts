import type { AdminSession } from "@tardadi/shared";

export const SESSION_COOKIE = "tardadi_admin_session";
export const BUSINESS_CONTEXT_COOKIE = "tardadi_business_id";

export interface SessionPayload {
  token: string;
  user: AdminSession;
}

export function isSuperAdmin(user: AdminSession | null | undefined): boolean {
  return user?.role === "super_admin";
}

export function isBusinessAdmin(user: AdminSession | null | undefined): boolean {
  return user?.role === "business_admin";
}
