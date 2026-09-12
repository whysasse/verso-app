# AGENTS.md

## Project

**Verso** — a minimalist article reader with **iOS and Web** platforms. Currently in **active implementation**.

Articles are saved as plain Markdown files to a user-selected iCloud Drive folder — no proprietary database, no accounts, no lock-in.

- **Figma:** https://www.figma.com/design/WCPHZNg1my8VSSMbLO5bvX/Reader-UI
- **Issue Tracker:** see `CLAUDE.md`'s `## Workflow → Issues` for what's authoritative. Historical note kept here only: GitHub Issues on `whysasse/verso-app` was tidied once (see `docs/DONE.md` "Repo Admin") — don't reconcile it against BACKLOG.md again.

---

## Implementation Entry Point

**Before starting any implementation task, read `docs/HANDOFF.md` first.** It is the authoritative entry point — inline essentials for the design system, screens, and services, plus a doc map telling you which file to fetch for each domain (components, tokens, error states, animations, accessibility, copy, user flows).

---

## Architecture

### Core (Both Platforms)

- **File-first:** Articles saved as Markdown files to user-selected iCloud Drive folder. This is the source of truth.
- **No proprietary database** — Core Data (iOS) is a read cache only, rebuilt from files.
- **4 Themes:** Paper, Sepia, Night, Ink. Each has 9 semantic color roles.
- **WCAG AA:** All text on all themes (4.5:1 normal, 3:1 large text).
- **Article Status:** Unread → Reading → Read (auto-tracked on scroll).
- **Article list sections:** Continue Reading (pinned first, shows live scroll-progress), Unread, Read (collapsed by default), Archived (collapsed by default). Empty sections are omitted. Replaced the old status filter-chip bar (FAB-292, 2026-08-29) — `FilterChipBar`/`FilterChip` no longer exist; don't reference them.
- **MVP search:** Title-only (no full-text body search).
- **Tags:** Articles can be tagged; filtering/editing via side panel.

### iOS

