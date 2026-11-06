#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/../website"
case "${1:-build}" in
    install) set -- ci ;;
    build) set -- run build ;;
    preview) set -- run preview -- --host 127.0.0.1 --port 4321 ;;
    *) echo "Usage: $0 [install|build|preview]" >&2; exit 1 ;;
esac
exec npm "$@"
