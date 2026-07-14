import type { Request, Response, NextFunction } from "express";
import type { AdminRole, AdminSession, Permission } from "@tardadi/shared";
import { roleHasPermission } from "@tardadi/shared";
import { getJwtSecret, verifyJwt } from "./crypto";

export interface AdminAuthContext extends AdminSession {
  userId: string;
}

declare global {
  namespace Express {
    interface Request {
      adminAuth?: AdminAuthContext | null;
    }
  }
}

export class HttpError extends Error {
  constructor(
    message: string,
    readonly status: number
  ) {
    super(message);
    this.name = "HttpError";
  }
}

function extractBearer(req: Request): string | null {
  const header = req.headers.authorization;
  if (!header?.startsWith("Bearer ")) return null;
  return header.slice(7).trim() || null;
}

export function parseAdminAuth(req: Request): AdminAuthContext | null {
  const token = extractBearer(req);
  if (!token) return null;

  const payload = verifyJwt(token, getJwtSecret());
  if (!payload) return null;

  return {
    userId: payload.sub,
    name: payload.name,
    phone: payload.phone,
    role: payload.role as AdminRole,
    businessId: payload.businessId,
  };
}

/** Attach adminAuth to request when a valid JWT is present. */
export function attachAdminAuth(
  req: Request,
  _res: Response,
  next: NextFunction
): void {
  req.adminAuth = parseAdminAuth(req);
  next();
}

/** Require a valid admin JWT. */
export function requireAdminAuth(
  req: Request,
  res: Response,
  next: NextFunction
): void {
  const auth = parseAdminAuth(req);
  if (!auth) {
    res.status(401).json({
      success: false,
      error: "يجب تسجيل الدخول للوصول لهذا الطلب.",
    });
    return;
  }
  req.adminAuth = auth;
  next();
}

/** Require admin JWT + specific permission(s). */
export function requirePermission(...permissions: Permission[]) {
  return (req: Request, res: Response, next: NextFunction): void => {
    const auth = req.adminAuth ?? parseAdminAuth(req);
    if (!auth) {
      res.status(401).json({
        success: false,
        error: "يجب تسجيل الدخول للوصول لهذا الطلب.",
      });
      return;
    }

    const allowed = permissions.some((p) => roleHasPermission(auth.role, p));
    if (!allowed) {
      res.status(403).json({
        success: false,
        error: "ليس لديك صلاحية لهذا الإجراء.",
      });
      return;
    }

    req.adminAuth = auth;
    next();
  };
}

/** Require admin JWT when present; validate permission. Allow unauthenticated legacy clients. */
export function optionalAdminWithPermission(...permissions: Permission[]) {
  return (req: Request, res: Response, next: NextFunction): void => {
    const auth = parseAdminAuth(req);
    if (!auth) {
      req.adminAuth = null;
      next();
      return;
    }

    const allowed = permissions.some((p) => roleHasPermission(auth.role, p));
    if (!allowed) {
      res.status(403).json({
        success: false,
        error: "ليس لديك صلاحية لهذا الإجراء.",
      });
      return;
    }

    req.adminAuth = auth;
    next();
  };
}

export function requireSuperAdmin(
  req: Request,
  res: Response,
  next: NextFunction
): void {
  const auth = req.adminAuth ?? parseAdminAuth(req);
  if (!auth) {
    res.status(401).json({
      success: false,
      error: "يجب تسجيل الدخول للوصول لهذا الطلب.",
    });
    return;
  }
  if (auth.role !== "super_admin") {
    res.status(403).json({
      success: false,
      error: "هذا الإجراء متاح لمدير النظام فقط.",
    });
    return;
  }
  req.adminAuth = auth;
  next();
}
