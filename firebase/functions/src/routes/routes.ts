import { Router } from "express";
import { COLLECTIONS, totalStationCount } from "@tardadi/shared";
import { db } from "../firebase";
import { fail, getOrgId, ok } from "../utils";

const router = Router();

const LIVE_GPS_WINDOW_MS = 60_000;

function isRecentlyUpdated(lastSeenAt: string | null | undefined): boolean {
  if (!lastSeenAt) return false;
  const seen = new Date(lastSeenAt).getTime();
  if (Number.isNaN(seen)) return false;
  return Date.now() - seen <= LIVE_GPS_WINDOW_MS;
}

router.get("/", async (req, res) => {
  try {
    const orgId = getOrgId(req);
    const orgRef = db.collection(COLLECTIONS.organizations).doc(orgId);

    const [routesSnapshot, tripsSnapshot, busesSnapshot] = await Promise.all([
      orgRef.collection(COLLECTIONS.routes).get(),
      orgRef.collection(COLLECTIONS.trips).where("tripStatus", "==", "active").get(),
      orgRef.collection(COLLECTIONS.buses).get(),
    ]);

    const busById = new Map(
      busesSnapshot.docs.map((doc) => [
        doc.id,
        { busId: doc.id, ...doc.data() } as { busId: string; lastSeenAt?: string },
      ])
    );

    const activeTripsByRoute = new Map<string, typeof tripsSnapshot.docs>();
    for (const tripDoc of tripsSnapshot.docs) {
      const routeId = tripDoc.data().routeId as string;
      const list = activeTripsByRoute.get(routeId) ?? [];
      list.push(tripDoc);
      activeTripsByRoute.set(routeId, list);
    }

    const routes = await Promise.all(
      routesSnapshot.docs.map(async (doc) => {
        const routeId = doc.id;
        const stopsSnapshot = await doc.ref.collection(COLLECTIONS.stops).get();
        const activeTrips = activeTripsByRoute.get(routeId) ?? [];
        let liveBusCount = 0;

        for (const tripDoc of activeTrips) {
          const busId = tripDoc.data().busId as string;
          const bus = busById.get(busId);
          if (bus && isRecentlyUpdated(bus.lastSeenAt as string | undefined)) {
            liveBusCount += 1;
          }
        }

        const routeData = doc.data();
        const intermediateStops = stopsSnapshot.size;

        return {
          routeId,
          organizationId: orgId,
          ...routeData,
          stopsCount: totalStationCount(intermediateStops, {
            hasFrom: !!routeData.fromLocation,
            hasTo: !!routeData.toLocation,
          }),
          intermediateStopsCount: intermediateStops,
          activeBusCount: activeTrips.length,
          liveBusCount,
        };
      })
    );

    ok(res, routes);
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

router.get("/:routeId/live", async (req, res) => {
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

    const [stopsSnapshot, tripsSnapshot] = await Promise.all([
      routeRef.collection(COLLECTIONS.stops).orderBy("sequenceNo").get(),
      db
        .collection(COLLECTIONS.organizations)
        .doc(orgId)
        .collection(COLLECTIONS.trips)
        .where("routeId", "==", routeId)
        .where("tripStatus", "==", "active")
        .get(),
    ]);

    const stops = stopsSnapshot.docs.map((doc) => ({
      stopId: doc.id,
      routeId,
      ...doc.data(),
    }));

    const buses = [];
    let liveBusCount = 0;

    for (const tripDoc of tripsSnapshot.docs) {
      const trip = tripDoc.data();
      const busDoc = await db
        .collection(COLLECTIONS.organizations)
        .doc(orgId)
        .collection(COLLECTIONS.buses)
        .doc(trip.busId as string)
        .get();

      if (!busDoc.exists) continue;

      const busData = busDoc.data()!;
      const isLive = isRecentlyUpdated(busData.lastSeenAt as string | undefined);
      if (isLive) liveBusCount += 1;

      buses.push({
        busId: busDoc.id,
        organizationId: orgId,
        ...busData,
        tripId: tripDoc.id,
        lastArrivedAt:
          (trip.lastArrivedAt as string | undefined) ??
          (busData.lastArrivedAt as string | undefined) ??
          null,
        lastArrivedStopId:
          (trip.lastArrivedStopId as string | undefined) ??
          (busData.lastArrivedStopId as string | undefined) ??
          null,
        isLive,
      });
    }

    ok(res, {
      route: {
        routeId,
        organizationId: orgId,
        ...routeDoc.data(),
        stopsCount: totalStationCount(stops.length, {
          hasFrom: !!routeDoc.data()?.fromLocation,
          hasTo: !!routeDoc.data()?.toLocation,
        }),
        intermediateStopsCount: stops.length,
      },
      stops,
      buses,
      liveBusCount,
      activeBusCount: tripsSnapshot.size,
    });
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

    const routeData = routeDoc.data()!;
    const intermediateStops = stopsSnapshot.size;

    ok(res, {
      route: {
        routeId,
        organizationId: orgId,
        ...routeData,
        stopsCount: totalStationCount(intermediateStops, {
          hasFrom: !!routeData.fromLocation,
          hasTo: !!routeData.toLocation,
        }),
        intermediateStopsCount: intermediateStops,
      },
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
      accessMode = "public",
      polyline,
      fromLocation,
      toLocation,
      stops = [],
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
        accessMode: accessMode === "private" ? "private" : "public",
        fromLocation,
        toLocation,
        polyline: polyline || null,
        createdAt: now,
        updatedAt: now,
      });

    if (Array.isArray(stops) && stops.length > 0) {
      const batch = db.batch();
      stops.forEach((stop: Record<string, unknown>, index: number) => {
        if (
          typeof stop.latitude !== "number" ||
          typeof stop.longitude !== "number"
        ) {
          return;
        }
        const stopRef = docRef.collection(COLLECTIONS.stops).doc();
        batch.set(stopRef, {
          name: (stop.name as string) || `محطة ${index + 1}`,
          latitude: stop.latitude,
          longitude: stop.longitude,
          sequenceNo: (stop.sequenceNo as number) ?? index + 1,
          geofenceRadiusM: 500,
          status: "active",
          createdAt: now,
          updatedAt: now,
        });
      });
      await batch.commit();
    }

    ok(
      res,
      {
        routeId: docRef.id,
        organizationId: orgId,
        name,
        code,
        colorHex: colorHex || "#FF6B00",
        status,
        accessMode: accessMode === "private" ? "private" : "public",
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
