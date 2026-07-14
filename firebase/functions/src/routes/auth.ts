import { Router } from "express";
import { COLLECTIONS, normalizePhone } from "@tardadi/shared";
import type { Driver, Bus, Route, Stop } from "@tardadi/shared";
import { db } from "../firebase";
import { getJwtSecret, signJwt, verifyPassword } from "../auth/crypto";
import { fail, getOrgId, ok } from "../utils";
import { withBusinessId } from "../auth/scope";

const router = Router();

router.post("/admin-login", async (req, res) => {
  try {
    const { phone, password } = req.body;

    if (!phone || !password) {
      fail(res, "اكتب رقم الجوال وكلمة المرور.");
      return;
    }

    const normalizedPhone = normalizePhone(phone);
    const snapshot = await db
      .collection(COLLECTIONS.adminUsers)
      .where("phone", "==", normalizedPhone)
      .where("status", "==", "active")
      .limit(1)
      .get();

    if (snapshot.empty) {
      fail(res, "رقم الجوال أو كلمة المرور غير صحيحة.", 401);
      return;
    }

    const userDoc = snapshot.docs[0];
    const userData = userDoc.data();

    if (!verifyPassword(password, userData.passwordHash as string)) {
      fail(res, "رقم الجوال أو كلمة المرور غير صحيحة.", 401);
      return;
    }

    if (userData.role === "business_admin" && userData.businessId) {
      const businessDoc = await db
        .collection(COLLECTIONS.businesses)
        .doc(userData.businessId as string)
        .get();
      if (!businessDoc.exists || businessDoc.data()?.status !== "active") {
        fail(res, "شركتك معطّلة. تواصل مع مدير النظام.", 403);
        return;
      }
    }

    const user = {
      userId: userDoc.id,
      name: userData.name as string,
      phone: userData.phone as string,
      role: userData.role as "super_admin" | "business_admin",
      businessId: (userData.businessId as string | null) ?? null,
    };

    const token = signJwt(
      {
        sub: user.userId,
        role: user.role,
        businessId: user.businessId,
        name: user.name,
        phone: user.phone,
      },
      getJwtSecret()
    );

    ok(res, { token, user });
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

router.post("/driver-login", async (req, res) => {
  try {
    const orgId = getOrgId(req);
    const businessId = orgId;
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
    const driver: Driver = withBusinessId(businessId, {
      driverId: driverDoc.id,
      name: driverData.name,
      phone: driverData.phone,
      driverCode: driverData.driverCode,
      assignedRouteId: driverData.assignedRouteId,
      assignedBusId: driverData.assignedBusId,
      status: driverData.status,
    }) as Driver;

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

    const bus: Bus = withBusinessId(businessId, {
      busId: busDoc.id,
      ...(busDoc.data() as Omit<Bus, "busId" | "businessId" | "organizationId">),
    }) as Bus;

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

    const route: Route = withBusinessId(businessId, {
      routeId: routeDoc.id,
      ...(routeDoc.data() as Omit<Route, "routeId" | "businessId" | "organizationId">),
    }) as Route;

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
