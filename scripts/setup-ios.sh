#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Tardadi iOS Setup ==="

if [[ ! -d "/Applications/Xcode.app/Contents/Developer" ]]; then
  echo "Xcode is not installed."
  echo "Install Xcode from the App Store, then run this script again."
  exit 1
fi

echo "[1/4] Pointing xcode-select to Xcode.app (requires password)..."
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

echo "[2/4] Running Xcode first launch..."
sudo xcodebuild -runFirstLaunch

echo "[3/4] Installing CocoaPods (if needed)..."
if ! command -v pod >/dev/null 2>&1; then
  brew install cocoapods
fi

echo "[4/4] Installing iOS pods..."
(cd "$ROOT/apps/passenger/ios" && pod install)
(cd "$ROOT/apps/driver/ios" && pod install)

echo ""
echo "Done. Run the passenger app on iOS simulator with:"
echo "  npm run dev:passenger:ios"
