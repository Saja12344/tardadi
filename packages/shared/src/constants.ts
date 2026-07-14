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
  /** Primary tenant collection — each doc is a Business workspace. */
  businesses: "businesses",
  /** @deprecated Alias for businesses — used during migration. */
  organizations: "businesses",
  adminUsers: "admin_users",
  drivers: "drivers",
  buses: "buses",
  routes: "routes",
  stops: "stops",
  trips: "trips",
  gpsLogs: "gps_logs",
  reminders: "reminders",
} as const;

export function businessPath(businessId: string): string {
  return `${COLLECTIONS.businesses}/${businessId}`;
}

export function businessSubcollection(
  businessId: string,
  subcollection: string
): string {
  return `${businessPath(businessId)}/${subcollection}`;
}

/** @deprecated Use businessPath */
export function orgPath(organizationId: string): string {
  return businessPath(organizationId);
}

/** @deprecated Use businessSubcollection */
export function orgSubcollection(
  organizationId: string,
  subcollection: string
): string {
  return businessSubcollection(organizationId, subcollection);
}
