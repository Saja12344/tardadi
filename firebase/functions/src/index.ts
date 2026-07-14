import * as functions from "firebase-functions";
import express from "express";
import cors from "cors";

import authRouter from "./routes/auth";
import businessesRouter from "./routes/businesses";
import routesRouter from "./routes/routes";
import busesRouter from "./routes/buses";
import driversRouter from "./routes/drivers";
import tripsRouter from "./routes/trips";
import gpsRouter from "./routes/gps";
import remindersRouter from "./routes/reminders";
import { attachAdminAuth } from "./auth/middleware";

const app = express();

app.use(cors({ origin: true }));
app.use(express.json());
app.use(attachAdminAuth);

app.get("/api/health", (_req, res) => {
  res.json({ success: true, data: { status: "ok", service: "tardadi-api" } });
});

app.use("/api/auth", authRouter);
app.use("/api/businesses", businessesRouter);
app.use("/api/routes", routesRouter);
app.use("/api/buses", busesRouter);
app.use("/api/drivers", driversRouter);
app.use("/api/trips", tripsRouter);
app.use("/api/gps", gpsRouter);
app.use("/api/reminders", remindersRouter);

export const api = functions.https.onRequest(app);
