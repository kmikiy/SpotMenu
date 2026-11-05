#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
exec osv-scanner scan source \
    --lockfile=SpotMenu.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved \
    --lockfile=website/package-lock.json "$@"
