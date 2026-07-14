import { Router } from "express";
import {
  COLLECTIONS,
  normalizePhone,
  type Business,
  type BusinessListItem,
  type BusinessStats,
  type CreateBusinessRequest,
  type UpdateBusinessRequest,
} from "@tardadi/shared";
import { db } from "../firebase";
import { hashPassword } from "../auth/crypto";
import {
  requirePermission,
  requireSuperAdmin,
} from "../auth/middleware";
import { businessRef, getBusinessStats } from "../business/helpers";
import { fail, ok, paramId } from "../utils";

const router = Router();

async function loadAdminSummary(adminUserId: string | null | undefined) {
  if (!adminUserId) return { adminName: null, adminPhone: null };
  const doc = await db.collection(COLLECTIONS.adminUsers).doc(adminUserId).get();
  if (!doc.exists) return { adminName: null, adminPhone: null };
  const data = doc.data()!;
  return { adminName: data.name as string, adminPhone: data.phone as string };
}

router.get(
  "/",
  requirePermission("businesses:read"),
  async (_req, res) => {
    try {
      const snapshot = await db.collection(COLLECTIONS.businesses).get();
      const items: BusinessListItem[] = await Promise.all(
        snapshot.docs.map(async (doc) => {
          const data = doc.data();
          const businessId = doc.id;
          const [stats, admin] = await Promise.all([
            getBusinessStats(db, businessId),
            loadAdminSummary(data.adminUserId as string | undefined),
          ]);

          return {
            businessId,
            name: data.name as string,
            logo: (data.logo as string | null) ?? null,
            status: data.status as Business["status"],
            adminUserId: (data.adminUserId as string | null) ?? null,
            createdAt: data.createdAt as string | undefined,
            updatedAt: data.updatedAt as string | undefined,
            ...admin,
            driverCount: stats.driverCount,
            busCount: stats.busCount,
            routeCount: stats.routeCount,
            stationCount: stats.stationCount,
          };
        })
      );

      ok(res, items);
    } catch (error) {
      fail(res, (error as Error).message, 500);
    }
  }
);

router.get(
  "/:businessId",
  requirePermission("businesses:read", "drivers:read"),
  async (req, res) => {
    try {
      const businessId = paramId(req.params.businessId);
      const auth = req.adminAuth!;

      if (
        auth.role === "business_admin" &&
        auth.businessId !== businessId
      ) {
        fail(res, "لا يمكنك الوصول لبيانات شركة أخرى.", 403);
        return;
      }

      const doc = await businessRef(db, businessId).get();
      if (!doc.exists) {
        fail(res, "لم نجد هذه الشركة.", 404);
        return;
      }

      const data = doc.data()!;
      const admin = await loadAdminSummary(data.adminUserId as string | undefined);
      const stats = await getBusinessStats(db, businessId);

      ok(res, {
        businessId,
        name: data.name,
        logo: data.logo ?? null,
        status: data.status,
        adminUserId: data.adminUserId ?? null,
        createdAt: data.createdAt,
        updatedAt: data.updatedAt,
        ...admin,
        stats,
      });
    } catch (error) {
      fail(res, (error as Error).message, 500);
    }
  }
);

router.get(
  "/:businessId/stats",
  requirePermission("businesses:read", "drivers:read", "stats:read_all"),
  async (req, res) => {
    try {
      const businessId = paramId(req.params.businessId);
      const auth = req.adminAuth!;

      if (
        auth.role === "business_admin" &&
        auth.businessId !== businessId
      ) {
        fail(res, "لا يمكنك الوصول لبيانات شركة أخرى.", 403);
        return;
      }

      const doc = await businessRef(db, businessId).get();
      if (!doc.exists) {
        fail(res, "لم نجد هذه الشركة.", 404);
        return;
      }

      const stats: BusinessStats = await getBusinessStats(db, businessId);
      ok(res, stats);
    } catch (error) {
      fail(res, (error as Error).message, 500);
    }
  }
);

