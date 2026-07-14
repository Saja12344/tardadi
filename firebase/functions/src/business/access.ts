import type { Firestore } from "firebase-admin/firestore";
import { COLLECTIONS } from "@tardadi/shared";
import type { AdminAuthContext } from "../auth/middleware";
import { HttpError } from "../auth/middleware";
import { resolveBusinessId } from "../auth/scope";

/** List business IDs the caller may access. */
export async function listAccessibleBusinessIds(
  db: Firestore,
  auth: AdminAuthContext | null | undefined,
  requestedBusinessId: string | null
): Promise<string[]> {
  if (requestedBusinessId) return [requestedBusinessId];

  if (auth?.role === "super_admin") {
    const snap = await db.collection(COLLECTIONS.businesses).get();
    return snap.docs.map((d) => d.id);
  }

  if (auth?.role === "business_admin" && auth.businessId) {
    return [auth.businessId];
  }

  if (!auth && requestedBusinessId === null) {
    // Legacy single-tenant
    const resolved = resolveBusinessId({ query: {}, body: {} } as never, null);
    return resolved ? [resolved] : [];
  }

  throw new HttpError("حدّد الشركة أولاً.", 400);
}

export async function mapAcrossBusinesses<T>(
  db: Firestore,
  businessIds: string[],
  mapper: (businessId: string) => Promise<T[]>
): Promise<T[]> {
  const chunks = await Promise.all(businessIds.map(mapper));
  return chunks.flat();
}
