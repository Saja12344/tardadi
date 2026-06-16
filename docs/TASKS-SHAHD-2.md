# مهام شهد — المرحلة ٢ (تطبيق الراكب — مالكة كاملة)

> شهد **مسؤولة عن `apps/passenger/` بالكامل** — منطق، واجهة، أمان، وتنبيهات.  
> **الخريطة الحقيقية مؤجّلة** لحد ما المستثمرة تسوي حساب Google Cloud (أو نقرر الحل النهائي).

---

## قرار الفريق (مهم)


| الموضوع               | القرار                                                                     |
| --------------------- | -------------------------------------------------------------------------- |
| **الخريطة التفاعلية** | ⏸️ **مؤجّل** — ننتظر إيميل/حساب المستثمرة لـ Google Maps                   |
| **البديل الحين**      | صندوق «معاينة» بسيط + **قائمة الباصات** فيها كل المعلومات (مو خريطة كاملة) |
| **OpenStreetMap**     | ✅ مسموح كـ **bypass مؤقت** لاحقاً — بس **مو أولوية المرحلة ٢**             |
| **أولوية شهد**        | Logic · UI · Safety · Alerts                                               |


---

## الهدف

تطبيق راكب **يشتغل ويثق فيه** حتى بدون خريطة:

- يحمّل البيانات ويعرضها صح
- يفلتر بالخط
- يذكّرني يشتغل مع رسائل واضحة
- **كل خطأ أو حالة فاضية** لها alert/message مناسب
- كود منظم وآمن (ما فيه أسرار، معالجة أخطاء، صلاحيات)

---

## التشغيل

```bash
# Terminal 1 — Backend
cd ~/Projects/tardadi && npm run dev:backend

# Terminal 2 — Passenger (شهد)
cd ~/Projects/tardadi && npm run dev:passenger:android
```

> Android؟ → `docs/ANDROID-SETUP-SHAHD.md`

---

## المهام

### أ) تجهيز وميزانية المشروع

- **S1** `git pull` + `flutter pub get`
- **S2** تأكدي التطبيق يتصل بالـ API (Backend شغال)
- **S3** اكتبي في «ملاحظات شهد» تحت: هل Backend عندك محلياً أو على جهاز ساجا؟

---

### ب) منطق التطبيق (Logic)

- **S4** فصل `map_screen.dart` إلى ملفات أصغر:
  ```
  apps/passenger/lib/
    screens/home_screen.dart      ← الشاشة الرئيسية
    widgets/bus_card.dart
    widgets/route_filter.dart
    widgets/map_placeholder.dart  ← مكان الخريطة لاحقاً
    services/passenger_session.dart
  ```
- **S5** اربطي كل باص **باسم الخط** (مو بس `routeId` أو إحداثيات)
- **S6** فلتر الخطوط يشتغل على القائمة **و** على العداد في الأعلى
- **S7** **Pull-to-refresh** يحدّث: خطوط + باصات + رحلات
- **S8** لما السائق يوقف الرحلة → الباص **يختفي** من القائمة خلال 10 ثوانٍ (أو فوراً مع refresh)
- **S9** «ذكّرني»: اعرضي تأكيد قبل الإرسال (dialog) + رسالة نجاح/فشل واضحة

---

### ج) الواجهة (UI) — بدون خريطة كاملة

- **S10** استبدلي صندوق الخريطة بـ `**MapPlaceholder`**:
  - عنوان: «الخريطة قريباً»
  - عداد: `X باص نشط · Y خط`
  - **لا تضيفي `flutter_map` الحين** — بس placeholder جاهز للربط لاحقاً
- **S11** بطاقة الباص: اسم الباص + اسم الخط + حالة GPS (ألوان)
  - 🟠 بانتظار GPS
  - 🟢 متصل — آخر تحديث قبل X ثانية
- **S12** حالة فاضية جميلة لما ما فيه باصات (أيقونة + نص + زر تحديث)
- **S13** شاشة تحميل أول مرة (skeleton أو CircularProgressIndicator)
- **S14** RTL + خط عربي واضح — راجعي كل النصوص

---

### د) الأمان (Safety)

- **S15** أنشئي `apps/passenger/lib/config/app_config.dart`:
  - `apiBaseUrl` من `--dart-define` (مو hardcoded في الشاشة)
  - مثال تشغيل:
    ```bash
    flutter run --dart-define=API_URL=http://10.0.2.2:5001/demo-org/us-central1/api
    ```
  - **لا ترفعي** `.env` أو مفاتيح API في Git
