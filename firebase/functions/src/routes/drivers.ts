import { Router } from "express";
import { COLLECTIONS, normalizePhone } from "@tardadi/shared";
import { db } from "../firebase";
import { optionalAdminWithPermission } from "../auth/middleware";
import { resolveBusinessId, requireBusinessId, withBusinessId } from "../auth/scope";
import {
  listAccessibleBusinessIds,
  mapAcrossBusinesses,
} from "../business/access";
import { businessRef } from "../business/helpers";
import { fail, ok, paramId } from "../utils";

const router = Router();

async function listDriversForBusiness(businessId: string) {
  const snapshot = await businessRef(db, businessId)
    .collection(COLLECTIONS.drivers)
    .get();

  return snapshot.docs.map((doc) =>
    withBusinessId(businessId, {
      driverId: doc.id,
      ...doc.data(),
    })
  );
}

router.get("/", optionalAdminWithPermission("drivers:read"), async (req, res) => {
  try {
    const businessId = resolveBusinessId(req, req.adminAuth);
    const businessIds = await listAccessibleBusinessIds(
      db,
      req.adminAuth,
      businessId
    );
    const drivers = await mapAcrossBusinesses(db, businessIds, listDriversForBusiness);
    ok(res, drivers);
  } catch (error) {
    const err = error as Error & { status?: number };
    fail(res, err.message, err.status ?? 500);
  }
});

router.get("/me", async (req, res) => {
  try {
    const businessId = resolveBusinessId(req, req.adminAuth);
    if (!businessId) {
      fail(res, "حدّد الشركة أولاً.");
      return;
    }

    const driverId = req.query.driverId as string;
    if (!driverId) {
      fail(res, "driverId is required");
      return;
    }

    const driverDoc = await businessRef(db, businessId)
      .collection(COLLECTIONS.drivers)
      .doc(driverId)
      .get();

    if (!driverDoc.exists) {
      fail(res, "Driver not found", 404);
      return;
    }

    ok(
      res,
      withBusinessId(businessId, {
        driverId,
        ...driverDoc.data(),
      })
    );
  } catch (error) {
    const err = error as Error & { status?: number };
    fail(res, err.message, err.status ?? 500);
  }
});

router.post("/", optionalAdminWithPermission("drivers:write"), async (req, res) => {
  try {
    const businessId = requireBusinessId(req, req.adminAuth);
    const {
      name,
      phone,
      assignedRouteId,
      assignedBusId,
      status = "active",
    } = req.body;

    if (!name || !phone) {
      fail(res, "name and phone are required");
      return;
    }

    const normalizedPhone = normalizePhone(phone);

    const existing = await businessRef(db, businessId)
      .collection(COLLECTIONS.drivers)
      .where("phone", "==", normalizedPhone)
      .limit(1)
      .get();

    if (!existing.empty) {
      fail(res, "رقم الجوال مسجل مسبقاً", 409);
      return;
    }

    const now = new Date().toISOString();
    const docRef = await businessRef(db, businessId)
      .collection(COLLECTIONS.drivers)
      .add({
        name,
        phone: normalizedPhone,
        driverCode: null,
        assignedRouteId: assignedRouteId || null,
        assignedBusId: assignedBusId || null,
        status,
        createdAt: now,
        updatedAt: now,
      });

    ok(
      res,
      withBusinessId(businessId, {
        driverId: docRef.id,
        name,
        phone: normalizedPhone,
        assignedRouteId,
        assignedBusId,
        status,
      }),
      201
    );
  } catch (error) {
    const err = error as Error & { status?: number };
    fail(res, err.message, err.status ?? 500);
  }
});

router.put("/:driverId", optionalAdminWithPermission("drivers:write"), async (req, res) => {
  try {
    const businessId = requireBusinessId(req, req.adminAuth);
    const { driverId: rawDriverId } = req.params;
    const driverId = paramId(rawDriverId);
    const updates = { ...req.body, updatedAt: new Date().toISOString() };
    delete updates.organizationId;
    delete updates.businessId;
    delete updates.driverId;

    if (updates.phone) {
      updates.phone = normalizePhone(updates.phone);
    }

    await businessRef(db, businessId)
      .collection(COLLECTIONS.drivers)
      .doc(driverId)
      .update(updates);

    ok(res, withBusinessId(businessId, { driverId, ...updates }));
  } catch (error) {
    const err = error as Error & { status?: number };
    fail(res, err.message, err.status ?? 500);
  }
});

router.delete("/:driverId", optionalAdminWithPermission("drivers:write"), async (req, res) => {
  try {
    const businessId = requireBusinessId(req, req.adminAuth);
    const { driverId: rawDriverId } = req.params;
    const driverId = paramId(rawDriverId);

    await businessRef(db, businessId)
      .collection(COLLECTIONS.drivers)
      .doc(driverId)
      .delete();

    ok(res, { driverId, deleted: true });
  } catch (error) {
    const err = error as Error & { status?: number };
    fail(res, err.message, err.status ?? 500);
  }
});

export default router;
