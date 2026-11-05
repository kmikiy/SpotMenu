#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
git diff --check
for script in scripts/*.sh; do
    bash -n "$script"
done
exec ./scripts/test.sh "$@"
