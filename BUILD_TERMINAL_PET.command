#!/bin/zsh

set -euo pipefail

PROJECT_DIR="${0:A:h}"
DIST_DIR="$PROJECT_DIR/dist"
APP_PATH="$DIST_DIR/Terminal Pet.app"
STAGING_PATH="$DIST_DIR/.Terminal Pet.app.building"
ICONSET_PATH="$DIST_DIR/.TerminalPet.iconset"

cleanup() {
  /bin/rm -rf -- "$STAGING_PATH" "$ICONSET_PATH"
}
trap cleanup EXIT

clear
print ""
print "  ╭────────────────────────────────────╮"
print "  │  >_ TERMINAL PET 0.2 · macOS build │"
print "  ╰────────────────────────────────────╯"
print ""

if ! command -v swift >/dev/null 2>&1; then
  print "Swift was not found. Opening Apple's Command Line Tools installer…"
  xcode-select --install 2>/dev/null || true
  print ""
  print "After installation finishes, run this builder again."
  read -k 1 "?Press any key to close."
  print ""
  exit 1
fi

cd "$PROJECT_DIR"
print "[1/4] Compiling the native app…"
swift build -c release
BIN_DIR="$(swift build -c release --show-bin-path)"

print "[2/4] Building Terminal Pet.app…"
cleanup
/bin/mkdir -p "$STAGING_PATH/Contents/MacOS" "$STAGING_PATH/Contents/Resources"
/bin/cp "$BIN_DIR/TerminalPet" "$STAGING_PATH/Contents/MacOS/TerminalPet"
/bin/cp "$PROJECT_DIR/Assets/Info.plist" "$STAGING_PATH/Contents/Info.plist"
/bin/chmod 755 "$STAGING_PATH/Contents/MacOS/TerminalPet"

print "[3/4] Giving the creature an icon…"
/bin/mkdir -p "$ICONSET_PATH"
for spec in \
  "16:icon_16x16.png" \
  "32:icon_16x16@2x.png" \
  "32:icon_32x32.png" \
  "64:icon_32x32@2x.png" \
  "128:icon_128x128.png" \
  "256:icon_128x128@2x.png" \
  "256:icon_256x256.png" \
  "512:icon_256x256@2x.png" \
  "512:icon_512x512.png" \
  "1024:icon_512x512@2x.png"
do
  size="${spec%%:*}"
  filename="${spec#*:}"
  /usr/bin/sips -s format png -z "$size" "$size" "$PROJECT_DIR/Assets/AppIcon.png" --out "$ICONSET_PATH/$filename" >/dev/null
done
/usr/bin/iconutil -c icns "$ICONSET_PATH" -o "$STAGING_PATH/Contents/Resources/TerminalPet.icns"

print "[4/4] Signing and opening…"
/usr/bin/codesign --force --deep --sign - "$STAGING_PATH" >/dev/null
/bin/rm -rf -- "$APP_PATH"
/bin/mv "$STAGING_PATH" "$APP_PATH"
trap - EXIT
/bin/rm -rf -- "$ICONSET_PATH"

print ""
print "Done: $APP_PATH"
print "No sudo. No weird daemon. Just a pet."
print ""
/usr/bin/open "$APP_PATH"
read -k 1 "?Press any key to close this window."
print ""
