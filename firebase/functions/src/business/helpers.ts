import type { Firestore } from "firebase-admin/firestore";
import { COLLECTIONS } from "@tardadi/shared";

export function businessRef(db: Firestore, businessId: string) {
  return db.collection(COLLECTIONS.businesses).doc(businessId);
}

export async function countStations(
  db: Firestore,
  businessId: string
): Promise<number> {
  const routesSnap = await businessRef(db, businessId)
    .collection(COLLECTIONS.routes)
    .get();

  let count = 0;
  for (const routeDoc of routesSnap.docs) {
    const routeData = routeDoc.data();
    const stopsSnap = await routeDoc.ref.collection(COLLECTIONS.stops).get();
    count += stopsSnap.size;
    if (routeData.fromLocation) count += 1;
    if (routeData.toLocation) count += 1;
  }
  return count;
}

export async function countTodayTrips(
  db: Firestore,
  businessId: string
): Promise<number> {
  const startOfDay = new Date();
  startOfDay.setHours(0, 0, 0, 0);
  const startIso = startOfDay.toISOString();

  const snap = await businessRef(db, businessId)
    .collection(COLLECTIONS.trips)
    .where("createdAt", ">=", startIso)
    .get();

  return snap.size;
}

export async function getBusinessStats(db: Firestore, businessId: string) {
  const ref = businessRef(db, businessId);
  const [drivers, buses, routes, stationCount, todayTripCount] =
    await Promise.all([
      ref.collection(COLLECTIONS.drivers).get(),
      ref.collection(COLLECTIONS.buses).get(),
      ref.collection(COLLECTIONS.routes).get(),
      countStations(db, businessId),
      countTodayTrips(db, businessId),
    ]);

  return {
    businessId,
    driverCount: drivers.size,
    busCount: buses.size,
    routeCount: routes.size,
    stationCount,
    todayTripCount,
  };
}
