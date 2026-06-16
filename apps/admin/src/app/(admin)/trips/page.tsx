"use client";

import { useEffect, useMemo, useState } from "react";
import type { Bus, Trip } from "@tardadi/shared";
import { api } from "@/lib/api";
import MapView from "@/components/MapView";
import { geoPointToLatLng, type MapMarker } from "@/lib/mapUtils";

export default function TripsPage() {
  const [trips, setTrips] = useState<Trip[]>([]);
  const [buses, setBuses] = useState<Bus[]>([]);
  const [error, setError] = useState("");

  async function load() {
    try {
      const [tripData, busData] = await Promise.all([
        api.getTrips("active") as Promise<Trip[]>,
        api.getBuses(true) as Promise<Bus[]>,
      ]);
      setTrips(tripData);
      setBuses(busData);
      setError("");
    } catch (e) {
      setError((e as Error).message);
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

  const liveMarkers: MapMarker[] = useMemo(() => {
    const markers: MapMarker[] = [];
    for (const trip of trips) {
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
        <h1>الرحلات النشطة</h1>
        <p>راقب الرحلات الجارية ومواقع الباصات على الخريطة.</p>
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
              <th>بدأت</th>
            </tr>
          </thead>
          <tbody>
            {trips.length === 0 ? (
              <tr>
                <td colSpan={5}>لا توجد رحلات نشطة حالياً</td>
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
    </>
  );
}
