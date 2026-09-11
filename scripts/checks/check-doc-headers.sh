#!/usr/bin/env bash
# AGENTS.md: "Every doc starts with a header: **Version:** · **Date:** ·
# **Status:**". The backlog-hygiene rule scopes this to *new* docs, not the
# whole historical corpus — years of pre-existing docs predate this rule,
# and retroactively failing Check on all of them would make Check
# permanently red for reasons unrelated to whatever's being worked on. So
# this only checks docs newly *added* on this branch versus main.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BASE="main"
git rev-parse --verify -q "$BASE" >/dev/null 2>&1 || BASE="origin/main"
MERGE_BASE="$(git merge-base "$BASE" HEAD 2>/dev/null || echo "$BASE")"

# Portable read (no `mapfile`/`readarray` — those are bash 4+, and macOS's
# default /bin/bash is 3.2).
added=()
while IFS= read -r line; do
  [ -n "$line" ] && added+=("$line")
done < <(
  git diff --name-only --diff-filter=A "$MERGE_BASE"...HEAD -- 'docs/*.md' 'docs/**/*.md' 2>/dev/null \
    | grep -v '^docs/_archive/' || true
)

if [ "${#added[@]}" -eq 0 ]; then
  echo "check-doc-headers: no new docs on this branch — nothing to check"
  exit 0
fi

HEADER_RE='\*\*Version:\*\*.*\*\*Date:\*\*.*\*\*Status:\*\*'
violations=()
for f in "${added[@]}"; do
  [ -f "$f" ] || continue
  if ! head -5 "$f" | tr -d '\n' | grep -qE "$HEADER_RE"; then
    violations+=("$f")
  fi
done

if [ "${#violations[@]}" -gt 0 ]; then
  echo "check-doc-headers: ${#violations[@]} new doc(s) missing the Version/Date/Status header in their first few lines:"
  printf '  - %s\n' "${violations[@]}"
  exit 1
fi

echo "check-doc-headers: every new doc on this branch carries the required header"
exit 0
