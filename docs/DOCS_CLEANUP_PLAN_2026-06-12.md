# Verso — Documentation Cleanup & Streamlining Plan

**Date:** 2026-06-12 · **Author:** Claude (audit session) · **Status:** Ready to execute
**Decision (2026-06-12):** Linear is retired. `docs/BACKLOG.md` / `docs/DONE.md` are now the **issue tracker of record**, not a mirror.
**Executor instructions:** Work through phases in order. Each phase is independent and committable on its own. Verify with the checklist at the end.

---

## Context — what the audit found

The doc set is fundamentally good (HANDOFF.md as index, keyed UI copy, token docs with WCAG rationale). Most items from `VERSO_DOCS_REVIEW_2026-06-09.md` were already executed. What remains is (a) **fresh drift** — code moved faster than the docs, (b) **unresolved redundancy** flagged in May but never cleaned, and (c) **no written rules**, so the mess will regrow without them.

### A. Docs that contradict the code (fix in Phase 1)

1. **`HANDOFF.md` (v1.1, 2026-05-20) is stale:**
   - Screens table says Share Extension "🔲 Target not yet created" — **false**: `Verso/ShareExtension/` exists with `ShareView.swift`, `ShareViewController.swift`, `ShareViewModel.swift` and a target in `project.yml`.
   - Services table is missing `ArticlePlainText.swift`, `DebugSeedService.swift`, and `Import/ImportFileParser.swift`.
   - `Shared/` list shows 3 of 10 files — missing `AppConstants`, `ArticleParsingError`, `DuplicateSaveResolution`, `PendingArticle`, `ReadingEstimate`, `ShareDuplicateArticleTitle`, `VersoArticleURL`.
   - No mention of shipped tag features (tag filter side panel, `ArticleTagsEditorSheet`) or `VersoMainSplitView`.
