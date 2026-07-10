#!/usr/bin/env bash
# Set iOS/Android simulator GPS. Defaults to Roshn route trip start (KAFD).
set -euo pipefail

LAT="${SIM_LAT:-24.765852}"
LNG="${SIM_LNG:-46.640424}"

if [[ -d "/Applications/Xcode.app/Contents/Developer" ]]; then
  export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
fi

if command -v xcrun >/dev/null 2>&1; then
  while IFS= read -r device_id; do
    [[ -z "$device_id" ]] && continue
    echo "iOS simulator $device_id → $LAT, $LNG"
    xcrun simctl location "$device_id" set "$LAT" "$LNG" 2>/dev/null || true
  done < <(xcrun simctl list devices booted 2>/dev/null | sed -nE 's/.*\(([A-F0-9-]+)\) \(Booted\).*/\1/p')
fi

if [[ -z "${ANDROID_HOME:-}" && -d "$HOME/Library/Android/sdk" ]]; then
  export ANDROID_HOME="$HOME/Library/Android/sdk"
fi

if [[ -n "${ANDROID_HOME:-}" ]]; then
  export PATH="$ANDROID_HOME/platform-tools:$PATH"
fi

if command -v adb >/dev/null 2>&1; then
  while IFS= read -r device_id; do
    [[ -z "$device_id" ]] && continue
    echo "Android $device_id → $LAT, $LNG"
    adb -s "$device_id" emu geo fix "$LNG" "$LAT" 2>/dev/null || true
  done < <(adb devices 2>/dev/null | awk '/emulator-/{print $1}')
fi
