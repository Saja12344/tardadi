import type { Request } from "express";
import type { AdminAuthContext } from "./middleware";
import { HttpError } from "./middleware";

const DEFAULT_BUSINESS_ID = process.env.DEFAULT_BUSINESS_ID || "demo-org";

/**
 * Resolve the business scope for a request.
 * - Business Admin: always locked to their businessId (ignores client tampering).
 * - Super Admin: uses requested businessId; null = cross-business (list all).
 * - No admin auth (mobile apps): legacy businessId / organizationId from query/body.
 */
export function resolveBusinessId(
  req: Request,
  auth: AdminAuthContext | null | undefined
): string | null {
  const requested =
    (req.query.businessId as string) ||
    (req.query.organizationId as string) ||
    (req.body?.businessId as string) ||
    (req.body?.organizationId as string);

  if (!auth) {
    return requested || DEFAULT_BUSINESS_ID;
  }

  if (auth.role === "business_admin") {
    if (!auth.businessId) {
      throw new HttpError("حسابك غير مربوط بشركة.", 403);
    }
    if (requested && requested !== auth.businessId) {
      throw new HttpError("لا يمكنك الوصول لبيانات شركة أخرى.", 403);
    }
    return auth.businessId;
  }

  // super_admin
  return requested || null;
}

export function requireBusinessId(
  req: Request,
  auth: AdminAuthContext | null | undefined
): string {
  const businessId = resolveBusinessId(req, auth);
  if (!businessId) {
    throw new HttpError("حدّد الشركة أولاً.", 400);
  }
  return businessId;
}

/** Add businessId + organizationId (alias) to API responses. */
export function withBusinessId<T extends Record<string, unknown>>(
  businessId: string,
  entity: T
): T & { businessId: string; organizationId: string } {
  return { ...entity, businessId, organizationId: businessId };
}
