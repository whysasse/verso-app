#!/usr/bin/env bash
# AGENTS.md: "All documentation lives in docs/. Never create .md docs at the
# repo root or inside source folders (the only root files are README.md,
# CLAUDE.md, AGENTS.md, LICENSE). Platform-specific agent rules live in the
# platform folder (e.g. verso-web/AGENTS.md)."
#
# Checks git-tracked files only — deliberately excludes anything gitignored
# (sdlc-toolkit/) or untracked, since those aren't shipped documentation.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

ALLOWED_BASENAMES=("README.md" "AGENTS.md" "CLAUDE.md")
EXEMPT_PREFIXES=("SampleArticles/" "Verso/Resources/")

violations=()

while IFS= read -r f; do
  [ -z "$f" ] && continue
  case "$f" in
    docs/*) continue ;;
  esac

  exempt=false
  for prefix in "${EXEMPT_PREFIXES[@]}"; do
    case "$f" in
      "$prefix"*) exempt=true; break ;;
    esac
  done
  $exempt && continue

  base="$(basename "$f")"
  depth="$(tr -cd '/' <<<"$f" | wc -c | tr -d ' ')"

  is_allowed_name=false
  for name in "${ALLOWED_BASENAMES[@]}"; do
    [ "$base" = "$name" ] && is_allowed_name=true && break
  done

  # Allowed at the repo root (depth 0) or one level down — a platform
  # folder's own root, e.g. verso-web/AGENTS.md.
  if $is_allowed_name && [ "$depth" -le 1 ]; then
    continue
  fi

  violations+=("$f")
done < <(git ls-files '*.md')

if [ "${#violations[@]}" -gt 0 ]; then
  echo "check-doc-location: ${#violations[@]} tracked .md file(s) outside docs/ that shouldn't be there:"
  printf '  - %s\n' "${violations[@]}"
  exit 1
fi

echo "check-doc-location: every tracked doc is under docs/, or an allowed README/AGENTS/CLAUDE root file"
exit 0
