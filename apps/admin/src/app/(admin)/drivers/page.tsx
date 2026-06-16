"use client";

import { useEffect, useState } from "react";
import type { Bus, Driver, Route } from "@tardadi/shared";
import { api } from "@/lib/api";
import { adminFetch } from "@/lib/adminFetch";

export default function DriversPage() {
  const [drivers, setDrivers] = useState<Driver[]>([]);
  const [routes, setRoutes] = useState<Route[]>([]);
  const [buses, setBuses] = useState<Bus[]>([]);
  const [name, setName] = useState("");
  const [phone, setPhone] = useState("");
  const [assignedRouteId, setAssignedRouteId] = useState("");
  const [assignedBusId, setAssignedBusId] = useState("");
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  async function load() {
    setError("");
    try {
      setRoutes((await api.getRoutes()) as Route[]);
    } catch (e) {
      setError(`تعذر تحميل الخطوط: ${(e as Error).message}`);
    }

    try {
      setBuses((await api.getBuses()) as Bus[]);
    } catch (e) {
      setError(`تعذر تحميل الباصات: ${(e as Error).message}`);
    }

    try {
      setDrivers((await api.getDrivers()) as Driver[]);
    } catch (e) {
      setError(`تعذر تحميل السائقين: ${(e as Error).message}`);
    }
  }

  async function createDriver(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setSuccess("");
    try {
      await adminFetch("/api/drivers", {
        method: "POST",
        body: JSON.stringify({
          name,
          phone,
          assignedRouteId,
          assignedBusId,
        }),
      });
      setName("");
      setPhone("");
      setAssignedRouteId("");
      setAssignedBusId("");
      setSuccess("تمت إضافة السائق. يقدر يسجّل دخوله برقم جواله في التطبيق.");
      await load();
    } catch (e) {
      setError((e as Error).message);
    }
  }

  useEffect(() => {
    load();
  }, []);

  return (
    <>
      <div className="page-header">
        <h1>السائقين</h1>
        <p>أضف اسم السائق ورقم جواله. إذا كان رقمه مسجّل، يقدر يدخل التطبيق مباشرة.</p>
      </div>

      <div className="grid-2">
        <form className="card" onSubmit={createDriver}>
          <h3>إضافة سائق</h3>
          {error && <div className="alert alert-error">{error}</div>}
          {success && <div className="alert alert-success">{success}</div>}

          <div className="field">
            <label>اسم السائق</label>
            <input
              placeholder="مثال: أحمد علي"
              value={name}
              onChange={(e) => setName(e.target.value)}
              required
            />
          </div>

          <div className="field">
            <label>رقم الجوال</label>
            <input
              placeholder="05xxxxxxxx"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              required
            />
          </div>

          <div className="field">
            <label>الخط المسموح</label>
            <select
              value={assignedRouteId}
              onChange={(e) => setAssignedRouteId(e.target.value)}
              required
            >
              <option value="">اختر الخط</option>
              {routes.map((route) => (
                <option key={route.routeId} value={route.routeId}>
                  {route.name}
                </option>
              ))}
            </select>
          </div>

          <div className="field">
            <label>الباص المعيّن</label>
            <select
              value={assignedBusId}
              onChange={(e) => setAssignedBusId(e.target.value)}
              required
            >
              <option value="">اختر الباص</option>
              {buses.map((bus) => (
                <option key={bus.busId} value={bus.busId}>
                  {bus.label}
                </option>
              ))}
            </select>
          </div>

          {buses.length === 0 && (
            <div className="alert alert-error">
              لا توجد باصات. أضف باصاً أولاً من صفحة الباصات.
            </div>
          )}

          <button className="btn" type="submit">
            حفظ السائق
          </button>
        </form>

        <div className="card table-wrap">
          <h3>السائقين ({drivers.length})</h3>
          <table>
            <thead>
              <tr>
                <th>الاسم</th>
                <th>الجوال</th>
                <th>الخط</th>
                <th>الباص</th>
              </tr>
            </thead>
            <tbody>
              {drivers.map((driver) => (
                <tr key={driver.driverId}>
                  <td>{driver.name}</td>
                  <td>{driver.phone}</td>
                  <td>
                    {routes.find((r) => r.routeId === driver.assignedRouteId)
                      ?.name || "—"}
                  </td>
                  <td>
                    {buses.find((b) => b.busId === driver.assignedBusId)?.label ||
                      "—"}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </>
  );
}
