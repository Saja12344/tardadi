#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "=== Tardadi Dev Setup ==="

echo "[1/4] npm install..."
npm install

echo "[2/4] build shared + functions..."
npm run build:shared
npm run build:functions

echo "[3/4] flutter pub get (driver + passenger + core)..."
(cd packages/tardadi_core && flutter pub get)
(cd apps/driver && flutter pub get)
(cd apps/passenger && flutter pub get)

echo "[4/4] flutter doctor..."
flutter doctor

echo ""
echo "Done. Next:"
echo "  Terminal 1: npm run dev:backend"
echo "  Terminal 2: npm run dev:admin"
echo "  Terminal 3: npm run dev:driver:ios      (Saja)"
echo "  Terminal 4: npm run dev:passenger:android (Shahd)"
