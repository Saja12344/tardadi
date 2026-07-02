#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IOS_DEVICE_NAME="${IOS_DEVICE_NAME:-iPhone 17}"
IOS_DEVICE_ID="${IOS_DEVICE_ID:-}"

if [[ -d "/Applications/Xcode.app/Contents/Developer" ]]; then
  export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
fi

export PATH="$ROOT/scripts/ios-bin:$PATH"

cd "$ROOT/apps/passenger"
flutter pub get

if [[ -d ios ]]; then
  (cd ios && pod install)
fi

if [[ -z "$IOS_DEVICE_ID" ]]; then
  IOS_DEVICE_ID="$(xcrun simctl list devices available \
    | grep "$IOS_DEVICE_NAME (" \
    | head -1 \
    | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')"
fi

if [[ -z "$IOS_DEVICE_ID" ]]; then
  echo "Could not find iOS simulator: $IOS_DEVICE_NAME"
  echo "Available simulators:"
  xcrun simctl list devices available | grep -E 'iPhone|iPad' || true
  exit 1
fi

echo "Booting iOS simulator: $IOS_DEVICE_NAME ($IOS_DEVICE_ID)"
xcrun simctl boot "$IOS_DEVICE_ID" 2>/dev/null || true
open -a Simulator --args -CurrentDeviceUDID "$IOS_DEVICE_ID"

flutter run -d "$IOS_DEVICE_ID"