- **Platform:** SwiftUI, iOS 16+
- **Bundle ID:** `com.fabiosasseron.verso`
- **Entry point:** `Verso/Sources/App/VersoApp.swift` → `ContentView.swift`
- **Navigation:** `NavigationSplitView` (hybrid: collapses to a single stack on iPhone/compact, sidebar + detail side-by-side on iPad/regular); no tab bar; orchestrated by `VersoMainSplitView.swift`
- **Share Extension:** Separate app target at `Verso/ShareExtension/` for saving articles from other apps.
- **Design system code:** 6 Swift files in `Verso/Sources/Design/` (Typography, Spacing, Radius, ThemeManager, Animation, DesignSystemPreview), plus `Colors.swift` in `Verso/Shared/` (FAB-323: moved so the Share Extension can read theme colors too — it's shared with both targets, not main-app-only).

### Web

- **Platform:** Next.js 16, TypeScript, Tailwind CSS, App Router
- **Source:** `verso-web/`
- **Styling:** CSS custom properties in `verso-web/app/globals.css` mirror iOS tokens exactly.
- **Theme system:** React context (`ThemeProvider.tsx`), localStorage persistence, system dark-mode detection.
- **Fonts:** OpenDyslexic bundled locally at `verso-web/public/fonts/`.

---

## Build & Run

### iOS

The Xcode project is generated via XcodeGen:

```bash
cd Verso && ./generate-xcodeproj.sh
```

This bootstraps `Secrets.xcconfig` from the template when missing. If secrets already exist, `cd Verso && xcodegen generate` is sufficient. Then open `Verso/Verso.xcodeproj` in Xcode and press ⌘R.

### Web

```bash
cd verso-web && npm install && npm run dev
```

Runs at `http://localhost:3000`.

---

## Design System — Swift Identifiers

All design enum names are exact Swift identifiers; search the source file to find usage.

### Theme (`Colors.swift`)

```swift
enum VersoTheme: String { case paper, sepia, night, ink }
```

`ThemeManager` injected as `@EnvironmentObject`. Access colors via `themeManager.colors` → `ThemeColors` (9 roles).

### Article Status (`Colors.swift`)

```swift
enum ArticleStatus: String { case unread, reading, read, archived }
```

Badge colors are theme-aware as of FAB-325 (2026-09-05) — see `ArticleStatusColors` in `Colors.swift` for the per-theme table, not a fixed hex per status.
SF Symbols: `circle` · `book.pages` · `checkmark` · `archivebox` (16pt, white, 28×28 badge). (`book.open` is not a real SF Symbol — don't reintroduce it.)

`.archived` is a real, distinct status — filter counts (`FilterChipBar`) and `StatusBadge` must account for it explicitly rather than assuming only 3 cases (FAB-287 was exactly this mistake: the "All" count summed all 4 cases instead of excluding archived).

### Spacing, Radius, Typography, Animation

See `Verso/Sources/Design/` for exact values and `docs/DESIGN_TOKENS.md` for hex codes.

---

## Key Constraints

- **Touch target:** 44×44pt minimum, 8pt spacing between targets
- **WCAG AA:** All text on all 4 themes
- **Dynamic Type:** Reading view supports 6 body sizes
- **Reduce Motion:** Suppress auto-hide animations; instant show/hide only
- **Portrait only:** iOS 16+ minimum
- **Token parity (Web):** `globals.css` custom properties must stay in sync with `docs/DESIGN_TOKENS.md`

---

## SwiftUI Gotchas

- **`#Preview` wrappers:** `@Previewable @State` doesn't compile on iOS 16. Wrap in a `private struct`.
- **`NavigationStack` layout:** `ScrollView` must be direct child. Wrapping in `VStack` clips first element.
- **Background + safe area:** Use `.background(color)` on content, not root view.
- **Toolbar button style:** `.buttonStyle(.plain)` + `.tint(.clear)` needed to remove bubble background on iOS 16+.
- **iCloud security-scoped access:** Always call `startAccessingSecurityScopedResource()` / `stopAccessingSecurityScopedResource()` when reading from iCloud Drive bookmarks.
- **`NavigationSplitView` sidebar → detail navigation:** `NavigationLink(value:)` placed in the sidebar column cannot be opened by a `.navigationDestination(for:)` registered in the detail column — confirmed via a runtime warning ("no matching navigationDestination declaration visible from the location of the link"). SwiftUI only resolves a link's destination within the link's own column, or an enclosing `NavigationStack` — never across sidebar/detail. **Fix:** bind the sidebar's `List` with `selection:` (e.g. `List(selection: $selectedArticle)`) instead — that's the mechanism `NavigationSplitView` actually uses to auto-collapse/push to the detail column on iPhone. Reserve `NavigationLink`/`.navigationDestination(for:)` for pushes that stay *within* one column (e.g. opening a "related article" inside the reader's own `NavigationStack`). See `VersoMainSplitView.swift` (`selectedArticle` vs `detailPath`) and `ArticleListView.swift`.

---

## External Dependencies

| Package | Source | Purpose |
|---------|--------|---------|
| SwiftSoup ≥2.7.6 | github.com/scinfu/SwiftSoup | HTML parsing |
| TelemetryClient ≥2.0.0 | TelemetryDeck/SwiftClient | Analytics |

**Analytics App ID:** `AF772698-A152-4DBF-AEAA-B49EFDC7BF8C`

---

## Documentation Rules

See `CLAUDE.md`'s `## Workflow → Documentation` for the actual rules
(where docs live, header format, archiving, naming, folder layout). Moved
there 2026-09-12 so a session doing docs/backlog work sees them
unconditionally, instead of only when this file happens to get opened —
see `docs/DOC_DRIFT_AUDIT_2026-09-12.md` §G1 for why that mattered.

One rule that stays here, since it's about code-and-doc pairing rather
than doc mechanics: **when code changes invalidate a doc, update the doc
in the same PR** — especially HANDOFF's services/screens tables and
DESIGN_TOKENS ↔ globals.css parity.

---

## Docs Reference

Don't duplicate this table — `docs/HANDOFF.md`'s own "Doc Map" section is
the single, actively-maintained index of which file to read for which
domain. (This used to be a second copy of it here, with paths that had
drifted wrong — see `docs/DOC_DRIFT_AUDIT_2026-09-12.md` §B4.)