2. **Root `AGENTS.md` (2026-05-10) is badly stale:** says project is in "design/discovery phase" (it's in active implementation), is iOS-only (no web platform at all), and says "5 Swift files in `Verso/Sources/Design/`" (there are 7). It duplicates CLAUDE.md content and the two drift independently.
3. **`PROJECT_STATUS.md` (2026-06-05):** also says Share Extension "not yet created"; says FAB-166 "in progress" while `BACKLOG.md` (2026-06-10) says `Todo`. Conflicting status across docs.
4. **Triplicated web roadmap:** the FAB-166→174 table appears in `HANDOFF.md`, `PROJECT_STATUS.md`, AND `BACKLOG.md`. Three copies = guaranteed drift. With Linear retired, `BACKLOG.md` is the canonical copy; the other two must link to it.
5. **Linear references are now obsolete:** `CLAUDE.md`, `AGENTS.md`, `README.md`, `PROJECT_STATUS.md`, `LOCALIZATION.md`, and `BACKLOG.md`/`DONE.md` headers all point to Linear as the issue tracker / source of truth. Linear is no longer used.

### B. Redundant / dead files (archive in Phase 2)

| File | Why archive |
|---|---|
| `COMPONENTS.md` (v1.0, Apr 22, Draft) | Superseded by `component-inventory.md` (v1.4, May 2). Flagged in May audit, never resolved. |
| `THEMES.md` (v1.0, Apr 22, Draft) | Superseded by `DESIGN_TOKENS.md` (authoritative hex + WCAG) and `Colors.swift`. |
| `AUDIT_2026-05-02.md` | Self-declared "Historical snapshot — closed". |
| `VERSO_DOCS_REVIEW_2026-06-09.md` | Point-in-time review; actionable items done or carried into this plan. |
| `FAB-77-reading-view-variants.md` | Per-issue working doc; issue complete. |
| `design-system-preview.html` (Apr 19) | Superseded by `DesignSystemPreview.swift` and the Figma file. |
| `explorations/00-Plan-V2-CBDS.md` | Already banner-labeled "not adopted"; move under `_archive/` so the top level only contains live material. |
| `docs/research/` (empty dir) | Delete. |

**Keep active (not archive):** early discovery docs (`proto-personas.md`, `user-frustrations-pocket-instapaper.md`, `site-map.md`, `user-flows*.md`, `feature-priority-per-screen.md`, `navigation-patterns.md`, `interactions-and-gestures.md`) — still referenced by HANDOFF's doc map and useful for the web track. They move into a `product/` subfolder instead (Phase 3).

### C. Structural problems (Phase 3–4)

- 26 loose files at `docs/` top level, mixed naming (`SCREAMING_CASE.md` vs `kebab-case.md`), no signal of what's authoritative vs historical.
- `CLAUDE.md` and `AGENTS.md` at root are parallel hand-maintained copies. `verso-web/` already solved this: its `CLAUDE.md` contains only `@AGENTS.md`. Root should do the same.
- No documented rules for where docs go or how status is tracked.

---

## Phase 1 — Fix doc/code drift (no file moves)

1. **`HANDOFF.md`:**
   - Screens table: Share Extension → "✅ Implemented — `Verso/ShareExtension/`".
   - Regenerate the Services table from the actual contents of `Verso/Sources/Services/`, `Services/Import/`, and `Verso/Shared/` (one row per file; read each file's header comment for purpose).
   - Add `VersoMainSplitView.swift` to the architecture section; mention tag editing/filtering as shipped.
   - **Remove the web roadmap table** — replace with one line: "Web roadmap: see `BACKLOG.md` (the issue tracker)."
   - Bump version to 1.2 with today's date.
2. **`PROJECT_STATUS.md`:**
   - Move Share Extension to ✅ Done.
   - **Remove the per-issue web phase table** — link to `BACKLOG.md` instead. PROJECT_STATUS describes platform-level state only, in prose; issue-level truth lives in `BACKLOG.md`.
   - Refresh date.
3. **Root `AGENTS.md`:** rewrite — see Phase 4 (it becomes the single source, with CLAUDE.md pointing at it). At minimum: active implementation (not discovery), both platforms, 7 design files, web stack section.
4. Cross-check `CLAUDE.md`'s service/file lists against the filesystem and fix any misses.
5. **Retire Linear as the tracker of record (repo-wide):**
   - `BACKLOG.md` header: change "Migrated from Linear. Active issues only" to declare it the **issue tracker of record**. Keep the FAB-xx numbering scheme (continue the sequence for new issues) and document the status vocabulary (`Todo` / `In Progress` / `Backlog` / priority emoji) at the top of the file.
   - `DONE.md` header: "archive of all completed issues" (drop "Linear").
   - `CLAUDE.md` / `AGENTS.md` / `README.md` / `PROJECT_STATUS.md`: remove the Linear project URL from "Key Links" and any "Linear is the source of truth" statements; point to `docs/BACKLOG.md` instead.
   - `LOCALIZATION.md` and any other doc saying work is "tracked in Linear": point to `BACKLOG.md`. (Find them: `grep -rln "linear.app\|Linear" --include="*.md" . | grep -v _archive`.)
   - Existing `linear.app/...` issue URLs inside archived docs and `DONE.md` entries can stay as historical references — do not bulk-edit those.

## Phase 2 — Archive

1. Create `docs/_archive/` with a short `README.md`: "Historical/superseded documents. Nothing here is authoritative. Files keep their original content plus a status banner."
2. `git mv` each file from table B into `docs/_archive/` (keep `explorations/00-Plan-V2-CBDS.md` as `_archive/explorations/00-Plan-V2-CBDS.md`). Delete the empty `docs/research/`.
3. Prepend to each archived file (where not already present):
   `> 🗄️ **ARCHIVED <date>.** Superseded by <successor or "—">. Kept for history; do not implement from this document.`
4. Before archiving `COMPONENTS.md` and `THEMES.md`, diff them against their successors (`component-inventory.md`, `DESIGN_TOKENS.md`) and port over anything genuinely missing.
5. `grep -rn` the repo for references to every moved file (check `CLAUDE.md`, `AGENTS.md`, `README.md`, `HANDOFF.md`, `PROJECT_STATUS.md`, and intra-doc links) and update or remove links.

## Phase 3 — Restructure `docs/` (streamlining)

Target layout — group by purpose, keep the names of frequently-referenced spec files unchanged where possible:

```
docs/
  HANDOFF.md                  ← entry point / index (stays at top level)
  PROJECT_STATUS.md           ← canonical "where are we" (top level)
  BACKLOG.md / DONE.md        ← Linear mirror (top level, the ONLY issue mirror)
  product/                    ← PRD, personas, flows, site map, research-era docs
    PRD_MinimalistReaderApp.md, proto-personas.md, user-frustrations-pocket-instapaper.md,
    site-map.md, user-flows.md, user-flows-secondary.md, feature-priority-per-screen.md,
    navigation-patterns.md, interactions-and-gestures.md
  design/                     ← design-system specs
    DESIGN_SYSTEM_FOUNDATIONS.md, DESIGN_TOKENS.md, COMPONENT_SPECS.md, component-inventory.md,
    animation-spec.md, accessibility-specs.md, ERROR_STATES_SPEC.md,
    FIGMA_DESIGN_SYSTEM_REFERENCE.md, wireframes/, printscreens/
  engineering/                ← implementation specs
    OBSIDIAN_INTEGRATION.md, ANALYTICS_STRATEGY.md, LOCALIZATION.md
  copy/UI_COPY.md             ← unchanged
  figma-plugin/               ← unchanged (includes tokens.json — verify the plugin reads it from there first; if the manifest references it, move it inside figma-plugin/)
  _archive/                   ← Phase 2 output
```

Steps: `git mv` files; then update **every** path reference — `CLAUDE.md`, `AGENTS.md`, `README.md`, `HANDOFF.md` doc map, `PROJECT_STATUS.md`, and relative links inside the docs themselves (grep for each old filename). Finish with a link check: `grep -rno '\](\.\./\?[^)]*\.md)' docs/ *.md` and verify each target exists.

Naming rule going forward (do **not** mass-rename existing files — it breaks history and links): new docs use `SCREAMING_SNAKE.md` for specs/reference, `kebab-case.md` for working/research notes.

## Phase 4 — Write the rules into AGENTS.md + CLAUDE.md

1. Rewrite root `AGENTS.md` as the single source (fixing the staleness in §A.2) and reduce root `CLAUDE.md` to exactly one line — `@AGENTS.md` — matching the pattern already used in `verso-web/`. This permanently kills CLAUDE/AGENTS drift.
2. Add this section to `AGENTS.md` (verbatim):

```markdown
## Documentation Rules

- **All documentation lives in `docs/`.** Never create .md docs at the repo root or inside
  source folders (the only root files are README.md, CLAUDE.md, AGENTS.md, LICENSE).
  Platform-specific agent rules live in the platform folder (e.g. verso-web/AGENTS.md).
- **`docs/HANDOFF.md` is the index.** When you add, move, or archive a doc, update HANDOFF's
  doc map in the same commit.
- **`docs/PROJECT_STATUS.md` is the only place project status lives.** Other docs must not
  restate implementation status — link to it instead.
- **`docs/BACKLOG.md` is the issue tracker of record** (Linear is retired). `docs/DONE.md` is
  the archive of completed issues. Never copy issue tables into other docs — link to BACKLOG.
- **Backlog hygiene:** new issues get the next FAB-xx number; when an issue is completed,
  move its entry from BACKLOG.md to DONE.md (with completion date) in the same commit as
  the implementing change.
- **Every doc starts with a header:** `**Version:** · **Date:** · **Status:**` where Status is
  one of `Draft`, `Active`, `Locked` (decisions final), or `Archived`.
- **Superseded docs are archived, not deleted:** move to `docs/_archive/`, prepend the
  archive banner, and fix all inbound links in the same commit.
- **Per-issue working docs** (e.g. `FAB-77-…md`) move to `_archive/` when the issue closes.
- **Folders:** `product/` (PRD, personas, flows) · `design/` (tokens, components, specs) ·
  `engineering/` (integration/implementation specs) · `copy/` (strings) ·
  `figma-plugin/` · `_archive/`. New top-level docs need a reason to be top-level
  (currently only HANDOFF, PROJECT_STATUS, BACKLOG, DONE).
- **Naming:** `SCREAMING_SNAKE.md` for specs/reference docs, `kebab-case.md` for working
  notes. Don't rename existing files just to conform.
- **When code changes invalidate a doc, update the doc in the same PR** — especially
  HANDOFF's services/screens tables and DESIGN_TOKENS ↔ globals.css parity.
```

3. Update `README.md`'s "Key Documentation" links to the new paths.

## Phase 5 — Verification (required)

- [ ] `grep -rn "design/discovery"` returns nothing outside `_archive/`.
- [ ] `grep -rn "not yet created"` returns nothing outside `_archive/` (Share Extension).
- [ ] The FAB-166→174 table exists only in `BACKLOG.md`.
- [ ] `grep -rln "linear.app" --include="*.md" . | grep -v "_archive\|DONE.md"` returns nothing — no live doc points to Linear as the tracker.
- [ ] `BACKLOG.md` header declares it the issue tracker of record and documents the status/priority vocabulary.
- [ ] Every file in `docs/` (excl. `_archive/`) is reachable from `HANDOFF.md`'s doc map or `PROJECT_STATUS.md`.
- [ ] Every relative `.md` link in `CLAUDE.md`/`AGENTS.md`/`README.md`/`docs/**` resolves to an existing file.
- [ ] Root `CLAUDE.md` contains only `@AGENTS.md`.
- [ ] HANDOFF services table matches `ls Verso/Sources/Services Verso/Sources/Services/Import Verso/Shared` exactly.
- [ ] Figma plugin still loads (if `tokens.json` was moved, manifest updated).

---

## Out of scope / flagged for Fabio

- ~~BACKLOG.md/DONE.md as a Linear mirror~~ — **Decided 2026-06-12: Linear retired; BACKLOG.md is the tracker of record** (handled in Phase 1.5). One consequence to be aware of: a flat Markdown backlog has no per-issue links, assignees, or notifications — fine for a solo project, but the move-to-DONE hygiene rule is what keeps it trustworthy.
- **DONE.md is 88 KB** — fine as an archive, but agents shouldn't read it by default; it's intentionally excluded from HANDOFF's doc map.
- The May audit's localization items (date formatting, WPM constant, plural-aware strings) are tracked in `LOCALIZATION.md` and the BACKLOG's Localization epic — not part of this cleanup.
