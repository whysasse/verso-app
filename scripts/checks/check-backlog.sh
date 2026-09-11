#!/usr/bin/env bash
# AGENTS.md backlog hygiene: an issue's entry *moves* from BACKLOG.md to
# DONE.md — it doesn't get copied. Only matches real checklist entries
# (`- [ ]`/`- [x]` lines with a bold **FAB-xx**), not prose that merely
# mentions an id in passing (parent-issue cross-references, "see FAB-150"
# notes, design-critique heading tags, etc.) — those aren't duplicate
# bookkeeping, just normal cross-referencing.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

extract_ids() {
  grep -oE '^- \[[ x]\] .*\*\*FAB-[0-9]+\*\*' "$1" | grep -oE 'FAB-[0-9]+' | sort -u
}

backlog_ids="$(extract_ids docs/BACKLOG.md || true)"
done_ids="$(extract_ids docs/DONE.md || true)"

dupes="$(comm -12 <(echo "$backlog_ids") <(echo "$done_ids") | sed '/^$/d')"

if [ -n "$dupes" ]; then
  count=$(echo "$dupes" | wc -l | tr -d ' ')
  echo "check-backlog: $count issue id(s) have an entry in both BACKLOG.md and DONE.md:"
  while IFS= read -r id; do
    echo "  - $id"
    grep -n "\*\*${id}\*\*" docs/BACKLOG.md | sed 's/^/      BACKLOG.md:/'
    grep -n "\*\*${id}\*\*" docs/DONE.md | sed 's/^/      DONE.md:   /'
  done <<< "$dupes"
  exit 1
fi

echo "check-backlog: no issue id appears as an entry in both BACKLOG.md and DONE.md"
exit 0
