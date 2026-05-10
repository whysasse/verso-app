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
  echo "Created $SECRETS from $TEMPLATE (local only, gitignored). Edit to override TELEMETRY_DECK_APP_ID if needed."
fi

exec xcodegen generate "$@"
