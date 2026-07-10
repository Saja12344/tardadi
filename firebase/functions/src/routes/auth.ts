import { Router } from "express";
import { COLLECTIONS, normalizePhone } from "@tardadi/shared";
import type { Driver, Bus, Route, Stop } from "@tardadi/shared";
import { db } from "../firebase";
import { fail, getOrgId, ok } from "../utils";

const router = Router();

router.post("/driver-login", async (req, res) => {
  try {
    const orgId = getOrgId(req);
    const { phone } = req.body;

    if (!phone) {
      fail(res, "phone is required");
      return;
    }

    const normalizedPhone = normalizePhone(phone);

    const driversSnapshot = await db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.drivers)
      .where("phone", "==", normalizedPhone)
      .where("status", "==", "active")
      .limit(1)
      .get();

    if (driversSnapshot.empty) {
      fail(res, "رقم الجوال غير مسجل. تواصل مع الإدارة.", 401);
      return;
    }

    const driverDoc = driversSnapshot.docs[0];
    const driverData = driverDoc.data();
    const driver: Driver = {
      driverId: driverDoc.id,
      organizationId: orgId,
      name: driverData.name,
      phone: driverData.phone,
      driverCode: driverData.driverCode,
      assignedRouteId: driverData.assignedRouteId,
      assignedBusId: driverData.assignedBusId,
      status: driverData.status,
    };

    if (!driver.assignedRouteId || !driver.assignedBusId) {
      fail(res, "لم يتم تعيين خط أو باص لك بعد. تواصل مع الإدارة.", 403);
      return;
    }

    const busDoc = await db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.buses)
      .doc(driver.assignedBusId)
      .get();

    if (!busDoc.exists) {
      fail(res, "الباص المعيّن غير موجود", 404);
      return;
    }

    const bus: Bus = {
      busId: busDoc.id,
      organizationId: orgId,
      ...(busDoc.data() as Omit<Bus, "busId" | "organizationId">),
    };

    const routeDoc = await db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.routes)
      .doc(driver.assignedRouteId)
      .get();

    if (!routeDoc.exists) {
      fail(res, "الخط المعيّن غير موجود", 404);
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

    const activeTripSnapshot = await db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.trips)
      .where("busId", "==", driver.assignedBusId)
      .where("tripStatus", "==", "active")
      .limit(1)
      .get();

    const tripId = activeTripSnapshot.empty
      ? null
      : activeTripSnapshot.docs[0].id;

    ok(res, { driver, bus, route, stops, tripId });
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

export default router;
