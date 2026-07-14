"use client";

import Link from "next/link";
import { useParams, useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import type {
  Bus,
  BusinessStats,
  Driver,
  Route,
  Trip,
} from "@tardadi/shared";
import { api } from "@/lib/api";
import { adminFetch } from "@/lib/adminFetch";
import { getUserErrorMessage } from "@/lib/errorMessage";
import { useAuth } from "@/components/AuthProvider";

type Tab =
  | "overview"
  | "drivers"
  | "buses"
  | "routes"
  | "stations"
  | "trips"
  | "admin";

interface BusinessDetail {
  businessId: string;
  name: string;
  logo?: string | null;
  status: string;
  adminName?: string | null;
  adminPhone?: string | null;
  stats: BusinessStats;
}

export default function BusinessDetailPage() {
  const params = useParams<{ businessId: string }>();
  const businessId = params.businessId;
  const router = useRouter();
  const { user, setBusinessContext } = useAuth();
  const [tab, setTab] = useState<Tab>("overview");
  const [business, setBusiness] = useState<BusinessDetail | null>(null);
  const [drivers, setDrivers] = useState<Driver[]>([]);
  const [buses, setBuses] = useState<Bus[]>([]);
  const [routes, setRoutes] = useState<Route[]>([]);
  const [trips, setTrips] = useState<Trip[]>([]);
  const [error, setError] = useState("");

  useEffect(() => {
    if (
      user?.role === "business_admin" &&
      user.businessId &&
      user.businessId !== businessId
    ) {
      router.replace(`/businesses/${user.businessId}`);
    }
  }, [user, businessId, router]);

  useEffect(() => {
    if (user?.role === "super_admin") {
      void setBusinessContext(businessId);
    }
  }, [businessId, user, setBusinessContext]);

  async function load() {
    setError("");
    try {
      const detail = await adminFetch<BusinessDetail>(
        `/api/businesses/${businessId}`
      );
      setBusiness(detail);

      const [d, b, r, t] = await Promise.all([
        api.getDrivers() as Promise<Driver[]>,
        api.getBuses() as Promise<Bus[]>,
        api.getRoutes() as Promise<Route[]>,
        api.getTrips() as Promise<Trip[]>,
      ]);

      const filter = <T extends { businessId?: string }>(items: T[]) =>
        items.filter((i) => i.businessId === businessId);

      setDrivers(filter(d));
      setBuses(filter(b));
      setRoutes(filter(r));
      setTrips(filter(t));
    } catch (e) {
      setError(getUserErrorMessage(e));
    }
  }

  useEffect(() => {
    load();
  }, [businessId]);

  const tabs: Array<{ id: Tab; label: string }> = [
    { id: "overview", label: "نظرة عامة" },
    { id: "drivers", label: "السائقين" },
    { id: "buses", label: "الباصات" },
    { id: "routes", label: "الخطوط" },
    { id: "stations", label: "المحطات" },
    { id: "trips", label: "الرحلات" },
    { id: "admin", label: "مدير الشركة" },
  ];

  const stationRows = routes.flatMap((route) => {
    const items: Array<{ routeName: string; name: string }> = [];
    if (route.fromLocation?.address) {
      items.push({ routeName: route.name, name: route.fromLocation.address });
    }
    if (route.toLocation?.address) {
      items.push({ routeName: route.name, name: route.toLocation.address });
    }
    return items;
  });

  return (
    <>
      <div className="page-header">
        <div className="row-between">
          <div>
            <h1>{business?.name || "الشركة"}</h1>
            <p>
              {business?.status === "active" ? "نشطة" : "معطّلة"}
              {user?.role === "super_admin" && (
                <>
                  {" "}
                  · <Link href="/businesses">كل الشركات</Link>
                </>
              )}
            </p>
          </div>
          {user?.role === "super_admin" && (
            <div className="quick-links">
              <Link href="/routes" className="btn btn-sm">
                إدارة الخطوط
              </Link>
              <Link href="/drivers" className="btn btn-sm">
                إدارة السائقين
              </Link>
            </div>
          )}
        </div>
      </div>

      {error && <div className="alert alert-error">{error}</div>}

      <div className="tabs">
        {tabs.map((t) => (
          <button
            key={t.id}
            type="button"
            className={`tab ${tab === t.id ? "active" : ""}`}
            onClick={() => setTab(t.id)}
          >
            {t.label}
          </button>
        ))}
      </div>

      {tab === "overview" && business && (
        <div className="stat-grid">
          <div className="stat-card">
            <strong>{business.stats.driverCount}</strong>
            <span>السائقين</span>
          </div>
          <div className="stat-card">
            <strong>{business.stats.busCount}</strong>
            <span>الباصات</span>
          </div>
          <div className="stat-card">
            <strong>{business.stats.routeCount}</strong>
            <span>الخطوط</span>
          </div>
          <div className="stat-card">
            <strong>{business.stats.stationCount}</strong>
            <span>المحطات</span>
          </div>
          <div className="stat-card">
            <strong>{business.stats.todayTripCount}</strong>
            <span>رحلات اليوم</span>
          </div>
        </div>
      )}

      {tab === "drivers" && (
        <div className="card table-card">
          <table className="data-table">
            <thead>
              <tr>
                <th>الاسم</th>
                <th>الجوال</th>
                <th>الحالة</th>
              </tr>
            </thead>
            <tbody>
              {drivers.map((d) => (
                <tr key={d.driverId}>
                  <td>{d.name}</td>
                  <td dir="ltr">{d.phone}</td>
                  <td>{d.status}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {tab === "buses" && (
        <div className="card table-card">
          <table className="data-table">
            <thead>
              <tr>
                <th>اللوحة</th>
                <th>الاسم</th>
                <th>الحالة</th>
              </tr>
            </thead>
            <tbody>
              {buses.map((b) => (
                <tr key={b.busId}>
                  <td>{b.plateNo}</td>
                  <td>{b.label}</td>
                  <td>{b.status}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {tab === "routes" && (
        <div className="card table-card">
          <table className="data-table">
            <thead>
              <tr>
                <th>الاسم</th>
                <th>الكود</th>
                <th>المحطات</th>
              </tr>
            </thead>
            <tbody>
              {routes.map((r) => (
                <tr key={r.routeId}>
                  <td>{r.name}</td>
                  <td>{r.code}</td>
                  <td>{(r as Route & { stopsCount?: number }).stopsCount ?? "—"}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {tab === "stations" && (
        <div className="card table-card">
          <table className="data-table">
            <thead>
              <tr>
                <th>الخط</th>
                <th>المحطة</th>
              </tr>
            </thead>
            <tbody>
              {stationRows.map((s, i) => (
                <tr key={`${s.routeName}-${i}`}>
                  <td>{s.routeName}</td>
                  <td>{s.name}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {tab === "trips" && (
        <div className="card table-card">
          <table className="data-table">
            <thead>
              <tr>
                <th>الحالة</th>
                <th>الباص</th>
                <th>السائق</th>
                <th>بدأت</th>
              </tr>
            </thead>
            <tbody>
              {trips.map((t) => (
                <tr key={t.tripId}>
                  <td>{t.tripStatus}</td>
                  <td>{t.busId}</td>
                  <td>{t.driverId}</td>
                  <td>{t.startedAt || "—"}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {tab === "admin" && business && (
        <div className="card">
          <h3>مدير الشركة</h3>
          <p>
            <strong>الاسم:</strong> {business.adminName || "—"}
          </p>
          <p>
            <strong>الجوال:</strong>{" "}
            <span dir="ltr">{business.adminPhone || "—"}</span>
          </p>
          {user?.role === "super_admin" && (
            <p className="muted">
              لتعديل بيانات المدير، استخدم صفحة الشركات أو عدّل الشركة من الإجراءات.
            </p>
          )}
        </div>
      )}
    </>
  );
}
