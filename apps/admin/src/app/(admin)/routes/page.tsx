"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import type { LocationPlace, Route, Stop } from "@tardadi/shared";
import { api } from "@/lib/api";
import { adminFetch } from "@/lib/adminFetch";
import LocationSearchField from "@/components/LocationSearchField";
import RouteMapEditor, { type PickMode } from "@/components/RouteMapEditor";
import {
  formatDistance,
  formatDuration,
  useRoadRoute,
} from "@/hooks/useRoadRoute";
import { decodePolyline } from "@/lib/routing";
import { routeEndpointsToMarkers, stopsToMarkers } from "@/lib/mapUtils";
import { getUserErrorMessage } from "@/lib/errorMessage";

type PanelMode = "list" | "create" | "detail";

async function reverseGeocode(
  lat: number,
  lng: number
): Promise<LocationPlace> {
  try {
    const response = await fetch(
      `/api/geocode/reverse?lat=${lat}&lng=${lng}`
    );
    const data = await response.json();
    if (!response.ok) throw new Error(data.error);
    return data as LocationPlace;
  } catch {
    return {
      address: `${lat.toFixed(5)}, ${lng.toFixed(5)}`,
      latitude: lat,
      longitude: lng,
    };
  }
}

export default function RoutesPage() {
  const [panelMode, setPanelMode] = useState<PanelMode>("list");
  const [routes, setRoutes] = useState<Route[]>([]);
  const [selectedRouteId, setSelectedRouteId] = useState<string | null>(null);
  const [selectedRoute, setSelectedRoute] = useState<Route | null>(null);
  const [stops, setStops] = useState<Stop[]>([]);

  const [name, setName] = useState("");
  const [code, setCode] = useState("");
  const [fromLocation, setFromLocation] = useState<LocationPlace | null>(null);
  const [toLocation, setToLocation] = useState<LocationPlace | null>(null);
  const [pickMode, setPickMode] = useState<PickMode>("from");
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const createRoute = useRoadRoute(fromLocation, toLocation);
  const detailNeedsFetch =
    selectedRoute?.fromLocation &&
    selectedRoute?.toLocation &&
    !decodePolyline(selectedRoute.polyline).length;

  const detailRoute = useRoadRoute(
    detailNeedsFetch ? selectedRoute!.fromLocation! : null,
    detailNeedsFetch ? selectedRoute!.toLocation! : null
  );

  async function load() {
    try {
      const data = (await api.getRoutes()) as Route[];
      setRoutes(data);
      setError("");
    } catch (e) {
      setError(getUserErrorMessage(e));
    }
  }

  async function loadRouteDetail(routeId: string) {
    try {
      const detail = (await api.getRoute(routeId)) as {
        route: Route;
        stops: Stop[];
      };
      setSelectedRoute(detail.route);
      setStops(detail.stops);
      setSelectedRouteId(routeId);
      setPanelMode("detail");
      setError("");
    } catch (e) {
      setError(getUserErrorMessage(e));
    }
  }

  function resetCreateForm() {
    setName("");
    setCode("");
    setFromLocation(null);
    setToLocation(null);
    setPickMode("from");
    setError("");
    setSuccess("");
  }

  function openCreate() {
    resetCreateForm();
    setPanelMode("create");
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setSuccess("");

    if (!fromLocation || !toLocation) {
      setError("حدّد نقطة البداية والنهاية");
      return;
    }

    if (!createRoute.roadRoute) {
      setError(
        createRoute.loading
          ? "جاري حساب المسار على الطريق..."
          : createRoute.error || "تعذّر حساب مسار الطريق"
      );
      return;
    }

    try {
      await adminFetch("/api/routes", {
        method: "POST",
        body: JSON.stringify({
          name,
          code,
          colorHex: "#EB4F26",
          fromLocation,
          toLocation,
          polyline: createRoute.roadRoute.polyline,
        }),
      });
      resetCreateForm();
      setSuccess("تمت إضافة الخط");
      setPanelMode("list");
      await load();
    } catch (e) {
      setError(getUserErrorMessage(e));
    }
  }

  const handleMapPick = useCallback(
    async (lat: number, lng: number) => {
      if (!pickMode) return;
      const place = await reverseGeocode(lat, lng);
      if (pickMode === "from") setFromLocation(place);
      else setToLocation(place);
    },
    [pickMode]
  );

  const handleMarkerDrag = useCallback(
    async (kind: "from" | "to", lat: number, lng: number) => {
      const place = await reverseGeocode(lat, lng);
      if (kind === "from") setFromLocation(place);
      else setToLocation(place);
    },
    []
  );

  useEffect(() => {
    load();
  }, []);

  const mapFrom = panelMode === "create" ? fromLocation : selectedRoute?.fromLocation ?? null;
  const mapTo = panelMode === "create" ? toLocation : selectedRoute?.toLocation ?? null;

  const mapPolyline = useMemo(() => {
    if (panelMode === "create") {
      return createRoute.roadRoute?.coordinates ?? [];
    }
    if (!selectedRoute) return [];
    const stored = decodePolyline(selectedRoute.polyline);
    if (stored.length > 1) return stored;
    return detailRoute.roadRoute?.coordinates ?? [];
  }, [panelMode, createRoute.roadRoute, selectedRoute, detailRoute.roadRoute]);

  const mapMarkers = useMemo(() => {
    if (panelMode === "detail" && selectedRoute) {
      return [
        ...routeEndpointsToMarkers(selectedRoute.fromLocation, selectedRoute.toLocation),
        ...stopsToMarkers(stops),
      ];
    }
    return [];
  }, [panelMode, selectedRoute, stops]);

  const routeMeta = panelMode === "create" ? createRoute : detailRoute;

  return (
    <div className="routes-workspace">
      <div className="routes-panel card">
        <div className="routes-panel-header">
          <div>
            <h1>الخطوط</h1>
            <p className="routes-panel-sub">
              {panelMode === "create"
                ? "حدّد المسار على الخريطة"
                : panelMode === "detail"
                  ? selectedRoute?.name
                  : "اختر خطاً أو أضف جديد"}
            </p>
          </div>
          {panelMode === "list" ? (
            <button type="button" className="btn btn-sm" onClick={openCreate}>
              + خط جديد
            </button>
          ) : (
            <button
              type="button"
              className="btn-ghost"
              onClick={() => {
                setPanelMode("list");
                setError("");
              }}
            >
              ← رجوع
            </button>
          )}
        </div>

        {error && <div className="alert alert-error">{error}</div>}
        {success && <div className="alert alert-success">{success}</div>}

        {panelMode === "list" && (
          <div className="routes-list">
            {routes.length === 0 ? (
              <p className="map-hint">لا توجد خطوط — اضغط «خط جديد»</p>
            ) : (
              routes.map((route) => (
                <button
                  key={route.routeId}
                  type="button"
                  className={`route-list-item ${selectedRouteId === route.routeId ? "active" : ""}`}
                  onClick={() => loadRouteDetail(route.routeId)}
                >
                  <strong>{route.name}</strong>
                  <span className="route-list-code">{route.code}</span>
                  {route.fromLocation && route.toLocation && (
                    <span className="route-list-path">
                      {route.fromLocation.address.split(",")[0]} →{" "}
                      {route.toLocation.address.split(",")[0]}
                    </span>
                  )}
                </button>
              ))
            )}
          </div>
        )}

        {panelMode === "create" && (
          <form className="routes-create-form" onSubmit={handleSubmit}>
            <div className="pick-mode-toggle">
              <button
                type="button"
                className={`pick-btn ${pickMode === "from" ? "active from" : ""}`}
                onClick={() => setPickMode("from")}
              >
                <span className="accent-dot accent-dot-from" />
                حدّد البداية
              </button>
              <button
                type="button"
                className={`pick-btn ${pickMode === "to" ? "active to" : ""}`}
                onClick={() => setPickMode("to")}
              >
                <span className="accent-dot accent-dot-to" />
                حدّد النهاية
              </button>
            </div>

            <LocationSearchField
              label="من"
              value={fromLocation}
              onChange={setFromLocation}
              onFocus={() => setPickMode("from")}
              accent="from"
            />

            <LocationSearchField
              label="إلى"
              value={toLocation}
              onChange={setToLocation}
              onFocus={() => setPickMode("to")}
              accent="to"
            />

            <div className="field">
              <label>اسم الخط</label>
              <input
                placeholder="مثال: روشن - الملز"
                value={name}
                onChange={(e) => setName(e.target.value)}
                required
              />
            </div>

            <div className="field">
              <label>كود الخط</label>
              <input
                placeholder="R-01"
                value={code}
                onChange={(e) => setCode(e.target.value)}
                required
              />
            </div>

            {routeMeta.roadRoute && (
              <p className="route-stats">
                {formatDistance(routeMeta.roadRoute.distanceMeters)} ·{" "}
                {formatDuration(routeMeta.roadRoute.durationSeconds)} بالباص
              </p>
            )}
            {routeMeta.loading && (
              <p className="route-stats loading">جاري حساب المسار على الطريق...</p>
            )}

            <button
              className="btn"
              type="submit"
              disabled={createRoute.loading || !createRoute.roadRoute}
            >
              حفظ الخط
            </button>
          </form>
        )}

        {panelMode === "detail" && selectedRoute && (
          <div className="routes-detail">
            <p className="detail-code">كود: {selectedRoute.code}</p>
            {selectedRoute.fromLocation && (
              <p className="detail-point">
                <span className="accent-dot accent-dot-from" />
                {selectedRoute.fromLocation.address}
              </p>
            )}
            {selectedRoute.toLocation && (
              <p className="detail-point">
                <span className="accent-dot accent-dot-to" />
                {selectedRoute.toLocation.address}
              </p>
            )}
            {detailRoute.roadRoute && (
              <p className="route-stats">
                {formatDistance(detailRoute.roadRoute.distanceMeters)} ·{" "}
                {formatDuration(detailRoute.roadRoute.durationSeconds)}
              </p>
            )}
            {stops.length > 0 && (
              <p className="map-hint">{stops.length} محطة وسيطة</p>
            )}
          </div>
        )}
      </div>

      <div className="routes-map-area">
        {panelMode === "list" && !selectedRoute && (
          <div className="routes-map-empty">
            <p>اختر خطاً من القائمة أو أضف خطاً جديداً</p>
          </div>
        )}
        {(panelMode !== "list" || selectedRoute) && (
          <RouteMapEditor
            fromLocation={mapFrom}
            toLocation={mapTo}
            pickMode={panelMode === "create" ? pickMode : null}
            roadPolyline={mapPolyline}
            extraMarkers={panelMode === "detail" ? mapMarkers.filter((m) => m.kind === "stop") : []}
            onMapPick={handleMapPick}
            onMarkerDrag={handleMarkerDrag}
          />
        )}
      </div>
    </div>
  );
}
