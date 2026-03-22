#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DESTINATION_DIR="${1:?Usage: fetch-sparkle-tools.sh <destination-dir>}"

if [[ -x "$DESTINATION_DIR/bin/generate_appcast" && -x "$DESTINATION_DIR/bin/generate_keys" ]]; then
    echo "$DESTINATION_DIR/bin"
    exit 0
fi

SPARKLE_VERSION="${SPARKLE_VERSION:-$(
    /usr/bin/python3 -c '
import json
from pathlib import Path

resolved = Path("'"$ROOT_DIR"'/CorgiNotch.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved")
data = json.loads(resolved.read_text())
for pin in data["pins"]:
    if pin["identity"] == "sparkle":
        print(pin["state"]["version"])
        break
else:
    raise SystemExit("Sparkle version not found in Package.resolved")
' 
)}"

ARCHIVE_URL="https://github.com/sparkle-project/Sparkle/releases/download/${SPARKLE_VERSION}/Sparkle-${SPARKLE_VERSION}.tar.xz"
TEMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

curl -fsSL "$ARCHIVE_URL" -o "$TEMP_DIR/Sparkle-${SPARKLE_VERSION}.tar.xz"
tar -xJf "$TEMP_DIR/Sparkle-${SPARKLE_VERSION}.tar.xz" -C "$TEMP_DIR"

BIN_DIR="$(find "$TEMP_DIR" -type d -path '*/bin' | head -n 1)"

if [[ -z "$BIN_DIR" ]]; then
    echo "Unable to locate Sparkle tools after downloading $ARCHIVE_URL" >&2
    exit 1
fi

mkdir -p "$DESTINATION_DIR"
cp -R "$(dirname "$BIN_DIR")"/. "$DESTINATION_DIR"/

echo "$DESTINATION_DIR/bin"
