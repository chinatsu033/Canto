#!/usr/bin/env bash
# Usage: packaging/package_linux.sh <x86|arm64>   (after `flutter build linux --release`)
set -euo pipefail
ARCH="$1"
VERSION="$(grep '^version:' pubspec.yaml | sed 's/version: //; s/+.*//')"
case "$ARCH" in
  x86) DEB_ARCH=amd64; BUILD_DIR=build/linux/x64/release/bundle; AI_ARCH=x86_64 ;;
  arm64) DEB_ARCH=arm64; BUILD_DIR=build/linux/arm64/release/bundle; AI_ARCH=aarch64 ;;
  *) echo "unknown arch $ARCH" >&2; exit 1 ;;
esac
mkdir -p dist
DESKTOP='[Desktop Entry]
Type=Application
Name=Canto
Comment=Lyrics for whatever is playing
Exec=canto
Icon=canto
Categories=AudioVideo;Audio;
Terminal=false
StartupWMClass=io.github.chinatsu033.canto'

# --- deb ---
STAGE="$(mktemp -d)"
mkdir -p "$STAGE/DEBIAN" "$STAGE/opt/Canto" "$STAGE/usr/bin" "$STAGE/usr/share/applications" \
  "$STAGE/usr/share/icons/hicolor/512x512/apps"
cp -r "$BUILD_DIR"/. "$STAGE/opt/Canto/"
ln -s /opt/Canto/Canto "$STAGE/usr/bin/canto"
echo "$DESKTOP" > "$STAGE/usr/share/applications/canto.desktop"
cp assets/icon/canto_512.png "$STAGE/usr/share/icons/hicolor/512x512/apps/canto.png"
cat > "$STAGE/DEBIAN/control" <<CTL
Package: canto
Version: $VERSION
Architecture: $DEB_ARCH
Maintainer: chinatsu033 <noreply@github.com>
Depends: libgtk-3-0 | libgtk-3-0t64
Section: sound
Priority: optional
Homepage: https://github.com/chinatsu033/Canto
Description: Canto - lyrics display (personal learning project)
 Shows synced lyrics from LRCLIB for the track your system is playing (MPRIS).
 Does not play or provide any music.
CTL
dpkg-deb --root-owner-group --build "$STAGE" "dist/Canto-$VERSION-linux-$ARCH.deb"

# --- AppImage ---
APPDIR="$(mktemp -d)/Canto.AppDir"
mkdir -p "$APPDIR/usr/bin"
cp -r "$BUILD_DIR"/. "$APPDIR/usr/bin/"
echo "$DESKTOP" > "$APPDIR/canto.desktop"
cp assets/icon/canto_512.png "$APPDIR/canto.png"
cat > "$APPDIR/AppRun" <<'RUN'
#!/bin/sh
HERE="$(dirname "$(readlink -f "$0")")"
exec "$HERE/usr/bin/Canto" "$@"
RUN
chmod +x "$APPDIR/AppRun"
TOOL="appimagetool-$AI_ARCH.AppImage"
[ -f "/tmp/$TOOL" ] || curl -fsSL -o "/tmp/$TOOL" "https://github.com/AppImage/appimagetool/releases/download/continuous/$TOOL"
chmod +x "/tmp/$TOOL"
APPIMAGE_EXTRACT_AND_RUN=1 ARCH="$AI_ARCH" "/tmp/$TOOL" --no-appstream "$APPDIR" "dist/Canto-$VERSION-linux-$ARCH.AppImage"
ls -la dist
