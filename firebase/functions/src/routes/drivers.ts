import { Router } from "express";
import { COLLECTIONS } from "@tardadi/shared";
import { db } from "../firebase";
import { fail, getOrgId, ok } from "../utils";

const router = Router();

router.get("/", async (req, res) => {
  try {
    const orgId = getOrgId(req);
    const snapshot = await db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.drivers)
      .get();

    const drivers = snapshot.docs.map((doc) => ({
      driverId: doc.id,
      organizationId: orgId,
      ...doc.data(),
    }));

    ok(res, drivers);
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

router.get("/me", async (req, res) => {
  try {
    const orgId = getOrgId(req);
    const driverId = req.query.driverId as string;

    if (!driverId) {
      fail(res, "driverId is required");
      return;
    }

    const driverDoc = await db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.drivers)
      .doc(driverId)
      .get();

    if (!driverDoc.exists) {
      fail(res, "Driver not found", 404);
      return;
    }

    const driver = { driverId, organizationId: orgId, ...driverDoc.data() };
    ok(res, driver);
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

router.post("/", async (req, res) => {
  try {
    const orgId = getOrgId(req);
    const {
      driverCode,
      name,
      phone,
      assignedRouteId,
      assignedBusId,
      status = "active",
    } = req.body;

    if (!driverCode || !name) {
      fail(res, "driverCode and name are required");
      return;
    }

    const now = new Date().toISOString();
    const docRef = await db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.drivers)
      .add({
        driverCode,
        name,
        phone: phone || null,
        assignedRouteId: assignedRouteId || null,
        assignedBusId: assignedBusId || null,
        status,
        createdAt: now,
        updatedAt: now,
      });

    ok(
      res,
      {
        driverId: docRef.id,
        organizationId: orgId,
        driverCode,
        name,
        assignedRouteId,
        assignedBusId,
        status,
      },
      201
    );
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

router.put("/:driverId", async (req, res) => {
  try {
    const orgId = getOrgId(req);
    const { driverId } = req.params;
    const updates = { ...req.body, updatedAt: new Date().toISOString() };
    delete updates.organizationId;
    delete updates.driverId;

    await db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.drivers)
      .doc(driverId)
      .update(updates);

    ok(res, { driverId, ...updates });
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

router.delete("/:driverId", async (req, res) => {
  try {
    const orgId = getOrgId(req);
    const { driverId } = req.params;

    await db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.drivers)
      .doc(driverId)
      .delete();

    ok(res, { driverId, deleted: true });
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

export default router;
