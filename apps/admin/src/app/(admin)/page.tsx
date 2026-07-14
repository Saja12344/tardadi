"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import type { Bus, Driver, Route, Trip } from "@tardadi/shared";
import { api } from "@/lib/api";
import { useAuth } from "@/components/AuthProvider";
import { isSuperAdmin } from "@/lib/auth.constants";
import { adminFetch } from "@/lib/adminFetch";
import type { BusinessListItem } from "@tardadi/shared";

export default function HomePage() {
  const { user, businessContextId } = useAuth();
  const [counts, setCounts] = useState({
    routes: 0,
    buses: 0,
    drivers: 0,
    trips: 0,
    businesses: 0,
  });

  useEffect(() => {
    async function load() {
      try {
        if (isSuperAdmin(user) && !businessContextId) {
          const businesses = await adminFetch<BusinessListItem[]>(
            "/api/businesses"
          );
          setCounts({
            businesses: businesses.length,
            routes: businesses.reduce((s, b) => s + b.routeCount, 0),
            buses: businesses.reduce((s, b) => s + b.busCount, 0),
            drivers: businesses.reduce((s, b) => s + b.driverCount, 0),
            trips: 0,
          });
          return;
        }

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
          businesses: 0,
        });
      } catch {
        // Backend may be offline
      }
    }
    if (user) load();
  }, [user, businessContextId]);

  return (
    <>
      <div className="page-header">
        <h1>مرحباً {user?.name || "بك"} في ترددي</h1>
        <p>
          {isSuperAdmin(user)
            ? "لوحة مدير النظام — إدارة كل الشركات"
            : "إدارة شركتك: السائقون، الباصات، والخطوط"}
        </p>
      </div>

      {isSuperAdmin(user) && !businessContextId && (
        <div className="alert alert-info card mb-20">
          اختر شركة من القائمة الجانبية لإدارة خطوطها وسائقيها وباصاتها.
        </div>
      )}

      <div className="stat-grid">
        {isSuperAdmin(user) && (
          <div className="stat-card">
            <strong>{counts.businesses}</strong>
            <span>الشركات</span>
          </div>
        )}
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
          {isSuperAdmin(user) && (
            <Link href="/businesses" className="step active">
              إدارة الشركات
            </Link>
          )}
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
