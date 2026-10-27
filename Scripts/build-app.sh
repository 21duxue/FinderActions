#!/bin/zsh
set -euo pipefail

ROOT="${0:A:h:h}"
cd "$ROOT"

CONFIGURATION="${1:-release}"
VERSION="${VERSION:-0.1.3}"
APP_NAME="FinderActions"
APP_BUNDLE="$ROOT/build/$APP_NAME.app"
EXTENSION_NAME="FinderActionsExtension"
EXTENSION_BUNDLE="$APP_BUNDLE/Contents/PlugIns/$EXTENSION_NAME.appex"

swift build -c "$CONFIGURATION"
BIN_DIR="$(swift build -c "$CONFIGURATION" --show-bin-path)"

SDK="$(xcrun --sdk macosx --show-sdk-path)"
TARGET="$(uname -m)-apple-macos13.0"
EXT_SRC_DIR="$(mktemp -d)"
trap 'rm -rf "$EXT_SRC_DIR"' EXIT

rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"
cp "$ROOT/Resources/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
mkdir -p "$EXTENSION_BUNDLE/Contents/MacOS"

cp "$BIN_DIR/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

for source in "$ROOT/Sources/$EXTENSION_NAME"/*.swift; do
  sed '/^[[:space:]]*import FinderActionsCore[[:space:]]*$/d' "$source" > "$EXT_SRC_DIR/${source:t}"
done

xcrun swiftc \
  -swift-version 5 \
  -O \
  -sdk "$SDK" \
  -target "$TARGET" \
  -module-name "$EXTENSION_NAME" \
  -parse-as-library \
  -application-extension \
  -framework Cocoa \
  -framework FinderSync \
  -Xlinker -e \
  -Xlinker _NSExtensionMain \
  "$EXT_SRC_DIR"/*.swift \
  "$ROOT/Sources/FinderActionsCore"/*.swift \
  -o "$EXTENSION_BUNDLE/Contents/MacOS/$EXTENSION_NAME"

cat > "$APP_BUNDLE/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>zh_CN</string>
    <key>CFBundleExecutable</key>
    <string>FinderActions</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key>
            <string>dev.finderactions.FinderActions</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>finderactions</string>
            </array>
        </dict>
    </array>
    <key>CFBundleIdentifier</key>
    <string>dev.finderactions.FinderActions</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>FinderActions</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
PLIST

cat > "$EXTENSION_BUNDLE/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>zh_CN</string>
    <key>CFBundleDisplayName</key>
    <string>FinderActions Finder Sync</string>
    <key>CFBundleExecutable</key>
    <string>FinderActionsExtension</string>
    <key>CFBundleIdentifier</key>
    <string>dev.finderactions.FinderActions.FinderSync</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>FinderActions Finder Sync</string>
    <key>CFBundlePackageType</key>
    <string>XPC!</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSExtension</key>
    <dict>
        <key>NSExtensionAttributes</key>
        <dict/>
        <key>NSExtensionPointIdentifier</key>
        <string>com.apple.FinderSync</string>
        <key>NSExtensionPrincipalClass</key>
        <string>FinderActionsSync</string>
    </dict>
</dict>
</plist>
PLIST

cat > "$ROOT/build/extension.entitlements" <<'ENTITLEMENTS'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
    <key>com.apple.security.temporary-exception.shared-preference.read-only</key>
    <array>
        <string>dev.finderactions.shared</string>
    </array>
</dict>
</plist>
ENTITLEMENTS

cat > "$ROOT/build/app.entitlements" <<'ENTITLEMENTS'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
</dict>
</plist>
ENTITLEMENTS

codesign --force --sign - --entitlements "$ROOT/build/extension.entitlements" "$EXTENSION_BUNDLE"
codesign --force --sign - "$APP_BUNDLE"

echo "Built $APP_BUNDLE"
