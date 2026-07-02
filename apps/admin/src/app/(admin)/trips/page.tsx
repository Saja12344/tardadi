"use client";

import { useEffect, useMemo, useState } from "react";
import type { Bus, Driver, Route, Trip } from "@tardadi/shared";
import { api } from "@/lib/api";
import MapView from "@/components/MapView";
import { geoPointToLatLng, type MapMarker } from "@/lib/mapUtils";
import { getUserErrorMessage } from "@/lib/errorMessage";

export default function TripsPage() {
  const [trips, setTrips] = useState<Trip[]>([]);
  const [buses, setBuses] = useState<Bus[]>([]);
  const [drivers, setDrivers] = useState<Driver[]>([]);
  const [routes, setRoutes] = useState<Route[]>([]);
  const [error, setError] = useState("");

  async function load() {
    try {
      const [tripData, busData, driverData, routeData] = await Promise.all([
        api.getTrips() as Promise<Trip[]>,
        api.getBuses() as Promise<Bus[]>,
        api.getDrivers() as Promise<Driver[]>,
        api.getRoutes() as Promise<Route[]>,
      ]);
      setTrips(tripData);
      setBuses(busData);
      setDrivers(driverData);
      setRoutes(routeData);
      setError("");
    } catch (e) {
      setError(getUserErrorMessage(e));
    }
  }

  useEffect(() => {
    load();
    const interval = setInterval(load, 10_000);
    return () => clearInterval(interval);
  }, []);

  const busById = useMemo(
    () => new Map(buses.map((bus) => [bus.busId, bus])),
    [buses]
  );

  const driverById = useMemo(
    () => new Map(drivers.map((driver) => [driver.driverId, driver])),
    [drivers]
  );

  const routeById = useMemo(
    () => new Map(routes.map((route) => [route.routeId, route])),
    [routes]
  );

  const liveMarkers: MapMarker[] = useMemo(() => {
    const markers: MapMarker[] = [];
    for (const trip of trips.filter((trip) => trip.tripStatus === "active")) {
      const bus = busById.get(trip.busId);
      if (!bus?.currentLocation) continue;
      markers.push({
        id: trip.tripId,
        position: geoPointToLatLng(bus.currentLocation),
        label: `${bus.label} (${bus.plateNo})`,
        kind: "bus",
      });
    }
    return markers;
  }, [trips, busById]);

  return (
    <>
      <div className="page-header">
        <h1>سجل الرحلات</h1>
        <p>الرحلات المنتهية تبقى محفوظة هنا، والخريطة تعرض النشطة فقط.</p>
      </div>

      {error && <div className="alert alert-error">{error}</div>}

      <div className="card map-card">
        <h3>خريطة الرحلات المباشرة ({liveMarkers.length} باص على الخريطة)</h3>
        {liveMarkers.length === 0 && (
          <p className="map-hint">
            لا توجد مواقع GPS حالياً — تظهر عندما يبدأ السائق الرحلة.
          </p>
        )}
        <MapView markers={liveMarkers} height={420} />
      </div>

      <div className="card table-wrap">
        <table>
          <thead>
            <tr>
              <th>رقم الرحلة</th>
              <th>الباص</th>
              <th>السائق</th>
              <th>الخط</th>
              <th>الحالة</th>
              <th>بدأت</th>
              <th>انتهت</th>
            </tr>
          </thead>
          <tbody>
            {trips.length === 0 ? (
              <tr>
                <td colSpan={7}>لا توجد رحلات مسجلة حالياً</td>
              </tr>
            ) : (
              trips.map((trip) => {
                const bus = busById.get(trip.busId);
                const driver = driverById.get(trip.driverId);
                const route = routeById.get(trip.routeId);

                return (
                  <tr key={trip.tripId}>
                    <td className="mono-id">{shortId(trip.tripId)}</td>
                    <td>{bus ? `${bus.label} (${bus.plateNo})` : shortId(trip.busId)}</td>
                    <td>{driver?.name || shortId(trip.driverId)}</td>
                    <td>{route ? `${route.name} (${route.code})` : shortId(trip.routeId)}</td>
                    <td>
                      <span className={`status-pill status-${trip.tripStatus}`}>
                        {formatTripStatus(trip.tripStatus)}
                      </span>
                    </td>
                    <td>{formatStartedAt(trip.startedAt)}</td>
                    <td>{formatStartedAt(trip.endedAt)}</td>
                  </tr>
                );
              })
            )}
          </tbody>
        </table>
      </div>
    </>
  );
}

function shortId(id: string): string {
  if (id.length <= 8) return id;
  return `${id.slice(0, 6)}...${id.slice(-4)}`;
}

function formatStartedAt(value?: string | null): string {
  if (!value) return "—";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return value;

  return new Intl.DateTimeFormat("ar-SA", {
    dateStyle: "medium",
    timeStyle: "short",
  }).format(date);
}

function formatTripStatus(status: Trip["tripStatus"]): string {
  if (status === "active") return "نشطة";
  if (status === "ended") return "منتهية";
  return "مجدولة";
}
