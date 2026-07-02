const MESSAGE_MAP: Array<[RegExp, string]> = [
  [
    /backend unreachable|failed to fetch|networkerror|load failed|fetch failed/i,
    "تعذّر الاتصال بالخادم. تأكد أن الباكند شغال ثم حدّث الصفحة.",
  ],
  [/forbidden resource/i, "ليس لديك صلاحية للوصول لهذا الطلب."],
  [/request failed|internal|server error/i, "صار خطأ في الخادم. حاول مرة أخرى."],
  [/invalid json/i, "الطلب غير صحيح. حدّث الصفحة وحاول مرة أخرى."],
  [/invalid coordinates/i, "إحداثيات الموقع غير صحيحة. اختر الموقع من الخريطة مرة أخرى."],
  [/from and to locations are required/i, "حدّد نقطة البداية ونقطة النهاية."],
  [/routing service unavailable|routing failed/i, "تعذّر حساب المسار الآن. حاول مرة أخرى."],
  [/no road route found/i, "لم نجد مسار طريق بين النقطتين. جرّب اختيار نقاط أقرب للطريق."],
  [/placeId required/i, "اختر نتيجة موقع من القائمة أولًا."],
  [/place not found/i, "لم نتمكن من العثور على هذا الموقع. جرّب البحث مرة أخرى."],
  [/google places search failed|geocoding search failed/i, "تعذّر البحث عن الموقع. حاول مرة أخرى."],
  [/requires google_maps_api_key/i, "البحث المتقدم يحتاج مفتاح Google Maps API."],
  [/name and code are required/i, "اكتب اسم الخط وكوده."],
  [/plateNo and label are required/i, "اكتب رقم اللوحة واسم الباص."],
  [/name and phone are required/i, "اكتب اسم السائق ورقم جواله."],
  [/driver not found/i, "لم نجد هذا السائق."],
  [/route not found/i, "لم نجد هذا الخط."],
  [/trip not found/i, "لم نجد هذه الرحلة."],
];

export function getUserErrorMessage(error: unknown): string {
  const raw =
    error instanceof Error
      ? error.message
      : typeof error === "string"
        ? error
        : "";

  for (const [pattern, message] of MESSAGE_MAP) {
    if (pattern.test(raw)) return message;
  }

  return raw.trim() || "صار خطأ غير متوقع. حاول مرة أخرى.";
}
