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
      .collection(COLLECTIONS.routes)
      .get();

    const routes = snapshot.docs.map((doc) => ({
      routeId: doc.id,
      organizationId: orgId,
      ...doc.data(),
    }));

    ok(res, routes);
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

router.get("/:routeId", async (req, res) => {
  try {
    const orgId = getOrgId(req);
    const { routeId } = req.params;

    const routeRef = db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.routes)
      .doc(routeId);

    const routeDoc = await routeRef.get();
    if (!routeDoc.exists) {
      fail(res, "Route not found", 404);
      return;
    }

    const stopsSnapshot = await routeRef.collection(COLLECTIONS.stops).orderBy("sequenceNo").get();
    const stops = stopsSnapshot.docs.map((doc) => ({
      stopId: doc.id,
      routeId,
      ...doc.data(),
    }));

    ok(res, {
      route: { routeId, organizationId: orgId, ...routeDoc.data() },
      stops,
    });
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

router.post("/", async (req, res) => {
  try {
    const orgId = getOrgId(req);
    const {
      name,
      code,
      colorHex,
      status = "active",
      polyline,
      fromLocation,
      toLocation,
    } = req.body;

    if (!name || !code) {
      fail(res, "name and code are required");
      return;
    }

    if (
      !fromLocation?.address ||
      typeof fromLocation.latitude !== "number" ||
      typeof fromLocation.longitude !== "number"
    ) {
      fail(res, "fromLocation (address, latitude, longitude) is required");
      return;
    }

    if (
      !toLocation?.address ||
      typeof toLocation.latitude !== "number" ||
      typeof toLocation.longitude !== "number"
    ) {
      fail(res, "toLocation (address, latitude, longitude) is required");
      return;
    }

    const now = new Date().toISOString();
    const docRef = await db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.routes)
      .add({
        name,
        code,
        colorHex: colorHex || "#FF6B00",
        status,
        fromLocation,
        toLocation,
        polyline: polyline || null,
        createdAt: now,
        updatedAt: now,
      });

    ok(
      res,
      {
        routeId: docRef.id,
        organizationId: orgId,
        name,
        code,
        colorHex: colorHex || "#FF6B00",
        status,
        fromLocation,
        toLocation,
      },
      201
    );
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

router.put("/:routeId", async (req, res) => {
  try {
    const orgId = getOrgId(req);
    const { routeId } = req.params;
    const updates = { ...req.body, updatedAt: new Date().toISOString() };
    delete updates.organizationId;
    delete updates.routeId;

    await db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.routes)
      .doc(routeId)
      .update(updates);

    ok(res, { routeId, ...updates });
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

router.delete("/:routeId", async (req, res) => {
  try {
    const orgId = getOrgId(req);
    const { routeId } = req.params;

    await db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.routes)
      .doc(routeId)
      .delete();

    ok(res, { routeId, deleted: true });
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

export default router;
