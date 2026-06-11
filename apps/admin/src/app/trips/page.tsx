"use client";

import { useEffect, useState } from "react";
import type { Trip } from "@tardadi/shared";
import { api } from "@/lib/api";

export default function TripsPage() {
  const [trips, setTrips] = useState<Trip[]>([]);
  const [error, setError] = useState("");

  async function load() {
    try {
      const data = (await api.getTrips("active")) as Trip[];
      setTrips(data);
    } catch (e) {
      setError((e as Error).message);
    }
  }

  useEffect(() => {
    load();
    const interval = setInterval(load, 10_000);
    return () => clearInterval(interval);
  }, []);

  return (
    <main className="container">
      <h1>الرحلات النشطة</h1>
      {error && <p style={{ color: "#ff6b6b" }}>{error}</p>}
      <div className="card">
        <table>
          <thead>
            <tr>
              <th>رقم الرحلة</th>
              <th>الباص</th>
              <th>السائق</th>
              <th>الخط</th>
              <th>بدأت</th>
            </tr>
          </thead>
          <tbody>
            {trips.length === 0 ? (
              <tr>
                <td colSpan={5}>لا توجد رحلات نشطة</td>
              </tr>
            ) : (
              trips.map((trip) => (
                <tr key={trip.tripId}>
                  <td>{trip.tripId}</td>
                  <td>{trip.busId}</td>
                  <td>{trip.driverId}</td>
                  <td>{trip.routeId}</td>
                  <td>{trip.startedAt}</td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </main>
  );
}
