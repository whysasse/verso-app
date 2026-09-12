# Verso

## Commands
- Check: `scripts/check.sh` — fast, mechanical hygiene checks (docs, tokens,
  backlog bookkeeping, stray files). Not the build; see `## Commands → Build`
  for that. (No `make check` wrapper yet — there's no Makefile in this repo;
  the script runs standalone. Worth revisiting if that changes.)
- Build:
  - iOS: `xcodebuild -project Verso/Verso.xcodeproj -scheme Verso -destination 'generic/platform=iOS Simulator' -sdk iphonesimulator build` (and the `ShareExtension` scheme too, if it was touched)
  - Web: `cd verso-web && npm run build` (or `npx tsc --noEmit` for a faster type-only check)
- Test: none yet — no automated test suite exists. Flagged, not solved: see
  `docs/DECISIONS.md` for the Obsidian sync layer's test gap specifically.
- Run:
  - iOS: open `Verso/Verso.xcodeproj` in Xcode, ⌘R
  - Web: `cd verso-web && npm run dev` → `http://localhost:3000`

## Workflow
- Issues: `docs/BACKLOG.md` is the tracker of record (Linear retired
  2026-06-12). GitHub Issues on this repo is a leftover migration artifact,
  not kept in sync — never treat it as authoritative. A completed issue's
  entry *moves* to `docs/DONE.md` with a completion date, in the same
  commit as the implementing change — `scripts/check.sh` now catches an
  entry left in both files.
- Branching: branch from `main`; PR back into `main`; squash-merge with the
  branch deleted on merge. For a step within a larger parent issue (e.g.
  FAB-150), use `Refs #NNN` rather than `Closes #NNN` in the PR body so the
  parent doesn't auto-close early.
- Documentation: all docs live only inside `docs/` (root is limited to
  README/CLAUDE/AGENTS/LICENSE). `docs/HANDOFF.md` is the index — fetch
  its doc map for anything domain-specific, and update that map in the
  same commit as any doc you add, move, or archive. `docs/PROJECT_STATUS.md`
  is the only place project status lives — link to it, don't restate it.
  Every doc's first few lines carry `**Version:** · **Date:** ·
  **Status:**` (`Draft`/`Active`/`Locked`/`Archived`). Superseded docs move
  to `docs/_archive/` with the archive banner prepended and inbound links
  fixed in the same commit; per-issue working docs (e.g. `FAB-77-…md`)
  move there when the issue closes. `docs/` is currently flat — no
  `product/`/`design/`/`engineering/` subfolders exist (a 2026-06 plan to
  add them was never executed — see `docs/_archive/DOCS_CLEANUP_PLAN_2026-06-12.md`);
  don't invent paths assuming they do. `SCREAMING_SNAKE.md` for
  specs/reference docs, `kebab-case.md` for working notes — don't rename
  existing files just to conform. This moved here from `AGENTS.md` on
  2026-09-12 specifically so it's read unconditionally, not gated behind
  "touching iOS or design-system code."
- Human verification: headless iOS Simulator automation isn't reliable for
  this project, so pulling the branch, opening Xcode, and running on the
  simulator is genuinely Fabio's step, every time. Web changes can be
  checked directly in a browser.
- Release gate: none yet — pre-TestFlight. Revisit once a submission
  command exists.

## Conventions
See `AGENTS.md` for the full picture (architecture, design-system Swift
identifiers, key constraints, external dependencies) — this file doesn't
restate it, to avoid the two drifting apart. (Documentation conventions
moved to `## Workflow` above, not here — see that section's note on why.)
The two rules `scripts/check.sh` now enforces mechanically, so they're
worth naming here specifically:
- Docs live only inside `docs/` (`scripts/checks/check-doc-location.sh`).
- `verso-web/app/globals.css` must match `docs/DESIGN_TOKENS.md`
  (`scripts/checks/check-token-parity.sh`).

Read `AGENTS.md` before touching iOS or design-system code — SwiftUI
gotchas, `xcodegen` regeneration, and the exact token/identifier names all
live there.

## Things Claude gets wrong
See `AGENTS.md`'s "SwiftUI Gotchas" section — that's the living list, and
where a correction goes the second time a mistake happens. Keeping a
second copy here would just drift from that one.
