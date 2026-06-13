# Android Setup for Shahd (Passenger App)

Use this once on your machine before running the Passenger app on Android emulator.

## 1) Install Android Studio

1. Download: https://developer.android.com/studio
2. Install and open Android Studio
3. Complete first-run setup (Standard install)

## 2) Install SDK components

In Android Studio:

1. **Settings / Preferences** → **Languages & Frameworks** → **Android SDK**
2. **SDK Platforms** tab → enable latest Android (API 34 or 35)
3. **SDK Tools** tab → enable:
   - Android SDK Build-Tools
   - Android SDK Platform-Tools
   - Android Emulator
   - Android SDK Command-line Tools
4. Apply / OK

## 3) Create an Android Virtual Device (AVD)

1. Open **Device Manager** in Android Studio
2. Click **Create Device**
3. Pick a phone (e.g. Pixel 7)
4. Pick a system image (API 34+ recommended)
5. Finish and name it (e.g. `Pixel_7_API_34`)

## 4) Point Flutter to Android SDK

```bash
flutter doctor
```

If Android SDK is not detected:

```bash
flutter config --android-sdk ~/Library/Android/sdk
flutter doctor --android-licenses
```

Accept all licenses.

## 5) Clone and run Passenger app

```bash
git clone https://github.com/Saja12344/tardadi.git
cd tardadi/apps/passenger
flutter pub get
cd ../..
npm run dev:passenger:android
```

If emulator name is custom:

```bash
ANDROID_AVD=Pixel_7_API_34 npm run dev:passenger:android
```

## Temporary fallback (no Android yet)

Run Passenger on iOS simulator instead:

```bash
npm run dev:passenger:ios
```

## Verify

```bash
flutter devices
```

You should see something like:

```
sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64 • Android ...
```

## Common issues

| Issue | Fix |
|---|---|
| `Unable to locate Android SDK` | Install Android Studio + run `flutter config --android-sdk` |
| `No Android AVD found` | Create AVD in Device Manager |
| `emulator: command not found` | Add to PATH: `~/Library/Android/sdk/emulator` |
| App can't reach API | Backend must be running: `npm run dev:backend` on Saja's machine or shared network |

## Shahd's folder to edit today

```
apps/passenger/lib/screens/map_screen.dart
```
