import type { ApiResponse } from "./types";

export class TardadiApiClient {
  constructor(
    private baseUrl: string,
    private organizationId: string
  ) {}

  private buildUrl(path: string, extraQuery?: Record<string, string>): string {
    const base = this.baseUrl.replace(/\/$/, "");
    const [pathname, search = ""] = path.split("?");
    const params = new URLSearchParams(search);
    params.set("organizationId", this.organizationId);

    if (extraQuery) {
      for (const [key, value] of Object.entries(extraQuery)) {
        params.set(key, value);
      }
    }

    return `${base}${pathname}?${params.toString()}`;
  }

  private async request<T>(
    path: string,
    options: RequestInit = {},
    extraQuery?: Record<string, string>
  ): Promise<T> {
    const response = await fetch(this.buildUrl(path, extraQuery), {
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
    return this.request(
      "/api/buses",
      {},
      activeOnly ? { active: "true" } : undefined
    );
  }

  getDrivers() {
    return this.request("/api/drivers");
  }

  getDriverMe(driverId: string) {
    return this.request("/api/drivers/me", {}, { driverId });
  }

  driverLogin(phone: string) {
    return this.request("/api/auth/driver-login", {
      method: "POST",
      body: JSON.stringify({
        organizationId: this.organizationId,
        phone,
      }),
    });
  }

  getTrips(status?: string) {
    return this.request(
      "/api/trips",
      {},
      status ? { status } : undefined
    );
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
    return this.request(
      "/api/reminders",
      {},
      userId ? { userId } : undefined
    );
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
