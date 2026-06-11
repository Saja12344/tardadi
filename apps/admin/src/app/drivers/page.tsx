"use client";

import { useEffect, useState } from "react";
import type { Bus, Driver, Route } from "@tardadi/shared";
import { api } from "@/lib/api";

export default function DriversPage() {
  const [drivers, setDrivers] = useState<Driver[]>([]);
  const [routes, setRoutes] = useState<Route[]>([]);
  const [buses, setBuses] = useState<Bus[]>([]);
  const [driverCode, setDriverCode] = useState("");
  const [name, setName] = useState("");
  const [assignedRouteId, setAssignedRouteId] = useState("");
  const [assignedBusId, setAssignedBusId] = useState("");
  const [error, setError] = useState("");

  const baseUrl =
    process.env.NEXT_PUBLIC_API_URL ||
    "http://127.0.0.1:5001/demo-org/us-central1/api";
  const orgId = process.env.NEXT_PUBLIC_ORG_ID || "demo-org";

  async function load() {
    try {
      const [driversData, routesData, busesData] = await Promise.all([
        api.getDrivers() as Promise<Driver[]>,
        api.getRoutes() as Promise<Route[]>,
        api.getBuses() as Promise<Bus[]>,
      ]);
      setDrivers(driversData);
      setRoutes(routesData);
      setBuses(busesData);
    } catch (e) {
      setError((e as Error).message);
    }
  }

  async function createDriver(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    try {
      await fetch(`${baseUrl}/api/drivers?organizationId=${orgId}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          driverCode,
          name,
          assignedRouteId,
          assignedBusId,
        }),
      });
      setDriverCode("");
      setName("");
      setAssignedRouteId("");
      setAssignedBusId("");
      await load();
    } catch (e) {
      setError((e as Error).message);
    }
  }

  useEffect(() => {
    load();
  }, []);

  return (
    <main className="container">
      <h1>السائقين</h1>
      <form className="card" onSubmit={createDriver}>
        <h3>إضافة سائق + تعيين خط وباص</h3>
        <input
          placeholder="كود السائق (DRV-102)"
          value={driverCode}
          onChange={(e) => setDriverCode(e.target.value)}
          required
        />
        <input
          placeholder="الاسم"
          value={name}
          onChange={(e) => setName(e.target.value)}
          required
        />
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
        <button className="btn" type="submit">
          إضافة
        </button>
      </form>
      {error && <p style={{ color: "#ff6b6b" }}>{error}</p>}
      <div className="card">
        <table>
          <thead>
            <tr>
              <th>الاسم</th>
              <th>الكود</th>
              <th>الخط</th>
              <th>الباص</th>
            </tr>
          </thead>
          <tbody>
            {drivers.map((driver) => (
              <tr key={driver.driverId}>
                <td>{driver.name}</td>
                <td>{driver.driverCode}</td>
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
    </main>
  );
}
