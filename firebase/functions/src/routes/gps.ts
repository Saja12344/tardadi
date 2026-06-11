import { Router } from "express";
import { COLLECTIONS, isWithinGeofence } from "@tardadi/shared";
import type { GeoPoint } from "@tardadi/shared";
import { db } from "../firebase";
import { fail, getOrgId, ok } from "../utils";

const router = Router();

router.post("/", async (req, res) => {
  try {
    const orgId = getOrgId(req);
    const { tripId, driverId, busId, latitude, longitude, speedKmh, heading } =
      req.body;

    if (
      !tripId ||
      !driverId ||
      !busId ||
      latitude === undefined ||
      longitude === undefined
    ) {
      fail(res, "tripId, driverId, busId, latitude, and longitude are required");
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

    const trip = tripDoc.data()!;
    if (trip.tripStatus !== "active") {
      fail(res, "Trip is not active", 400);
      return;
    }

    if (trip.driverId !== driverId || trip.busId !== busId) {
      fail(res, "Trip does not match driver or bus", 403);
      return;
    }

    const stopsSnapshot = await db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.routes)
      .doc(trip.routeId)
      .collection(COLLECTIONS.stops)
      .get();

    const stopPoints: GeoPoint[] = stopsSnapshot.docs.map((doc) => {
      const data = doc.data();
      return { latitude: data.latitude, longitude: data.longitude };
    });

    const currentPoint: GeoPoint = { latitude, longitude };
    if (!isWithinGeofence(currentPoint, stopPoints)) {
      fail(res, "Location outside allowed route geofence", 403);
      return;
    }

    const now = new Date().toISOString();
    const gpsRef = await tripRef.collection(COLLECTIONS.gpsLogs).add({
      latitude,
      longitude,
      speedKmh: speedKmh ?? null,
      heading: heading ?? null,
      capturedAt: now,
    });

    await db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.buses)
      .doc(busId)
      .update({
        currentLocation: { latitude, longitude },
        lastSeenAt: now,
        updatedAt: now,
      });

    await tripRef.update({ updatedAt: now });

    ok(res, {
      gpsLogId: gpsRef.id,
      tripId,
      latitude,
      longitude,
      capturedAt: now,
    }, 201);
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

export default router;
