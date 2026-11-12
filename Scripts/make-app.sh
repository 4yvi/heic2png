#!/bin/bash
# Собирает build/HEIC2PNG.app из release-бинарника SwiftPM (без Xcode GUI).
set -euo pipefail
cd "$(dirname "$0")/.."
swift build -c release --product HEIC2PNGApp
BIN="$(swift build -c release --show-bin-path)/HEIC2PNGApp"
APP="build/HEIC2PNG.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp "$BIN" "$APP/Contents/MacOS/HEIC2PNGApp"
cat > "$APP/Contents/Info.plist" <<PL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleIdentifier</key><string>local.heic2png</string>
  <key>CFBundleName</key><string>HEIC2PNG</string>
  <key>CFBundleExecutable</key><string>HEIC2PNGApp</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>NSHighResolutionCapable</key><true/>
  <key>CFBundleDocumentTypes</key><array><dict>
    <key>CFBundleTypeName</key><string>HEIC Image</string>
    <key>CFBundleTypeRole</key><string>Viewer</string>
    <key>LSItemContentTypes</key><array><string>public.heic</string><string>public.heif</string></array>
  </dict></array>
</dict></plist>
PL
codesign --force --sign - "$APP"
echo "Готово: $APP"
