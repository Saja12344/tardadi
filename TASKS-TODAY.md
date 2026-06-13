# Tardadi — Today's Tasks

## Setup (run once, shared)

Open **4 terminals**:

```bash
# Terminal 1 — Backend
cd ~/Projects/tardadi
chmod +x scripts/*.sh
./scripts/dev-backend.sh

# Terminal 2 — Admin panel
cd ~/Projects/tardadi
npm run dev:admin

# Terminal 3 — Driver app (Saja, iOS)
cd ~/Projects/tardadi
npm run dev:driver:ios

# Terminal 4 — Passenger app (Shahd, Android)
cd ~/Projects/tardadi
npm run dev:passenger:android
```

> If Android emulator is not installed yet, Shahd can temporarily use:
> `npm run dev:passenger:ios` (second iOS simulator)

---

## Saja — Driver App (iOS Simulator)

**Goal:** Admin data works → Driver can log in → start trip → send GPS

### Tasks

- [ ] **T1** Start Firebase emulators and confirm API health at `/api/health`
- [ ] **T2** Open Admin panel (`http://localhost:3000`) and create:
  - 1 route
  - 1 bus
  - 1 driver assigned to that route + bus
- [ ] **T3** Copy `busId` and `driverCode` from Admin/Firestore
- [ ] **T4** Run Driver app on **iOS simulator** (`npm run dev:driver:ios`)
- [ ] **T5** Log in with `driverCode` + `busId`
- [ ] **T6** Verify assigned route and stops appear on map screen
- [ ] **T7** Tap **Start Trip** and confirm GPS sends every 5 seconds
- [ ] **T8** Check Admin **Trips** page shows active trip
- [ ] **T9** Tap **End Trip** and confirm trip status becomes `ended`

### Files to work in

```
apps/driver/lib/screens/login_screen.dart
apps/driver/lib/screens/map_screen.dart
```

### Done when

Driver login works, trip starts, GPS updates `lastSeenAt` on the bus.

---

## Shahd — Passenger App (Android Emulator)

**Goal:** See active buses on screen → filter by route → create reminder

### Tasks

- [ ] **T1** Clone repo: `git clone https://github.com/Saja12344/tardadi.git`
- [ ] **T2** Install Flutter deps: `cd apps/passenger && flutter pub get`
- [ ] **T3** Run Passenger app on **Android emulator** (`npm run dev:passenger:android`)
  - If Android SDK missing: install Android Studio + create AVD first
  - Temporary fallback: `npm run dev:passenger:ios`
- [ ] **T4** Allow location permission on app launch
- [ ] **T5** Confirm active buses list loads from API
- [ ] **T6** Test route filter chips (All + each route)
- [ ] **T7** When Saja starts a trip, verify bus location updates on Passenger screen
- [ ] **T8** Tap **Remind me** on an active bus and confirm success message
- [ ] **T9** Note any UI issues for map screen (real map comes later)

### Files to work in

```
apps/passenger/lib/screens/map_screen.dart
packages/tardadi_core/lib/src/api/tardadi_api.dart   # read only unless API change needed
```

### Done when

Passenger sees active bus after Driver starts trip, filter works, reminder button succeeds.

---

## End-of-day test (both together, 10 min)

1. Saja: Admin creates route + bus + driver
2. Saja: Driver logs in → Start Trip
3. Shahd: Passenger refreshes → bus appears with location
4. Shahd: Tap Remind me
5. Saja: End Trip → bus disappears from active list

---

## Do NOT touch today

- `apps/driver/android/`, `ios/`, `macos/`, `web/` (auto-generated)
- `firebase/functions/` unless API bug found
- Push notifications / real map (later sprint)