- **S16** صلاحية الموقع: اطلبيها مرة، وإذا رفض المستخدم اعرضي banner واضح (مو crash)
- **S17** كل استدعاء API في `try/catch` — **ما فيه** `catch (_) {}` صامت بدون UI
- **S18** لا تخزني بيانات حساسة في `SharedPreferences` الحين (MVP)

---

### هـ) التنبيهات (Alerts) — لكل شي


| الحالة        | المطلوب                                                |
| ------------- | ------------------------------------------------------ |
| Backend مقفول | SnackBar أحمر: «تعذّر الاتصال — تأكدي أن السيرفر شغال» |
| لا باصات      | بطاقة رمادية + «لا توجد باصات نشطة»                    |
| لا خطوط       | «لم تُضف خطوط بعد من لوحة الإدارة»                     |
| GPS مرفوض     | Banner برتقالي ثابت أعلى الشاشة                        |
| ذكّرني نجح    | SnackBar أخضر                                          |
| ذكّرني فشل    | SnackBar أحمر + سبب مختصر                              |
| تحديث يدوي    | مؤشر تحميل صغير أثناء الـ refresh                      |


- **S19** نفّذي الجدول فوق — كل حالة لها UI
- **S20** أنشئي `widgets/app_alert.dart` أو helper واحد لـ SnackBar موحّد (لون + مدة + نص عربي)

---

### و) اختبار مع ساجا (بدون خريطة)

- **S21** ساجا: خط + باص + سائق من الأدمن
- **S22** ساجا: السائق يبدأ رحلة
- **S23** أنتِ: الباص يظهر في **القائمة** مع حالة GPS
- **S24** أنتِ: ذكّرني → dialog → نجاح
- **S25** ساجا: إنهاء الرحلة → الباص يختفي عندك
- **S26** سجّلي 3 ملاحظات في الجدول تحت

---

## الملفات — ملك شهد

```
apps/passenger/
  lib/
    main.dart
    config/app_config.dart
    screens/home_screen.dart
    widgets/
    services/
  pubspec.yaml
  test/                    ← أضيفي اختبار بسيط إذا قدرتي
```

**اقرئي فقط** (تعديل بموافقة ساجا):

```
packages/tardadi_core/
firebase/functions/
apps/admin/
apps/driver/
```

---

## لا تلمسين

- `firebase/functions/` — إلا لو bug واضح واتفقتوا
- `apps/admin/` · `apps/driver/`
- إعداد Google Maps / `GOOGLE_MAPS_API_KEY` — **هذا شغل المستثمرة + ساجا**

---

## خلصتِ لما…

1. التطبيق منظم (ملفات منفصلة)
2. كل حالة فيها alert/UI واضح
3. القائمة + الفلتر + ذكّرني يشتغلون بدون خريطة
4. `app_config` آمن (dart-define)
5. اختبار S21–S25 ناجح

---

## مؤجّل — المرحلة ٣ (بعد حساب المستثمرة)

- خريطة `flutter_map` + OpenStreetMap/Carto (مجاني)
- أو Google Maps إذا المستثمرة فعّلت الحساب
- خط المسار يتبع الطرق
- اختيار محطة للتذكير
- Push notifications حقيقية

> **ملاحظة للمستثمرة:** للـ MVP الحالي **ما نحتاج Google**. OpenStreetMap يكفي للخريطة لاحقاً بـ $0. Google = نتائج بحث أحسن بس مو ضروري الحين.

---

## ملاحظات شهد


| #   | الملاحظة     | الحالة |
| --- | ------------ | ------ |
| 1   | Backend عند: |        |
| 2   |              |        |
| 3   |              |        |


---

## مرجع — `MapPlaceholder` (مؤقت)

```dart
// widgets/map_placeholder.dart — بديل الخريطة لحد المرحلة ٣
class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({
    super.key,
    required this.activeBusCount,
    required this.routeCount,
  });

  final int activeBusCount;
  final int routeCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TardadiBrand.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TardadiBrand.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🗺️ الخريطة — قريباً', style: TextStyle(
            color: TardadiBrand.orange, fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          Text('$activeBusCount باص نشط · $routeCount خط',
            style: const TextStyle(color: TardadiBrand.grey)),
          const Spacer(),
          const Text('تتبّع الباصات من القائمة تحت',
            style: TextStyle(color: TardadiBrand.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
```

