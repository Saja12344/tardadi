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

const ERROR_MESSAGES: Array<[RegExp, string]> = [
  [/driverId is required/i, "معرّف السائق مطلوب."],
  [/driver not found/i, "لم نجد هذا السائق."],
  [/name and phone are required/i, "اكتب اسم السائق ورقم جواله."],
  [/route not found/i, "لم نجد هذا الخط."],
  [/name and code are required/i, "اكتب اسم الخط وكوده."],
  [/fromLocation .* required/i, "حدّد نقطة بداية الخط."],
  [/toLocation .* required/i, "حدّد نقطة نهاية الخط."],
  [/phone is required/i, "اكتب رقم الجوال."],
  [/plateNo and label are required/i, "اكتب رقم اللوحة واسم الباص."],
  [
    /userId, busId, routeId, stopId, and fcmToken are required/i,
    "بيانات التنبيه غير مكتملة.",
  ],
  [
    /tripId, driverId, busId, latitude, and longitude are required/i,
    "بيانات موقع الباص غير مكتملة.",
  ],
  [/trip not found/i, "لم نجد هذه الرحلة."],
  [/driverId, busId, and routeId are required/i, "اختر السائق والباص والخط قبل بدء الرحلة."],
  [/tripId and driverId are required/i, "بيانات إنهاء الرحلة غير مكتملة."],
];

function toUserMessage(message: string, status: number): string {
  for (const [pattern, userMessage] of ERROR_MESSAGES) {
    if (pattern.test(message)) return userMessage;
  }

  if (status >= 500) {
    return "صار خطأ في الخادم. حاول مرة أخرى.";
  }

  return message || "صار خطأ غير متوقع. حاول مرة أخرى.";
}

export function fail(res: Response, message: string, status = 400): void {
  const body: ApiResponse<never> = {
    success: false,
    error: toUserMessage(message, status),
  };
  res.status(status).json(body);
}

export function withId<T extends Record<string, unknown>>(
  id: string,
  data: T
): T & { id: string } {
  return { id, ...data };
}
