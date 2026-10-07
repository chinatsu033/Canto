#!/usr/bin/env bash
# Usage: packaging/package_macos.sh <arm64|x86>  (after `flutter build macos --release`)
set -euo pipefail
ARCH="$1"
VERSION="$(grep '^version:' pubspec.yaml | sed 's/version: //; s/+.*//')"
APP=build/macos/Build/Products/Release/Canto.app
mkdir -p dist
# Unsigned build: ad-hoc signature only (users must right-click > Open once).
codesign --force --deep --sign - "$APP"
STAGE="$(mktemp -d)"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"
hdiutil create -volname "Canto" -srcfolder "$STAGE" -ov -format UDZO "dist/Canto-$VERSION-macos-$ARCH.dmg"
ls -la dist
