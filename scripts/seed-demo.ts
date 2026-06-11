/**
 * Seed demo data into Firestore emulator.
 * Run: npx ts-node scripts/seed-demo.ts
 * Requires FIRESTORE_EMULATOR_HOST=127.0.0.1:8080
 */

import * as admin from "firebase-admin";

const ORG_ID = "demo-org";

if (!admin.apps.length) {
  admin.initializeApp({ projectId: "demo-org" });
}

const db = admin.firestore();

async function seed() {
  const now = new Date().toISOString();

  await db.collection("organizations").doc(ORG_ID).set({
    name: "ترددي Demo",
    type: "company",
    accessMode: "public",
    status: "active",
    createdAt: now,
    updatedAt: now,
  });

  const routeRef = await db
    .collection("organizations")
    .doc(ORG_ID)
    .collection("routes")
    .add({
      name: "الخط أ",
      code: "R-A",
      colorHex: "#FF6B00",
      status: "active",
      createdAt: now,
      updatedAt: now,
    });

  await routeRef.collection("stops").add({
    name: "البوابة الرئيسية",
    latitude: 24.7136,
    longitude: 46.6753,
    sequenceNo: 1,
    geofenceRadiusM: 500,
    status: "active",
    createdAt: now,
    updatedAt: now,
  });

  await routeRef.collection("stops").add({
    name: "المحطة الوسطى",
    latitude: 24.72,
    longitude: 46.68,
    sequenceNo: 2,
    geofenceRadiusM: 500,
    status: "active",
    createdAt: now,
    updatedAt: now,
  });

  const busRef = await db
    .collection("organizations")
    .doc(ORG_ID)
    .collection("buses")
    .add({
      plateNo: "ABC-1234",
      label: "Bus 12",
      status: "active",
      currentTripId: null,
      currentLocation: null,
      lastSeenAt: null,
      createdAt: now,
      updatedAt: now,
    });

  const driverRef = await db
    .collection("organizations")
    .doc(ORG_ID)
    .collection("drivers")
    .add({
      driverCode: "DRV-102",
      name: "أحمد علي",
      phone: "+966500000000",
      assignedRouteId: routeRef.id,
      assignedBusId: busRef.id,
      status: "active",
      createdAt: now,
      updatedAt: now,
    });

  console.log("✅ Demo data seeded:");
  console.log(`  organizationId: ${ORG_ID}`);
  console.log(`  routeId: ${routeRef.id}`);
  console.log(`  busId: ${busRef.id}`);
  console.log(`  driverId: ${driverRef.id}`);
  console.log(`  driverCode: DRV-102`);
}

seed().catch(console.error);
