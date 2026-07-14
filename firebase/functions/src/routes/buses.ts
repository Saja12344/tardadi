import { Router } from "express";
import type { Query } from "firebase-admin/firestore";
import { COLLECTIONS } from "@tardadi/shared";
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

async function listBusesForBusiness(
  businessId: string,
  activeOnly: boolean
) {
  let query: Query = businessRef(db, businessId).collection(COLLECTIONS.buses);
  if (activeOnly) {
    query = query.where("status", "==", "active");
  }
  const snapshot = await query.get();
  return snapshot.docs.map((doc) =>
    withBusinessId(businessId, { busId: doc.id, ...doc.data() })
  );
}

router.get("/", optionalAdminWithPermission("buses:read"), async (req, res) => {
  try {
    const businessId = resolveBusinessId(req, req.adminAuth);
    const activeOnly = req.query.active === "true";
    const businessIds = await listAccessibleBusinessIds(
      db,
      req.adminAuth,
      businessId
    );
    const buses = await mapAcrossBusinesses(db, businessIds, (id) =>
      listBusesForBusiness(id, activeOnly)
    );
    ok(res, buses);
  } catch (error) {
    const err = error as Error & { status?: number };
    fail(res, err.message, err.status ?? 500);
  }
});

router.post("/", optionalAdminWithPermission("buses:write"), async (req, res) => {
  try {
    const businessId = requireBusinessId(req, req.adminAuth);
    const { plateNo, label, status = "active" } = req.body;

    if (!plateNo || !label) {
      fail(res, "plateNo and label are required");
      return;
    }

    const now = new Date().toISOString();
    const docRef = await businessRef(db, businessId)
      .collection(COLLECTIONS.buses)
      .add({
        plateNo,
        label,
        status,
        currentTripId: null,
        currentLocation: null,
        lastSeenAt: null,
        createdAt: now,
        updatedAt: now,
      });

    ok(
      res,
      withBusinessId(businessId, { busId: docRef.id, plateNo, label, status }),
      201
    );
  } catch (error) {
    const err = error as Error & { status?: number };
    fail(res, err.message, err.status ?? 500);
  }
});

router.put("/:busId", optionalAdminWithPermission("buses:write"), async (req, res) => {
  try {
    const businessId = requireBusinessId(req, req.adminAuth);
    const busId = paramId(req.params.busId);
    const updates = { ...req.body, updatedAt: new Date().toISOString() };
    delete updates.organizationId;
    delete updates.businessId;
    delete updates.busId;

    await businessRef(db, businessId)
      .collection(COLLECTIONS.buses)
      .doc(busId)
      .update(updates);

    ok(res, withBusinessId(businessId, { busId, ...updates }));
  } catch (error) {
    const err = error as Error & { status?: number };
    fail(res, err.message, err.status ?? 500);
  }
});

router.delete("/:busId", optionalAdminWithPermission("buses:write"), async (req, res) => {
  try {
    const businessId = requireBusinessId(req, req.adminAuth);
    const busId = paramId(req.params.busId);

    await businessRef(db, businessId)
      .collection(COLLECTIONS.buses)
      .doc(busId)
      .delete();

    ok(res, { busId, deleted: true });
  } catch (error) {
    const err = error as Error & { status?: number };
    fail(res, err.message, err.status ?? 500);
  }
});

export default router;
