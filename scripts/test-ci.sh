#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
export CI=true
exec ./scripts/test.sh -disableAutomaticPackageResolution -onlyUsePackageVersionsFromResolvedFile "$@"
