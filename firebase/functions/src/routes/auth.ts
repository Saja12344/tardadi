import { Router } from "express";
import { COLLECTIONS } from "@tardadi/shared";
import type { Driver, Bus, Route, Stop } from "@tardadi/shared";
import { db } from "../firebase";
import { fail, getOrgId, ok } from "../utils";

const router = Router();

router.post("/driver-login", async (req, res) => {
  try {
    const orgId = getOrgId(req);
    const { driverCode, busId } = req.body;

    if (!driverCode || !busId) {
      fail(res, "driverCode and busId are required");
      return;
    }

    const driversSnapshot = await db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.drivers)
      .where("driverCode", "==", driverCode)
      .where("status", "==", "active")
      .limit(1)
      .get();

    if (driversSnapshot.empty) {
      fail(res, "Invalid driver code", 401);
      return;
    }

    const driverDoc = driversSnapshot.docs[0];
    const driverData = driverDoc.data();
    const driver: Driver = {
      driverId: driverDoc.id,
      organizationId: orgId,
      driverCode: driverData.driverCode,
      name: driverData.name,
      phone: driverData.phone,
      assignedRouteId: driverData.assignedRouteId,
      assignedBusId: driverData.assignedBusId,
      status: driverData.status,
    };

    if (driver.assignedBusId && driver.assignedBusId !== busId) {
      fail(res, "Bus not assigned to this driver", 403);
      return;
    }

    const busDoc = await db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.buses)
      .doc(busId)
      .get();

    if (!busDoc.exists) {
      fail(res, "Bus not found", 404);
      return;
    }

    const bus: Bus = {
      busId: busDoc.id,
      organizationId: orgId,
      ...(busDoc.data() as Omit<Bus, "busId" | "organizationId">),
    };

    if (!driver.assignedRouteId) {
      fail(res, "Driver has no assigned route", 403);
      return;
    }

    const routeDoc = await db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.routes)
      .doc(driver.assignedRouteId)
      .get();

    if (!routeDoc.exists) {
      fail(res, "Assigned route not found", 404);
      return;
    }

    const route: Route = {
      routeId: routeDoc.id,
      organizationId: orgId,
      ...(routeDoc.data() as Omit<Route, "routeId" | "organizationId">),
    };

    const stopsSnapshot = await routeDoc.ref
      .collection(COLLECTIONS.stops)
      .orderBy("sequenceNo")
      .get();

    const stops: Stop[] = stopsSnapshot.docs.map((doc) => ({
      stopId: doc.id,
      routeId: route.routeId,
      ...(doc.data() as Omit<Stop, "stopId" | "routeId">),
    }));

    ok(res, { driver, bus, route, stops });
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

export default router;
