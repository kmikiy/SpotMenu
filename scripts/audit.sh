#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
lockfiles=(
    --lockfile=SpotMenu.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
    --lockfile=website/package-lock.json
)
case "${1:-}" in
    swift) lockfiles=("${lockfiles[0]}"); shift ;;
    website) lockfiles=("${lockfiles[1]}"); shift ;;
esac
exec osv-scanner scan source "${lockfiles[@]}" "$@"
