#!/usr/bin/env bash
set -euo pipefail

# Simple builder for a macOS .pkg of the marvel-comics app
# - Builds Release using xcodebuild
# - Creates a component installer that installs the app into /Applications
# - Optionally signs the installer if INSTALLER_ID is set (Developer ID Installer: ...)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"
PROJECT_PATH="$REPO_ROOT/marvel-comics/marvel-comics.xcodeproj"
SCHEME="marvel-comics"
CONFIG="Release"
BUNDLE_ID="com.fbg.marvel-comics"
DERIVED_DATA_DIR="$REPO_ROOT/build"
APP_PATH="$DERIVED_DATA_DIR/Build/Products/$CONFIG/$SCHEME.app"
DIST_DIR="$REPO_ROOT/dist"

usage() {
  cat <<EOF
Usage: $(basename "$0") [--clean]

Options:
  --clean      Remove build and dist directories before building

Environment:
  INSTALLER_ID Optional. If set, used to sign the pkg. Example:
               "Developer ID Installer: Your Name (TEAMID)"
EOF
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi

if [[ ${1:-} == "--clean" ]]; then
  echo "[clean] Removing $DERIVED_DATA_DIR and $DIST_DIR"
  rm -rf "$DERIVED_DATA_DIR" "$DIST_DIR"
fi

echo "[build] Building $SCHEME ($CONFIG)"
xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration "$CONFIG" \
  -derivedDataPath "$DERIVED_DATA_DIR" \
  build | xcpretty || true

# Fallback in case xcpretty isn't installed: re-run without it on failure
if [[ ! -d "$APP_PATH" ]]; then
  echo "[build] Re-running build without xcpretty"
  xcodebuild \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -configuration "$CONFIG" \
    -derivedDataPath "$DERIVED_DATA_DIR" \
    build
fi

if [[ ! -d "$APP_PATH" ]]; then
  echo "[error] Built app not found at: $APP_PATH" >&2
  exit 1
fi

mkdir -p "$DIST_DIR"

# Determine version from built app Info.plist
INFO_PLIST="$APP_PATH/Contents/Info.plist"
VERSION=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$INFO_PLIST" 2>/dev/null || echo "0.0")
PKG_NAME="$SCHEME-$VERSION.pkg"
PKG_PATH="$DIST_DIR/$PKG_NAME"

echo "[pkg] Creating component package: $PKG_PATH"
PKGBUILD_ARGS=(
  --install-location "/Applications"
  --component "$APP_PATH"
  --identifier "$BUNDLE_ID"
  "$PKG_PATH"
)

if [[ -n ${INSTALLER_ID:-} ]]; then
  echo "[sign] Signing installer with: $INSTALLER_ID"
  PKGBUILD_ARGS=(--sign "$INSTALLER_ID" "${PKGBUILD_ARGS[@]}")
fi

pkgbuild "${PKGBUILD_ARGS[@]}"

echo "[done] Package created at: $PKG_PATH"
echo "Install with: sudo installer -pkg \"$PKG_PATH\" -target /"


