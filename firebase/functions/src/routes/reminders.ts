import { Router } from "express";
import { COLLECTIONS, DEFAULT_REMINDER_MINUTES } from "@tardadi/shared";
import { db } from "../firebase";
import { fail, getOrgId, ok } from "../utils";

const router = Router();

router.get("/", async (req, res) => {
  try {
    const orgId = getOrgId(req);
    const userId = req.query.userId as string | undefined;

    let query: FirebaseFirestore.Query = db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.reminders);

    if (userId) {
      query = query.where("userId", "==", userId);
    }

    const snapshot = await query.where("status", "==", "active").get();
    const reminders = snapshot.docs.map((doc) => ({
      reminderId: doc.id,
      organizationId: orgId,
      ...doc.data(),
    }));

    ok(res, reminders);
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

router.post("/", async (req, res) => {
  try {
    const orgId = getOrgId(req);
    const {
      userId,
      busId,
      routeId,
      stopId,
      fcmToken,
      notifyWhenMinutesAway = DEFAULT_REMINDER_MINUTES,
    } = req.body;

    if (!userId || !busId || !routeId || !stopId || !fcmToken) {
      fail(res, "userId, busId, routeId, stopId, and fcmToken are required");
      return;
    }

    const now = new Date().toISOString();
    const docRef = await db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.reminders)
      .add({
        userId,
        busId,
        routeId,
        stopId,
        fcmToken,
        status: "active",
        notifyWhenMinutesAway,
        createdAt: now,
        updatedAt: now,
      });

    ok(
      res,
      {
        reminderId: docRef.id,
        organizationId: orgId,
        userId,
        busId,
        routeId,
        stopId,
        status: "active",
        notifyWhenMinutesAway,
      },
      201
    );
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

router.delete("/:reminderId", async (req, res) => {
  try {
    const orgId = getOrgId(req);
    const { reminderId } = req.params;

    await db
      .collection(COLLECTIONS.organizations)
      .doc(orgId)
      .collection(COLLECTIONS.reminders)
      .doc(reminderId)
      .update({
        status: "cancelled",
        updatedAt: new Date().toISOString(),
      });

    ok(res, { reminderId, status: "cancelled" });
  } catch (error) {
    fail(res, (error as Error).message, 500);
  }
});

export default router;
