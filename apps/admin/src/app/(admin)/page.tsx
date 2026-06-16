"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import type { Bus, Driver, Route, Trip } from "@tardadi/shared";
import { api } from "@/lib/api";

export default function HomePage() {
  const [counts, setCounts] = useState({
    routes: 0,
    buses: 0,
    drivers: 0,
    trips: 0,
  });

  useEffect(() => {
    async function load() {
      try {
        const [routes, buses, drivers, trips] = await Promise.all([
          api.getRoutes() as Promise<Route[]>,
          api.getBuses() as Promise<Bus[]>,
          api.getDrivers() as Promise<Driver[]>,
          api.getTrips("active") as Promise<Trip[]>,
        ]);
        setCounts({
          routes: routes.length,
          buses: buses.length,
          drivers: drivers.length,
          trips: trips.length,
        });
      } catch {
        // Backend may be offline — keep zeros
      }
    }
    load();
  }, []);

  return (
    <>
      <div className="page-header">
        <h1>مرحباً بك في ترددي</h1>
        <p>إدارة بسيطة: أضف البيانات من هنا، والسائق يدخل برقم جواله فقط.</p>
      </div>

      <div className="steps">
        <span className={`step ${counts.routes > 0 ? "active" : ""}`}>
          1. أضف خط
        </span>
        <span className={`step ${counts.buses > 0 ? "active" : ""}`}>
          2. أضف باص
        </span>
        <span className={`step ${counts.drivers > 0 ? "active" : ""}`}>
          3. أضف سائق
        </span>
        <span className="step">4. السائق يدخل بالجوال</span>
      </div>

      <div className="stat-grid">
        <div className="stat-card">
          <strong>{counts.routes}</strong>
          <span>الخطوط</span>
        </div>
        <div className="stat-card">
          <strong>{counts.buses}</strong>
          <span>الباصات</span>
        </div>
        <div className="stat-card">
          <strong>{counts.drivers}</strong>
          <span>السائقين</span>
        </div>
        <div className="stat-card">
          <strong>{counts.trips}</strong>
          <span>الرحلات النشطة</span>
        </div>
      </div>

      <div className="card">
        <h3>ابدأ من هنا</h3>
        <div className="steps">
          <Link href="/routes" className="step active">
            إضافة خط
          </Link>
          <Link href="/buses" className="step active">
            إضافة باص
          </Link>
          <Link href="/drivers" className="step active">
            إضافة سائق
          </Link>
        </div>
      </div>
    </>
  );
}
