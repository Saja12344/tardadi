export type EntityStatus = "active" | "inactive";
export type TripStatus = "scheduled" | "active" | "ended";
export type ReminderStatus = "active" | "triggered" | "cancelled";
export type AccessMode = "public" | "private";

export interface GeoPoint {
  latitude: number;
  longitude: number;
}

export interface Organization {
  organizationId: string;
  name: string;
  type: string;
  accessMode: AccessMode;
  status: EntityStatus;
  createdAt?: string;
  updatedAt?: string;
}

export interface Driver {
  driverId: string;
  organizationId: string;
  driverCode: string;
  name: string;
  phone?: string;
  assignedRouteId?: string;
  assignedBusId?: string;
  status: EntityStatus;
  createdAt?: string;
  updatedAt?: string;
}

export interface Bus {
  busId: string;
  organizationId: string;
  plateNo: string;
  label: string;
  status: EntityStatus;
  currentTripId?: string | null;
  currentLocation?: GeoPoint | null;
  lastSeenAt?: string | null;
  createdAt?: string;
  updatedAt?: string;
}

export interface Route {
  routeId: string;
  organizationId: string;
  name: string;
  code: string;
  colorHex: string;
  status: EntityStatus;
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
  driverCode: string;
  busId: string;
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
