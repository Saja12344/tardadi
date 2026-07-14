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
import { fail, getOrgId, ok } from "../utils";

const router = Router();

async function listTripsForBusiness(businessId: string, status?: string) {
  let query: Query = businessRef(db, businessId).collection(COLLECTIONS.trips);
  if (status) {
    query = query.where("tripStatus", "==", status);
  }
  const snapshot = await query.orderBy("updatedAt", "desc").get();
  return snapshot.docs.map((doc) =>
    withBusinessId(businessId, { tripId: doc.id, ...doc.data() })
  );
}

router.get("/", optionalAdminWithPermission("trips:read"), async (req, res) => {
  try {
    const businessId = resolveBusinessId(req, req.adminAuth);
    const status = req.query.status as string | undefined;
    const businessIds = await listAccessibleBusinessIds(
      db,
      req.adminAuth,
      businessId
    );
    const trips = await mapAcrossBusinesses(db, businessIds, (id) =>
      listTripsForBusiness(id, status)
    );
    ok(res, trips);
  } catch (error) {
    const err = error as Error & { status?: number };
    fail(res, err.message, err.status ?? 500);
  }
});

router.post("/start", async (req, res) => {
  try {
    const businessId = getOrgId(req);
    const { driverId, busId, routeId } = req.body;

    if (!driverId || !busId || !routeId) {
      fail(res, "driverId, busId, and routeId are required");
      return;
    }

    const activeTrips = await businessRef(db, businessId)
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
    const tripRef = await businessRef(db, businessId)
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

    await businessRef(db, businessId)
      .collection(COLLECTIONS.buses)
      .doc(busId)
      .update({
        currentTripId: tripRef.id,
        updatedAt: now,
      });

    ok(
      res,
      withBusinessId(businessId, {
        tripId: tripRef.id,
        busId,
        driverId,
        routeId,
        tripStatus: "active",
        startedAt: now,
      }),
      201
    );
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

router.post("/arrived", async (req, res) => {
  try {
    const businessId = getOrgId(req);
    const { tripId, driverId, stopId } = req.body;

    if (!tripId || !driverId) {
      fail(res, "tripId and driverId are required");
      return;
    }

    const tripRef = businessRef(db, businessId)
      .collection(COLLECTIONS.trips)
      .doc(tripId);

    const tripDoc = await tripRef.get();
    if (!tripDoc.exists) {
      fail(res, "Trip not found", 404);
      return;
    }

    const trip = tripDoc.data()!;
    if (trip.tripStatus !== "active") {
      fail(res, "Trip is not active", 400);
      return;
    }

    if (trip.driverId !== driverId) {
      fail(res, "Trip does not belong to this driver", 403);
      return;
    }

    const now = new Date().toISOString();
    const arrival = {
      lastArrivedAt: now,
      lastArrivedStopId: stopId ?? null,
      updatedAt: now,
    };

    await tripRef.update(arrival);

    await businessRef(db, businessId)
      .collection(COLLECTIONS.buses)
      .doc(trip.busId as string)
      .update(arrival);

    ok(res, { tripId, arrivedAt: now, stopId: stopId ?? null });
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

router.post("/end", async (req, res) => {
  try {
    const businessId = getOrgId(req);
    const { tripId, driverId } = req.body;

    if (!tripId || !driverId) {
      fail(res, "tripId and driverId are required");
      return;
    }

    const tripRef = businessRef(db, businessId)
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

    await businessRef(db, businessId)
      .collection(COLLECTIONS.buses)
      .doc(tripData.busId as string)
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
