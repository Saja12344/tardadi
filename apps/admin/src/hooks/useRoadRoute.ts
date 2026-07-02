"use client";

import { useEffect, useState } from "react";
import type { LocationPlace } from "@tardadi/shared";
import { getUserErrorMessage } from "@/lib/errorMessage";

type RoadRouteState = {
  coordinates: [number, number][];
  distanceMeters: number;
  durationSeconds: number;
  polyline: string;
};

export function useRoadRoute(
  from: LocationPlace | null,
  to: LocationPlace | null
) {
  const [roadRoute, setRoadRoute] = useState<RoadRouteState | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    if (!from || !to) {
      setRoadRoute(null);
      setError("");
      return;
    }

    const controller = new AbortController();
    setLoading(true);
    setError("");

    fetch("/api/routing/route", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ from, to }),
      signal: controller.signal,
    })
      .then(async (response) => {
        const data = await response.json();
        if (!response.ok) throw new Error(data.error || "Routing failed");
        setRoadRoute(data as RoadRouteState);
      })
      .catch((e) => {
        if ((e as Error).name === "AbortError") return;
        setRoadRoute(null);
        setError(getUserErrorMessage(e));
      })
      .finally(() => setLoading(false));

    return () => controller.abort();
  }, [from, to]);

  return { roadRoute, loading, error };
}

export function formatDistance(meters: number): string {
  if (meters >= 1000) return `${(meters / 1000).toFixed(1)} كم`;
  return `${Math.round(meters)} م`;
}

export function formatDuration(seconds: number): string {
  const mins = Math.round(seconds / 60);
  if (mins < 60) return `${mins} د`;
  const h = Math.floor(mins / 60);
  const m = mins % 60;
  return m > 0 ? `${h} س ${m} د` : `${h} س`;
}
