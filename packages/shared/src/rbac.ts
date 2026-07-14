/** Admin roles — extend here for future roles (dispatcher, station_manager, etc.). */
export type AdminRole = "super_admin" | "business_admin";

export const ADMIN_ROLES = {
  SUPER_ADMIN: "super_admin" as const,
  BUSINESS_ADMIN: "business_admin" as const,
};

/** Permission keys — checked by RBAC middleware on the backend. */
export type Permission =
  | "businesses:create"
  | "businesses:read"
  | "businesses:update"
  | "businesses:delete"
  | "businesses:disable"
  | "businesses:assign_admin"
  | "drivers:read"
  | "drivers:write"
  | "buses:read"
  | "buses:write"
  | "routes:read"
  | "routes:write"
  | "trips:read"
  | "trips:write"
  | "stats:read_all";

const ROLE_PERMISSIONS: Record<AdminRole, readonly Permission[]> = {
  super_admin: [
    "businesses:create",
    "businesses:read",
    "businesses:update",
    "businesses:delete",
    "businesses:disable",
    "businesses:assign_admin",
    "drivers:read",
    "drivers:write",
    "buses:read",
    "buses:write",
    "routes:read",
    "routes:write",
    "trips:read",
    "trips:write",
    "stats:read_all",
  ],
  business_admin: [
    "drivers:read",
    "drivers:write",
    "buses:read",
    "buses:write",
    "routes:read",
    "routes:write",
    "trips:read",
    "trips:write",
  ],
};

export function roleHasPermission(
  role: AdminRole,
  permission: Permission
): boolean {
  return ROLE_PERMISSIONS[role].includes(permission);
}

export function assertPermission(
  role: AdminRole,
  permission: Permission
): void {
  if (!roleHasPermission(role, permission)) {
    throw new Error("Forbidden");
  }
}
