#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
git diff --check
for script in scripts/*.sh; do
    bash -n "$script"
done
./scripts/lint.sh
./scripts/format.sh --check
exec ./scripts/test.sh "$@"
