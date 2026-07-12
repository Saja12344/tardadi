#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ANDROID_AVD="${ANDROID_AVD:-Tardadi_Passenger}"

if [[ -z "${ANDROID_HOME:-}" ]]; then
  if [[ -d "$HOME/Library/Android/sdk" ]]; then
    export ANDROID_HOME="$HOME/Library/Android/sdk"
  elif [[ -d "/opt/homebrew/share/android-commandlinetools" ]]; then
    export ANDROID_HOME="/opt/homebrew/share/android-commandlinetools"
  fi
fi

if [[ -n "${ANDROID_HOME:-}" ]]; then
  export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
fi

cd "$ROOT/apps/passenger"
flutter pub get

if ! command -v emulator >/dev/null 2>&1; then
  echo "Android emulator not found."
  echo "Run: brew install --cask android-studio android-commandlinetools"
  echo "Fallback: npm run dev:passenger:ios"
  exit 1
fi

# Prefer an explicitly set AVD, then a real installed AVD matching the
# default name, otherwise the first available emulator.
if ! emulator -list-avds 2>/dev/null | grep -qx "$ANDROID_AVD"; then
  if emulator -list-avds 2>/dev/null | grep -qx "Tardadi_Passenger"; then
    ANDROID_AVD="Tardadi_Passenger"
  else
    ANDROID_AVD="$(emulator -list-avds 2>/dev/null | head -1 || true)"
  fi
fi

if [[ -z "$ANDROID_AVD" ]]; then
  echo "No Android AVD found. Create one with:"
  echo "  avdmanager create avd -n Tardadi_Passenger -k \"system-images;android-34;google_apis;arm64-v8a\" -d pixel_7"
  exit 1
fi

# Prefer a physical Android/Huawei device when one is connected.
PHYSICAL_ID="$(adb devices 2>/dev/null | awk '/\tdevice$/{print $1}' | grep -v '^emulator-' | head -1 || true)"

if [[ -n "$PHYSICAL_ID" ]]; then
  echo "Running passenger app on device $PHYSICAL_ID"
  flutter run -d "$PHYSICAL_ID"
  exit 0
fi

if ! adb devices 2>/dev/null | grep -qE '^emulator-'; then
  echo "Starting Android emulator: $ANDROID_AVD"
  nohup emulator -avd "$ANDROID_AVD" -no-snapshot-load >/tmp/tardadi-emulator.log 2>&1 &
fi

echo "Waiting for Android emulator to boot..."
adb wait-for-device
for _ in $(seq 1 60); do
  booted="$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')"
  if [[ "$booted" == "1" ]]; then
    break
  fi
  sleep 2
done

DEVICE_ID="$(adb devices | awk '/^emulator-/{print $1; exit}')"
if [[ -z "$DEVICE_ID" ]]; then
  echo "No Android emulator detected after boot."
  exit 1
fi

echo "Running passenger app on $DEVICE_ID"
flutter run -d "$DEVICE_ID"
