import type { Request, Response } from "express";
import type { ApiResponse } from "@tardadi/shared";

export function getOrgId(req: Request): string {
  return (
    (req.query.organizationId as string) ||
    (req.body?.organizationId as string) ||
    process.env.DEFAULT_ORGANIZATION_ID ||
    "demo-org"
  );
}

export function ok<T>(res: Response, data: T, status = 200): void {
  const body: ApiResponse<T> = { success: true, data };
  res.status(status).json(body);
}

export function fail(res: Response, message: string, status = 400): void {
  const body: ApiResponse<never> = { success: false, error: message };
  res.status(status).json(body);
}

export function withId<T extends Record<string, unknown>>(
  id: string,
  data: T
): T & { id: string } {
  return { id, ...data };
}
