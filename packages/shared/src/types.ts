import type { AdminRole } from "./rbac";

export type EntityStatus = "active" | "inactive";
export type TripStatus = "scheduled" | "active" | "ended";
export type ReminderStatus = "active" | "triggered" | "cancelled";
export type AccessMode = "public" | "private";

export interface GeoPoint {
  latitude: number;
  longitude: number;
}

/** Named place with coordinates — used for route from/to endpoints. */
export interface LocationPlace {
  address: string;
  latitude: number;
  longitude: number;
}

/** Transportation company workspace (Roshn, SAPTCO, etc.). */
export interface Business {
  businessId: string;
  name: string;
  logo?: string | null;
  status: EntityStatus;
  adminUserId?: string | null;
  createdAt?: string;
  updatedAt?: string;
}

/** @deprecated Use Business — kept for mobile app backward compatibility. */
export interface Organization {
  organizationId: string;
  name: string;
  type: string;
  accessMode: AccessMode;
  status: EntityStatus;
  createdAt?: string;
  updatedAt?: string;
}

export interface BusinessListItem extends Business {
  adminName?: string | null;
  adminPhone?: string | null;
  driverCount: number;
  busCount: number;
  routeCount: number;
  stationCount: number;
}

export interface BusinessStats {
  businessId: string;
  driverCount: number;
  busCount: number;
  routeCount: number;
  stationCount: number;
  todayTripCount: number;
}

export interface AdminUser {
  userId: string;
  name: string;
  phone: string;
  role: AdminRole;
  businessId: string | null;
  status: EntityStatus;
  createdAt?: string;
  updatedAt?: string;
}

export interface AdminSession {
  userId: string;
  name: string;
  phone: string;
  role: AdminRole;
  businessId: string | null;
}

export interface AdminLoginRequest {
  phone: string;
  password: string;
}

export interface AdminLoginResponse {
  token: string;
  user: AdminSession;
}

export interface CreateBusinessRequest {
  name: string;
  logo?: string | null;
  status?: EntityStatus;
  adminName: string;
  adminPhone: string;
  adminPassword: string;
}

export interface UpdateBusinessRequest {
  name?: string;
  logo?: string | null;
  status?: EntityStatus;
  adminName?: string;
  adminPhone?: string;
  adminPassword?: string;
}

export interface Driver {
  driverId: string;
  businessId: string;
  /** @deprecated Use businessId */
  organizationId: string;
  name: string;
  phone: string;
  driverCode?: string;
  assignedRouteId?: string;
  assignedBusId?: string;
  status: EntityStatus;
  createdAt?: string;
  updatedAt?: string;
}

export interface Bus {
  busId: string;
  businessId: string;
  /** @deprecated Use businessId */
  organizationId: string;
  plateNo: string;
  label: string;
  status: EntityStatus;
  currentTripId?: string | null;
  currentLocation?: GeoPoint | null;
  lastSeenAt?: string | null;
  lastArrivedAt?: string | null;
  lastArrivedStopId?: string | null;
  crowdLevel?: string | null;
  createdAt?: string;
  updatedAt?: string;
}

export interface Route {
  routeId: string;
  businessId: string;
  /** @deprecated Use businessId */
  organizationId: string;
  name: string;
  code: string;
  colorHex: string;
  status: EntityStatus;
  accessMode?: AccessMode;
  fromLocation?: LocationPlace | null;
  toLocation?: LocationPlace | null;
  polyline?: string;
  createdAt?: string;
  updatedAt?: string;
}

export interface Stop {
  stopId: string;
  routeId: string;
  name: string;
  latitude: number;
  longitude: number;
  sequenceNo: number;
  geofenceRadiusM?: number;
  status: EntityStatus;
  createdAt?: string;
  updatedAt?: string;
}

export interface Trip {
  tripId: string;
  businessId: string;
  /** @deprecated Use businessId */
  organizationId: string;
  busId: string;
  driverId: string;
  routeId: string;
  tripStatus: TripStatus;
  startedAt?: string | null;
  endedAt?: string | null;
  createdAt?: string;
  updatedAt?: string;
}

export interface GpsLog {
  gpsLogId: string;
  tripId: string;
  latitude: number;
  longitude: number;
  speedKmh?: number;
  heading?: number;
  capturedAt: string;
}

export interface Reminder {
  reminderId: string;
  businessId: string;
  /** @deprecated Use businessId */
  organizationId: string;
  userId: string;
  busId: string;
  routeId: string;
  stopId: string;
  fcmToken: string;
  status: ReminderStatus;
  notifyWhenMinutesAway: number;
  createdAt?: string;
  updatedAt?: string;
}

export interface DriverLoginRequest {
  organizationId: string;
  phone: string;
}

export interface DriverLoginResponse {
  driver: Driver;
  bus: Bus;
  route: Route;
  stops: Stop[];
}

export interface StartTripRequest {
  organizationId: string;
  driverId: string;
  busId: string;
  routeId: string;
}

export interface EndTripRequest {
  organizationId: string;
  tripId: string;
  driverId: string;
}

export interface GpsUpdateRequest {
  organizationId: string;
  tripId: string;
  driverId: string;
  busId: string;
  latitude: number;
  longitude: number;
  speedKmh?: number;
  heading?: number;
}

export interface CreateReminderRequest {
  organizationId: string;
  userId: string;
  busId: string;
  routeId: string;
  stopId: string;
  fcmToken: string;
  notifyWhenMinutesAway?: number;
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
}
