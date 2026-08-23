# AGENTS.md

## Project

**Verso** — a minimalist article reader with **iOS and Web** platforms. Currently in **active implementation**.

Articles are saved as plain Markdown files to a user-selected iCloud Drive folder — no proprietary database, no accounts, no lock-in.

- **Figma:** https://www.figma.com/design/WCPHZNg1my8VSSMbLO5bvX/Reader-UI
- **Issue Tracker:** `docs/BACKLOG.md` (Linear retired 2026-06-12)
- **Note:** GitHub Issues on `whysasse/verso-app` is not a tracker and is not kept in sync — it's a leftover migration artifact from the Linear→GitHub move, tidied once (see `docs/DONE.md` "Repo Admin"); don't treat its issue list as authoritative or reconcile it against BACKLOG.md again.

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
- **Filter chips:** All / Unread / Reading / Read. Visible even on empty states.
- **MVP search:** Title-only (no full-text body search).
- **Tags:** Articles can be tagged; filtering/editing via side panel.

### iOS

- **Platform:** SwiftUI, iOS 16+
- **Bundle ID:** `com.fabiosasseron.verso`
- **Entry point:** `Verso/Sources/App/VersoApp.swift` → `ContentView.swift`
- **Navigation:** `NavigationSplitView` (hybrid: collapses to a single stack on iPhone/compact, sidebar + detail side-by-side on iPad/regular); no tab bar; orchestrated by `VersoMainSplitView.swift`
- **Share Extension:** Separate app target at `Verso/ShareExtension/` for saving articles from other apps.
- **Design system code:** 7 Swift files in `Verso/Sources/Design/` (Colors, Typography, Spacing, Radius, ThemeManager, Animation, DesignSystemPreview).

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

Badge colors: unread `#4A90D9` · reading `#D4A353` · read `#5AAF7A` · archived `#8E8E93`
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

- **All documentation lives in `docs/`.** Never create .md docs at the repo root or inside source folders (the only root files are README.md, CLAUDE.md, AGENTS.md, LICENSE). Platform-specific agent rules live in the platform folder (e.g. verso-web/AGENTS.md).

- **`docs/HANDOFF.md` is the index.** When you add, move, or archive a doc, update HANDOFF's doc map in the same commit.

- **`docs/PROJECT_STATUS.md` is the only place project status lives.** Other docs must not restate implementation status — link to it instead.

- **`docs/BACKLOG.md` is the issue tracker of record** (Linear is retired). `docs/DONE.md` is the archive of completed issues. Never copy issue tables into other docs — link to BACKLOG instead.

- **Backlog hygiene:** New issues get the next FAB-xx number; when an issue is completed, move its entry from BACKLOG.md to DONE.md (with completion date) in the same commit as the implementing change. For long-lived parent checklists (e.g. FAB-150), use `Refs #NNN` rather than `Closes #NNN`/`Fixes #NNN` in PR bodies — the closing keywords auto-close the parent issue the moment any one PR merges, even though the checklist isn't done.

- **Every doc starts with a header:** `**Version:** · **Date:** · **Status:**` where Status is one of `Draft`, `Active`, `Locked` (decisions final), or `Archived`.

- **Superseded docs are archived, not deleted:** Move to `docs/_archive/`, prepend the archive banner, and fix all inbound links in the same commit.

- **Per-issue working docs** (e.g. `FAB-77-…md`) move to `_archive/` when the issue closes.

- **Folders:** `product/` (PRD, personas, flows) · `design/` (tokens, components, specs) · `engineering/` (integration/implementation specs) · `copy/` (strings) · `figma-plugin/` · `_archive/`. New top-level docs need a reason to be top-level (currently only HANDOFF, PROJECT_STATUS, BACKLOG, DONE).

- **Naming:** `SCREAMING_SNAKE.md` for specs/reference docs, `kebab-case.md` for working notes. Don't rename existing files just to conform.

- **When code changes invalidate a doc, update the doc in the same PR** — especially HANDOFF's services/screens tables and DESIGN_TOKENS ↔ globals.css parity.

---

## Docs Reference

Only fetch what you need — see `docs/HANDOFF.md` for the full doc map.

| Working on… | Read this |
|-------------|-----------|
| Component dimensions, padding, corner radius | `docs/design/COMPONENT_SPECS.md` |
| Token hex values and WCAG rationale | `docs/design/DESIGN_TOKENS.md` |
| Animation implementation (SwiftUI code) | `docs/design/animation-spec.md` |
| Accessibility (touch targets, VoiceOver) | `docs/design/accessibility-specs.md` |
| Error states (8 scenarios, copy, a11y) | `docs/design/ERROR_STATES_SPEC.md` |
| All UI copy strings | `docs/copy/UI_COPY.md` |
| Localization (locales, plurals, pseudolocalization QA) | `docs/LOCALIZATION.md` |
| User flows and navigation mechanics | `docs/product/user-flows.md`, `docs/product/navigation-patterns.md` |
| Authoritative entry point | `docs/HANDOFF.md` |

