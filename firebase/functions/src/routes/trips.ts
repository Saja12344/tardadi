import { Router } from "express";
import { COLLECTIONS } from "@tardadi/shared";
import { db } from "../firebase";
import { fail, getOrgId, ok } from "../utils";

const router = Router();

router.get("/", async (req, res) => {
  try {
    const orgId = getOrgId(req);
    const status = req.query.status as string | undefined;

    let query: FirebaseFirestore.Query = db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.trips);

    if (status) {
      query = query.where("tripStatus", "==", status);
    }

    const snapshot = await query.orderBy("updatedAt", "desc").get();
    const trips = snapshot.docs.map((doc) => ({
      tripId: doc.id,
      organizationId: orgId,
      ...doc.data(),
    }));

    ok(res, trips);
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

router.post("/start", async (req, res) => {
  try {
    const orgId = getOrgId(req);
    const { driverId, busId, routeId } = req.body;

    if (!driverId || !busId || !routeId) {
      fail(res, "driverId, busId, and routeId are required");
      return;
    }

    const activeTrips = await db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.trips)
      .where("busId", "==", busId)
      .where("tripStatus", "==", "active")
      .limit(1)
      .get();

    if (!activeTrips.empty) {
      fail(res, "Bus already has an active trip", 409);
      return;
    }

    const now = new Date().toISOString();
    const tripRef = await db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.trips)
      .add({
        busId,
        driverId,
        routeId,
        tripStatus: "active",
        startedAt: now,
        endedAt: null,
        createdAt: now,
        updatedAt: now,
      });

    await db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.buses)
      .doc(busId)
      .update({
        currentTripId: tripRef.id,
        updatedAt: now,
      });

    ok(res, {
      tripId: tripRef.id,
      organizationId: orgId,
      busId,
      driverId,
      routeId,
      tripStatus: "active",
      startedAt: now,
    }, 201);
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

router.post("/end", async (req, res) => {
  try {
    const orgId = getOrgId(req);
    const { tripId, driverId } = req.body;

    if (!tripId || !driverId) {
      fail(res, "tripId and driverId are required");
      return;
    }

    const tripRef = db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.trips)
      .doc(tripId);

    const tripDoc = await tripRef.get();
    if (!tripDoc.exists) {
      fail(res, "Trip not found", 404);
      return;
    }

    const tripData = tripDoc.data()!;
    if (tripData.driverId !== driverId) {
      fail(res, "Trip does not belong to this driver", 403);
      return;
    }

    const now = new Date().toISOString();
    await tripRef.update({
      tripStatus: "ended",
      endedAt: now,
      updatedAt: now,
    });

    await db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.buses)
      .doc(tripData.busId)
      .update({
        currentTripId: null,
        updatedAt: now,
      });

    ok(res, { tripId, tripStatus: "ended", endedAt: now });
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

export default router;
