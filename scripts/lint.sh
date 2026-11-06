#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
exec swiftlint lint --no-cache --strict --config .swiftlint.yml "$@"