router.post("/", requireSuperAdmin, async (req, res) => {
  try {
    const body = req.body as CreateBusinessRequest;
    const {
      name,
      logo = null,
      status = "active",
      adminName,
      adminPhone,
      adminPassword,
    } = body;

    if (!name?.trim()) {
      fail(res, "اكتب اسم الشركة.");
      return;
    }
    if (!adminName?.trim() || !adminPhone?.trim() || !adminPassword?.trim()) {
      fail(res, "اكتب اسم المدير ورقم جواله وكلمة المرور.");
      return;
    }

    const normalizedPhone = normalizePhone(adminPhone);
    const existingAdmin = await db
      .collection(COLLECTIONS.adminUsers)
      .where("phone", "==", normalizedPhone)
      .limit(1)
      .get();

    if (!existingAdmin.empty) {
      fail(res, "رقم جوال المدير مسجّل مسبقاً.", 409);
      return;
    }

    const now = new Date().toISOString();
    const businessDoc = await db.collection(COLLECTIONS.businesses).add({
      name: name.trim(),
      logo,
      status,
      adminUserId: null,
      createdAt: now,
      updatedAt: now,
    });

    const adminRef = await db.collection(COLLECTIONS.adminUsers).add({
      name: adminName.trim(),
      phone: normalizedPhone,
      passwordHash: hashPassword(adminPassword),
      role: "business_admin",
      businessId: businessDoc.id,
      status: "active",
      createdAt: now,
      updatedAt: now,
    });

    await businessDoc.update({
      adminUserId: adminRef.id,
      updatedAt: now,
    });

    ok(
      res,
      {
        businessId: businessDoc.id,
        name: name.trim(),
        logo,
        status,
        adminUserId: adminRef.id,
        adminName: adminName.trim(),
        adminPhone: normalizedPhone,
        createdAt: now,
        updatedAt: now,
      },
      201
    );
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

router.put("/:businessId", requireSuperAdmin, async (req, res) => {
  try {
    const businessId = paramId(req.params.businessId);
    const body = req.body as UpdateBusinessRequest;
    const docRef = businessRef(db, businessId);
    const doc = await docRef.get();

    if (!doc.exists) {
      fail(res, "لم نجد هذه الشركة.", 404);
      return;
    }

    const now = new Date().toISOString();
    const updates: Record<string, unknown> = { updatedAt: now };

    if (body.name !== undefined) updates.name = body.name.trim();
    if (body.logo !== undefined) updates.logo = body.logo;
    if (body.status !== undefined) updates.status = body.status;

    await docRef.update(updates);

    const data = doc.data()!;
    const adminUserId = data.adminUserId as string | null;

    if (
      adminUserId &&
      (body.adminName || body.adminPhone || body.adminPassword)
    ) {
      const adminUpdates: Record<string, unknown> = { updatedAt: now };
      if (body.adminName) adminUpdates.name = body.adminName.trim();
      if (body.adminPassword) {
        adminUpdates.passwordHash = hashPassword(body.adminPassword);
      }
      if (body.adminPhone) {
        const normalizedPhone = normalizePhone(body.adminPhone);
        const duplicate = await db
          .collection(COLLECTIONS.adminUsers)
          .where("phone", "==", normalizedPhone)
          .get();
        const taken = duplicate.docs.some((d) => d.id !== adminUserId);
        if (taken) {
          fail(res, "رقم جوال المدير مسجّل مسبقاً.", 409);
          return;
        }
        adminUpdates.phone = normalizedPhone;
      }
      await db.collection(COLLECTIONS.adminUsers).doc(adminUserId).update(adminUpdates);
    }

    ok(res, { businessId, ...updates });
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

router.patch("/:businessId/disable", requireSuperAdmin, async (req, res) => {
  try {
    const businessId = paramId(req.params.businessId);
    const docRef = businessRef(db, businessId);
    const doc = await docRef.get();
    if (!doc.exists) {
      fail(res, "لم نجد هذه الشركة.", 404);
      return;
    }

    const now = new Date().toISOString();
    await docRef.update({ status: "inactive", updatedAt: now });

    const adminUserId = doc.data()?.adminUserId as string | undefined;
    if (adminUserId) {
      await db
        .collection(COLLECTIONS.adminUsers)
        .doc(adminUserId)
        .update({ status: "inactive", updatedAt: now });
    }

    ok(res, { businessId, status: "inactive" });
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

router.delete("/:businessId", requireSuperAdmin, async (req, res) => {
  try {
    const businessId = paramId(req.params.businessId);
    const docRef = businessRef(db, businessId);
    const doc = await docRef.get();
    if (!doc.exists) {
      fail(res, "لم نجد هذه الشركة.", 404);
      return;
    }

    const adminUserId = doc.data()?.adminUserId as string | undefined;
    if (adminUserId) {
      await db.collection(COLLECTIONS.adminUsers).doc(adminUserId).delete();
    }

    await docRef.delete();
    ok(res, { businessId, deleted: true });
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

export default router;
