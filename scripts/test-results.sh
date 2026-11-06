#!/bin/bash
set -euo pipefail
exec xcrun xcresulttool get test-results summary --path "${1:?Usage: ./scripts/test-results.sh path/to/results.xcresult}"
