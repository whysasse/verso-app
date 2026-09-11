#!/usr/bin/env bash
# The project's single gate command — CLAUDE.md's "## Commands → Check"
# points here. This is the mechanical half of AGENTS.md's docs & repo
# hygiene checklist (the fast, seconds-not-minutes part); the iOS/web
# builds are their own, slower "## Commands → Build" and aren't run here.
#
# Each check is its own script under scripts/checks/, so a failure names
# itself instead of getting lost in one large log.
set -uo pipefail
cd "$(git rev-parse --show-toplevel)"

CHECKS=(
  scripts/checks/check-token-parity.sh
  scripts/checks/check-doc-location.sh
  scripts/checks/check-doc-headers.sh
  scripts/checks/check-backlog.sh
  scripts/checks/check-clean-tree.sh
)

failures=0
for check in "${CHECKS[@]}"; do
  echo "=== ${check} ==="
  if ! bash "$check"; then
    failures=$((failures + 1))
  fi
  echo
done

echo "---"
if [ "$failures" -eq 0 ]; then
  echo "check: all ${#CHECKS[@]} checks passed"
  exit 0
else
  echo "check: ${failures} of ${#CHECKS[@]} check(s) failed"
  exit 1
fi
