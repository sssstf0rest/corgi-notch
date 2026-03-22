#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_PATH="$ROOT_DIR/CorgiNotch.xcodeproj"
SCHEME="CorgiNotch"

CONFIGURATION="${CONFIGURATION:-Release}"
BUILD_DIR="${BUILD_DIR:-$ROOT_DIR/build/sparkle-release}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$BUILD_DIR/DerivedData}"
ARCHIVE_PATH="$BUILD_DIR/CorgiNotch.xcarchive"

SPARKLE_PUBLIC_ED_KEY="${SPARKLE_PUBLIC_ED_KEY:?Set SPARKLE_PUBLIC_ED_KEY before building a release archive.}"
SPARKLE_APPCAST_URL="${SPARKLE_APPCAST_URL:-https://sssstf0rest.github.io/corgi-notch/appcast.xml}"

VERSION="${VERSION:-$(
    /usr/bin/awk -F ' = ' '
        /MARKETING_VERSION = / {
            gsub(/;/, "", $2)
            print $2
            exit
        }
    ' "$PROJECT_PATH/project.pbxproj"
)}"

ZIP_PATH="$BUILD_DIR/CorgiNotch-${VERSION}.zip"
APP_PATH="$ARCHIVE_PATH/Products/Applications/CorgiNotch.app"

rm -rf "$ARCHIVE_PATH" "$DERIVED_DATA_PATH" "$ZIP_PATH"
mkdir -p "$BUILD_DIR"

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

ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$ZIP_PATH"

echo "Created release archive:"
echo "$ZIP_PATH"
