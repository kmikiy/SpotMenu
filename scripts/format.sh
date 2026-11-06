#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mode="${1:---check}"
case "$mode" in
    --check) exec xcrun swift-format lint --strict --recursive SpotMenu SpotifastBridge SpotMenuTests SpotMenuUITests ;;
    --write) exec xcrun swift-format format --in-place --recursive SpotMenu SpotifastBridge SpotMenuTests SpotMenuUITests ;;
    *) echo "Usage: $0 [--check|--write]" >&2; exit 2 ;;
esac
