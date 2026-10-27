#!/bin/zsh
set -euo pipefail

ROOT="${0:A:h:h}"
VERSION="${1:-0.1.3}"
export VERSION
BASE_NAME="FinderActions-v${VERSION}-macOS"
DIST="$ROOT/dist"
STAGING="$DIST/$BASE_NAME"
DMG_STAGING="$DIST/.dmg-staging"
ZIP_PATH="$DIST/$BASE_NAME.zip"
DMG_PATH="$DIST/$BASE_NAME.dmg"

"$ROOT/Scripts/build-app.sh" release

rm -rf "$STAGING" "$DMG_STAGING"
mkdir -p "$STAGING" "$DMG_STAGING"

cp -R "$ROOT/build/FinderActions.app" "$STAGING/"
cp "$ROOT/INSTALL.md" "$STAGING/"

cp -R "$ROOT/build/FinderActions.app" "$DMG_STAGING/"
ln -s /Applications "$DMG_STAGING/Applications"

rm -f "$ZIP_PATH" "$DMG_PATH" "$DIST/SHA256SUMS.txt"

cd "$DIST"
ditto -c -k --norsrc --keepParent "$BASE_NAME" "$ZIP_PATH"
hdiutil create \
  -volname "FinderActions" \
  -srcfolder "$DMG_STAGING" \
  -ov \
  -format UDZO \
  "$DMG_PATH" >/dev/null

shasum -a 256 "$ZIP_PATH" "$DMG_PATH" > "$DIST/SHA256SUMS.txt"

echo "Created:"
echo "  $ZIP_PATH"
echo "  $DMG_PATH"
cat "$DIST/SHA256SUMS.txt"
