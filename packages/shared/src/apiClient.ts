import type { ApiResponse } from "./types";

export class TardadiApiClient {
  constructor(
    private baseUrl: string,
    private organizationId: string
  ) {}

  private async request<T>(
    path: string,
    options: RequestInit = {}
  ): Promise<T> {
    const url = new URL(path, this.baseUrl);
    url.searchParams.set("organizationId", this.organizationId);

    const response = await fetch(url.toString(), {
      ...options,
      headers: {
        "Content-Type": "application/json",
        ...options.headers,
      },
    });

    const body = (await response.json()) as ApiResponse<T>;
    if (!body.success || body.data === undefined) {
      throw new Error(body.error || `Request failed: ${response.status}`);
    }

    return body.data;
  }

  getRoutes() {
    return this.request("/api/routes");
  }

  getRoute(routeId: string) {
    return this.request(`/api/routes/${routeId}`);
  }

  getBuses(activeOnly = false) {
    const path = activeOnly ? "/api/buses?active=true" : "/api/buses";
    return this.request(path);
  }

  getDrivers() {
    return this.request("/api/drivers");
  }

  getDriverMe(driverId: string) {
    return this.request(`/api/drivers/me?driverId=${driverId}`);
  }

  driverLogin(driverCode: string, busId: string) {
    return this.request("/api/auth/driver-login", {
      method: "POST",
      body: JSON.stringify({
        organizationId: this.organizationId,
        driverCode,
        busId,
      }),
    });
  }

  getTrips(status?: string) {
    const path = status ? `/api/trips?status=${status}` : "/api/trips";
    return this.request(path);
  }

  startTrip(driverId: string, busId: string, routeId: string) {
    return this.request("/api/trips/start", {
      method: "POST",
      body: JSON.stringify({
        organizationId: this.organizationId,
        driverId,
        busId,
        routeId,
      }),
    });
  }

  endTrip(tripId: string, driverId: string) {
    return this.request("/api/trips/end", {
      method: "POST",
      body: JSON.stringify({
        organizationId: this.organizationId,
        tripId,
        driverId,
      }),
    });
  }

  sendGps(payload: {
    tripId: string;
    driverId: string;
    busId: string;
    latitude: number;
    longitude: number;
    speedKmh?: number;
    heading?: number;
  }) {
    return this.request("/api/gps", {
      method: "POST",
      body: JSON.stringify({
        organizationId: this.organizationId,
        ...payload,
      }),
    });
  }

  getReminders(userId?: string) {
    const path = userId
      ? `/api/reminders?userId=${userId}`
      : "/api/reminders";
    return this.request(path);
  }

  createReminder(payload: {
    userId: string;
    busId: string;
    routeId: string;
    stopId: string;
    fcmToken: string;
    notifyWhenMinutesAway?: number;
  }) {
    return this.request("/api/reminders", {
      method: "POST",
      body: JSON.stringify({
        organizationId: this.organizationId,
        ...payload,
      }),
    });
  }

  cancelReminder(reminderId: string) {
    return this.request(`/api/reminders/${reminderId}`, {
      method: "DELETE",
    });
  }
}
