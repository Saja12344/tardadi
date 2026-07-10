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

cd "$ROOT/apps/driver"
flutter pub get

if ! command -v emulator >/dev/null 2>&1; then
  echo "Android emulator not found."
  exit 1
fi

if ! adb devices 2>/dev/null | grep -q "emulator"; then
  echo "Starting Android emulator: $ANDROID_AVD"
  nohup emulator -avd "$ANDROID_AVD" -no-snapshot-load >/tmp/tardadi-emulator.log 2>&1 &
  adb wait-for-device
fi

DEVICE_ID="$(adb devices 2>/dev/null | awk '/emulator-/{print $1; exit}')"

if [[ -z "$DEVICE_ID" ]]; then
  echo "No Android emulator device found."
  exit 1
fi

echo "Running Driver app on $DEVICE_ID"
bash "$ROOT/scripts/set-sim-location.sh"

flutter run -d "$DEVICE_ID"
