#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
export TEST_RUNNER_SPOTMENU_LIVE_SPOTIFAST=1
exec ./scripts/test.sh "$@"
