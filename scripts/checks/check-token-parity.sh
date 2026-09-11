#!/usr/bin/env bash
# Thin wrapper so check.sh can invoke this like every other check — the
# parsing itself is easier to get right in Python than in bash/sed.
set -euo pipefail
exec python3 "$(dirname "${BASH_SOURCE[0]}")/check-token-parity.py"
