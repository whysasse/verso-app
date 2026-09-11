#!/usr/bin/env bash
# AGENTS.md / work-on-issue's git-cleanliness rule, made mechanical: "nothing
# stray (scratch files, accidental exports, .DS_Store, etc.) should be
# sitting untracked or uncommitted." Deliberately checks for known junk
# patterns rather than requiring a fully clean `git diff` — Check needs to
# be runnable mid-implementation, not only in the instant right before
# opening a PR, when uncommitted work-in-progress is expected and fine.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

JUNK_RE='(^|/)(\.DS_Store|Thumbs\.db|.*\.orig|.*\.rej|.*~|.*\.swp)$'

violations=()

# Untracked junk sitting in the working tree.
while IFS= read -r line; do
  status="${line:0:2}"
  path="${line:3}"
  if [[ "$status" == "??" ]] && [[ "$path" =~ $JUNK_RE ]]; then
    violations+=("untracked: $path")
  fi
done < <(git status --porcelain)

# Junk that got committed by accident at some point.
while IFS= read -r f; do
  [[ -n "$f" && "$f" =~ $JUNK_RE ]] && violations+=("tracked: $f")
done < <(git ls-files)

if [ "${#violations[@]}" -gt 0 ]; then
  echo "check-clean-tree: ${#violations[@]} stray file(s) found:"
  printf '  - %s\n' "${violations[@]}"
  exit 1
fi

echo "check-clean-tree: no stray junk files, tracked or untracked"
exit 0
