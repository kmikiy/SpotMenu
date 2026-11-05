#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

identity="${SPOTMENU_SIGN_IDENTITY:-Apple Development}"
team="${SPOTMENU_DEVELOPMENT_TEAM:-}"
if [[ -z "$team" && "$identity" != - ]]; then
    team=$(security find-certificate -c "$identity" -p | \
        openssl x509 -noout -subject -nameopt multiline | \
        sed -n 's/^ *organizationalUnitName *= //p')
fi

exec xcodebuild -quiet -project SpotMenu.xcodeproj -scheme SpotMenu \
    -configuration Debug -destination 'platform=macOS' \
    -derivedDataPath "${SPOTMENU_BUILD_DIR:-${TMPDIR:-/tmp}/spotmenu-build}" \
    CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY="$identity" DEVELOPMENT_TEAM="$team" \
    "$@"
