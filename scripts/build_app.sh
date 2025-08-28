#!/bin/bash
set -euo pipefail

# Build MultiChrome.app from repository contents without absolute paths.

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="${PROJECT_ROOT}/dist"
APP_NAME="MultiChrome"
APP_DIR="${DIST_DIR}/${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RES_DIR="${CONTENTS_DIR}/Resources"

# Configurable via env or flags
VERSION="${VERSION:-0.1.0}"
IDENTIFIER="${IDENTIFIER:-io.multichrome.app}"
WITH_ICON=1

while [[ $# -gt 0 ]]; do
    case "$1" in
        --version)
            VERSION="${2:-$VERSION}"; shift ;;
        --identifier)
            IDENTIFIER="${2:-$IDENTIFIER}"; shift ;;
        --no-icon)
            WITH_ICON=0 ;;
        -h|--help)
            echo "Usage: $0 [--version X.Y.Z] [--identifier com.example.app] [--no-icon]"
            exit 0 ;;
        *)
            echo "Unknown option: $1" >&2; exit 1 ;;
    esac
    shift
done

echo "Building ${APP_NAME}.app (version ${VERSION}, id ${IDENTIFIER})..."

rm -rf "${APP_DIR}"
mkdir -p "${MACOS_DIR}" "${RES_DIR}"

# Generate Info.plist from template
if [[ ! -f "${PROJECT_ROOT}/scripts/Info.plist" ]]; then
    echo "Missing scripts/Info.plist template" >&2
    exit 1
fi
sed -e "s/@VERSION@/${VERSION}/g" \
    -e "s/@IDENTIFIER@/${IDENTIFIER}/g" \
    "${PROJECT_ROOT}/scripts/Info.plist" > "${CONTENTS_DIR}/Info.plist"

# Copy launcher
if [[ ! -f "${PROJECT_ROOT}/scripts/launcher" ]]; then
    echo "Missing scripts/launcher" >&2
    exit 1
fi
cp "${PROJECT_ROOT}/scripts/launcher" "${MACOS_DIR}/launcher"
chmod +x "${MACOS_DIR}/launcher"

# Bundle the main script
if [[ ! -f "${PROJECT_ROOT}/multi_chrome.sh" ]]; then
    echo "Missing multi_chrome.sh at repo root" >&2
    exit 1
fi
cp "${PROJECT_ROOT}/multi_chrome.sh" "${RES_DIR}/multi_chrome.sh"
chmod +x "${RES_DIR}/multi_chrome.sh"

# Optional icon
if [[ ${WITH_ICON} -eq 1 ]]; then
    if [[ -f "${PROJECT_ROOT}/assets/AppIcon.icns" ]]; then
        cp "${PROJECT_ROOT}/assets/AppIcon.icns" "${RES_DIR}/AppIcon.icns"
    else
        # Try to reuse Google Chrome's icon if available
        CHROME_ICNS="/Applications/Google Chrome.app/Contents/Resources/app.icns"
        if [[ -f "${CHROME_ICNS}" ]]; then
            cp "${CHROME_ICNS}" "${RES_DIR}/AppIcon.icns"
        fi
    fi
fi

echo "Built: ${APP_DIR}"
echo "Run:   open \"${APP_DIR}\""

