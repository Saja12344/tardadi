import { Router } from "express";
import { COLLECTIONS } from "@tardadi/shared";
import { db } from "../firebase";
import { fail, getOrgId, ok } from "../utils";

const router = Router();

router.get("/", async (req, res) => {
  try {
    const orgId = getOrgId(req);
    const activeOnly = req.query.active === "true";

    let query: FirebaseFirestore.Query = db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.buses);

    if (activeOnly) {
      query = query.where("status", "==", "active");
    }

    const snapshot = await query.get();
    const buses = snapshot.docs.map((doc) => ({
      busId: doc.id,
      organizationId: orgId,
      ...doc.data(),
    }));

    ok(res, buses);
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

router.post("/", async (req, res) => {
  try {
    const orgId = getOrgId(req);
    const { plateNo, label, status = "active" } = req.body;

    if (!plateNo || !label) {
      fail(res, "plateNo and label are required");
      return;
    }

    const now = new Date().toISOString();
    const docRef = await db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
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

    ok(res, { busId: docRef.id, organizationId: orgId, plateNo, label, status }, 201);
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

router.put("/:busId", async (req, res) => {
  try {
    const orgId = getOrgId(req);
    const { busId } = req.params;
    const updates = { ...req.body, updatedAt: new Date().toISOString() };
    delete updates.organizationId;
    delete updates.busId;

    await db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.buses)
      .doc(busId)
      .update(updates);

    ok(res, { busId, ...updates });
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

router.delete("/:busId", async (req, res) => {
  try {
    const orgId = getOrgId(req);
    const { busId } = req.params;

    await db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.buses)
      .doc(busId)
      .delete();

    ok(res, { busId, deleted: true });
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

export default router;
