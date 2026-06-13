#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ANDROID_AVD="${ANDROID_AVD:-}"

cd "$ROOT/apps/passenger"
flutter pub get

if ! command -v emulator >/dev/null 2>&1; then
  if [[ -x "$HOME/Library/Android/sdk/emulator/emulator" ]]; then
    export PATH="$HOME/Library/Android/sdk/emulator:$HOME/Library/Android/sdk/platform-tools:$PATH"
  fi
fi

if ! command -v emulator >/dev/null 2>&1; then
  echo "Android SDK not found."
  echo "Install Android Studio, create an AVD, then rerun this script."
  echo "Temporary fallback: run passenger on a second iOS simulator instead:"
  echo "  npm run dev:passenger:ios"
  exit 1
fi

if [[ -z "$ANDROID_AVD" ]]; then
  ANDROID_AVD="$(emulator -list-avds | head -1)"
fi

if [[ -z "$ANDROID_AVD" ]]; then
  echo "No Android AVD found. Create one in Android Studio > Device Manager."
  exit 1
fi

echo "Starting Android emulator: $ANDROID_AVD"
emulator -avd "$ANDROID_AVD" >/dev/null 2>&1 &
sleep 8

flutter run -d android
