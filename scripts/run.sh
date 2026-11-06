#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
./scripts/build.sh
exec open -n "${SPOTMENU_BUILD_DIR:-$PWD/build}/Build/Products/Debug/SpotMenu.app"
