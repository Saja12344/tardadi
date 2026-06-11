# ترددي (Tardadi)

Monorepo لتطبيق تتبع الباصات: سائق، راكب، ولوحة إدارة.

## الهيكل

```
tardadi/
├── packages/shared/     # Types + constants مشتركة
├── firebase/
│   ├── firestore.rules
│   └── functions/       # REST API (Cloud Functions)
├── packages/tardadi_core/  # Flutter shared (models + API + theme)
├── apps/
│   ├── admin/              # لوحة الإدارة (Next.js)
│   ├── driver/             # تطبيق السائق (Flutter)
│   └── passenger/          # تطبيق الراكب (Flutter)
```

## البدء

```bash
npm install
cp firebase/functions/.env.example firebase/functions/.env
npm run build:shared
npm run emulators   # Firestore + Functions محلياً

# Flutter apps
cd apps/driver && flutter pub get && flutter run
cd apps/passenger && flutter pub get && flutter run
```

## API Endpoints

| Endpoint | Method | الوصف |
|---|---|---|
| `/api/routes` | GET/POST/PUT/DELETE | إدارة الخطوط |
| `/api/buses` | GET/POST/PUT/DELETE | إدارة الباصات |
| `/api/drivers` | GET/POST/PUT/DELETE | إدارة السائقين |
| `/api/auth/driver-login` | POST | دخول السائق |
| `/api/drivers/me` | GET | تعيين السائق |
| `/api/trips` | GET | الرحلات |
| `/api/trips/start` | POST | بدء رحلة |
| `/api/trips/end` | POST | إنهاء رحلة |
| `/api/gps` | POST | إرسال موقع |
| `/api/reminders` | GET/POST/DELETE | تذكيرات الراكب |

## Firestore

```
organizations/{orgId}/
  drivers/, buses/, routes/{routeId}/stops/, trips/{tripId}/gps_logs/, reminders/
```
