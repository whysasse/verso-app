#!/usr/bin/env bash
# Ensures Secrets.xcconfig exists (gitignored; not in repo), then runs XcodeGen.
# Usage: from repo root: ./Verso/generate-xcodeproj.sh
#        or:            cd Verso && ./generate-xcodeproj.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

SECRETS="Secrets.xcconfig"
TEMPLATE="Secrets.xcconfig.template"

if [[ ! -f "$SECRETS" ]]; then
  if [[ ! -f "$TEMPLATE" ]]; then
    echo "error: missing $TEMPLATE — cannot create $SECRETS" >&2
    exit 1
  fi
  cp "$TEMPLATE" "$SECRETS"
  echo "Created $SECRETS from $TEMPLATE (local only, gitignored). Edit to set DEVELOPMENT_TEAM, or override TELEMETRY_DECK_APP_ID if needed."
fi

if ! grep -q "^DEVELOPMENT_TEAM[[:space:]]*=[[:space:]]*.\+" "$SECRETS"; then
  echo "warning: DEVELOPMENT_TEAM is not set in $SECRETS — builds will fail to code sign." >&2
  echo "         Find your Team ID at developer.apple.com → Membership details." >&2
fi

exec xcodegen generate "$@"
