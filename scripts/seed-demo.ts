/**
 * Seed demo data + RBAC users into Firestore emulator.
 * Run: npx ts-node scripts/seed-demo.ts
 * Requires FIRESTORE_EMULATOR_HOST=127.0.0.1:8080
 */

import * as admin from "firebase-admin";
import { randomBytes, scryptSync } from "crypto";

const PROJECT_ID = process.env.GCLOUD_PROJECT || "tardadi-5bd8e";
const BUSINESS_ID = "demo-org";

function hashPassword(password: string): string {
  const salt = randomBytes(16).toString("hex");
  const hash = scryptSync(password, salt, 64, { N: 16384, r: 8, p: 1 }).toString(
    "hex"
  );
  return `scrypt:${salt}:${hash}`;
}

if (!admin.apps.length) {
  admin.initializeApp({ projectId: PROJECT_ID });
}

const db = admin.firestore();

async function seed() {
  const now = new Date().toISOString();

  // Super Admin
  await db.collection("admin_users").doc("super-admin").set({
    name: "مدير النظام",
    phone: "+966500000001",
    passwordHash: hashPassword("admin123"),
    role: "super_admin",
    businessId: null,
    status: "active",
    createdAt: now,
    updatedAt: now,
  });

  // Demo business (Roshn-style)
  await db.collection("businesses").doc(BUSINESS_ID).set({
    name: "ترددي Demo",
    logo: null,
    status: "active",
    adminUserId: "demo-business-admin",
    createdAt: now,
    updatedAt: now,
  });

  await db.collection("admin_users").doc("demo-business-admin").set({
    name: "أحمد",
    phone: "+966538783273",
    passwordHash: hashPassword("demo123"),
    role: "business_admin",
    businessId: BUSINESS_ID,
    status: "active",
    createdAt: now,
    updatedAt: now,
  });

  const routeRef = await db
    .collection("businesses")
    .doc(BUSINESS_ID)
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
    .collection("businesses")
    .doc(BUSINESS_ID)
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
    .collection("businesses")
    .doc(BUSINESS_ID)
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

  console.log("✅ Demo data + RBAC seeded:");
  console.log("");
  console.log("Super Admin:");
  console.log("  phone: 0500000001");
  console.log("  password: admin123");
  console.log("");
  console.log("Business Admin (Demo company):");
  console.log("  phone: 0538783273");
  console.log("  password: demo123");
  console.log("");
  console.log(`  businessId: ${BUSINESS_ID}`);
  console.log(`  routeId: ${routeRef.id}`);
  console.log(`  busId: ${busRef.id}`);
  console.log(`  driverId: ${driverRef.id}`);
}

seed().catch(console.error);
