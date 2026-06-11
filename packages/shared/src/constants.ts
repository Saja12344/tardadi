export const BRAND = {
  orange: "#FF6B00",
  navy: "#1A2744",
  white: "#FFFFFF",
  grey: "#9CA3AF",
} as const;

export const GPS_INTERVAL_MS = {
  moving: 5_000,
  idle: 30_000,
} as const;

export const GEOFENCE_MAX_DISTANCE_M = 500;
export const DEFAULT_REMINDER_MINUTES = 5;

export const COLLECTIONS = {
  organizations: "organizations",
  drivers: "drivers",
  buses: "buses",
  routes: "routes",
  stops: "stops",
  trips: "trips",
  gpsLogs: "gps_logs",
  reminders: "reminders",
} as const;

export function orgPath(organizationId: string): string {
  return `${COLLECTIONS.organizations}/${organizationId}`;
}

export function orgSubcollection(
  organizationId: string,
  subcollection: string
): string {
  return `${orgPath(organizationId)}/${subcollection}`;
}
