#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_PATH="$ROOT_DIR/CorgiNotch.xcodeproj"
SCHEME="CorgiNotch"

CONFIGURATION="${CONFIGURATION:-Release}"
BUILD_DIR="${BUILD_DIR:-$ROOT_DIR/build/sparkle-release}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$BUILD_DIR/DerivedData}"
ARCHIVE_PATH="$BUILD_DIR/CorgiNotch.xcarchive"
STAGE_DIR="$BUILD_DIR/CorgiNotch-dmg-root"
RW_DMG_PATH="$BUILD_DIR/CorgiNotch-temp.dmg"
VOLUME_NAME="${VOLUME_NAME:-CorgiNotch}"

SPARKLE_PUBLIC_ED_KEY="${SPARKLE_PUBLIC_ED_KEY:-$(
    /usr/bin/awk -F ' = ' '
        /SPARKLE_PUBLIC_ED_KEY = / {
            gsub(/[\";]/, "", $2)
            if (length($2) > 0) {
                print $2
                exit
            }
        }
    ' "$PROJECT_PATH/project.pbxproj"
)}"
SPARKLE_APPCAST_URL="${SPARKLE_APPCAST_URL:-https://sssstf0rest.github.io/corgi-notch/appcast.xml}"

if [[ -z "$SPARKLE_PUBLIC_ED_KEY" ]]; then
    echo "Unable to determine SPARKLE_PUBLIC_ED_KEY. Set it in the environment or Xcode project before building a release DMG." >&2
    exit 1
fi

VERSION="${VERSION:-$(
    /usr/bin/awk -F ' = ' '
        /MARKETING_VERSION = / {
            gsub(/;/, "", $2)
            print $2
            exit
        }
    ' "$PROJECT_PATH/project.pbxproj"
)}"

DMG_PATH="$BUILD_DIR/CorgiNotch-${VERSION}.dmg"
APP_PATH="$ARCHIVE_PATH/Products/Applications/CorgiNotch.app"

rm -rf "$ARCHIVE_PATH" "$DERIVED_DATA_PATH" "$STAGE_DIR"
rm -f "$RW_DMG_PATH" "$DMG_PATH"
mkdir -p "$BUILD_DIR" "$STAGE_DIR"

xcodebuild \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    -archivePath "$ARCHIVE_PATH" \
    archive \
    SPARKLE_PUBLIC_ED_KEY="$SPARKLE_PUBLIC_ED_KEY" \
    SPARKLE_APPCAST_URL="$SPARKLE_APPCAST_URL"

if [[ ! -d "$APP_PATH" ]]; then
    echo "Expected archived app not found at $APP_PATH" >&2
    exit 1
fi

codesign --verify --deep --strict "$APP_PATH"

ditto "$APP_PATH" "$STAGE_DIR/CorgiNotch.app"
ln -s /Applications "$STAGE_DIR/Applications"

hdiutil create \
    -ov \
    -volname "$VOLUME_NAME" \
    -srcfolder "$STAGE_DIR" \
    -fs HFS+ \
    -format UDRW \
    "$RW_DMG_PATH"

hdiutil convert \
    -ov \
    "$RW_DMG_PATH" \
    -format UDZO \
    -imagekey zlib-level=9 \
    -o "$DMG_PATH"

rm -rf "$STAGE_DIR"
rm -f "$RW_DMG_PATH"

echo "Created release disk image:"
echo "$DMG_PATH"
