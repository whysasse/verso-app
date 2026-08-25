# Verso — Developer Handoff

**Version:** 1.3 | **Date:** 2026-08-03 | **Status:** Ready for development

This is the AI entry point for implementation. Read this file first, then fetch the linked docs only for the specific domain you're working in.

Verso now has two platforms: **iOS** (MVP shipped) and **Web** (Next.js, in active development). Most sections below apply to iOS. See the [Web Platform](#web-platform) section for web-specific architecture.

---

## Architecture — iOS

- **Platform:** SwiftUI, iOS 16+, iCloud Drive
- **Bundle ID:** `com.fabiosasseron.verso`
- **Entry point:** `Verso/Sources/App/VersoApp.swift` → `ContentView.swift`
- **File-first:** Articles are Markdown files in a user-selected iCloud Drive folder. This is the source of truth.
- **Core Data** (`CoreDataStack.shared`) is a read cache only — never write authoritative state to it.
- **Core Data threading:** any service that fetches, mutates, or saves via `CoreDataStack.shared.persistentContainer.viewContext` must be `@MainActor`-isolated, since `viewContext` is confined to the main thread — see `ArticleLibraryService`, `ImportOrchestrator`, and `PendingArticleIngester` for the pattern. Skipping this caused a real crash (FAB-291, `docs/DONE.md`) when a background `Task` raced the UI's reads of the same Core Data objects.
- **No tab bar.** Single `NavigationStack` throughout.
- **Navigation:** `VersoMainSplitView.swift` orchestrates the root split/navigation structure.
- **Share Extension** is a separate app target for saving articles from other apps.
- **Tags:** Articles can be tagged; filtering/editing via side panel and `ArticleTagsEditorSheet`.

---

## Web Platform

Scaffolded in `verso-web/` as a Next.js 16 + TypeScript + Tailwind app (App Router). The design system is ported to CSS custom properties so it stays in sync with the iOS token definitions in `docs/DESIGN_TOKENS.md`.

### Stack

- **Framework:** Next.js 16, TypeScript, Tailwind CSS, App Router
- **Entry point:** `verso-web/app/layout.tsx` wraps the app in `ThemeProvider`
- **Styling:** `verso-web/app/globals.css` — all tokens as CSS custom properties
- **Theme switching:** `verso-web/app/providers/ThemeProvider.tsx` — React context, `localStorage` persistence, system dark-mode detection on first visit

### CSS Token Naming

Tokens in `globals.css` mirror the iOS design system:

| Category | CSS variable pattern | Example |
|---|---|---|
| Theme colors | `--color-<role>` | `--color-background`, `--color-text-primary` |
| Article status | `--color-status-<state>` | `--color-status-unread` (#4A90D9) |
| Spacing | `--spacing-<scale>` | `--spacing-md` (16px) |
| Radius | `--radius-<scale>` | `--radius-pill` (20px) |
| UI typography | `--type-ui-<style>-<prop>` | `--type-ui-list-title-size` (17px) |
| Reading typography | `--type-reading-<style>-<prop>` | `--type-reading-body-md-size` (18px) |

Themes (`paper` · `sepia` · `night` · `ink`) are applied as `data-theme="<name>"` on `<html>`. Each theme block overrides the 9 semantic color roles: `background`, `surface`, `text-primary`, `text-secondary`, `accent`, `accent-pressed`, `accent-surface`, `border`, `placeholder`.

### Fonts

OpenDyslexic is bundled at `verso-web/public/fonts/OpenDyslexic-Regular.ttf` and loaded via `@font-face` in `globals.css`, matching the iOS implementation.

### Web Roadmap

See **`docs/BACKLOG.md`** for the authoritative issue tracker. Phases 1–3 (FAB-165 through FAB-170) are done; remaining web backlog is FAB-171 through FAB-175 — see `docs/PROJECT_STATUS.md` for current status.

Place new web screens under `verso-web/app/<screen>/page.tsx`.

---

## Design System — Swift Identifiers (iOS)

All design enum names are exact Swift identifiers. Search the source file to find usage.

### Theme (`Verso/Sources/Design/Colors.swift`)

```swift
enum VersoTheme: String { case paper, sepia, night, ink }
```

`ThemeManager` is injected as `@EnvironmentObject`. Access colors via `themeManager.colors` which returns `ThemeColors`.

**ThemeColors roles** (9 properties):
`background` · `surface` · `textPrimary` · `textSecondary` · `accent` · `accentPressed` · `accentSurface` · `border` · `placeholder`

**SemanticColors** (theme-dependent, same file):
`error` · `warning` · `success`

### Article Status (`Verso/Sources/Design/Colors.swift`)

```swift
enum ArticleStatus: String { case unread, reading, read }
```

Status lifecycle: `unread → reading → read` (auto-tracked on scroll)  
Badge colors: unread `#4A90D9` · reading `#D4A353` · read `#5AAF7A`  
SF Symbol per status: `circle` · `book.open` · `checkmark` (white, 16pt, 28×28 circular badge)

### Spacing (`Verso/Sources/Design/Spacing.swift`)

```swift
enum VersoSpacing {
    xxs=4  xs=8  sm=12  md=16  lg=24  xl=32  xxl=48  xxxl=64
}
```

### Radius (`Verso/Sources/Design/Radius.swift`)

```swift
enum VersoRadius { sm=10  md=12  lg=18  pill=20 }
```

### Typography (`Verso/Sources/Design/Typography.swift`)

UI styles (static): `screenTitle`(34/bold) · `listTitle`(17/semibold) · `listSubtitle`(15/regular) · `button`(17/semibold) · `caption`(13/regular) · `input`(17/regular)

Reading styles (instance, font-family aware): `h1`(28/bold) · `h2`(24/semibold) · `h3`(20/semibold) · `h4`(18/semibold) · `body(BodySize)` where `BodySize` ∈ {xs=14, sm=16, md=18, lg=20, xl=22, xxl=26}

### Animation (`Verso/Sources/Design/Animation.swift`)

```swift
enum VersoAnimation { fast=easeOut(0.15)  normal=easeInOut(0.25)  slow=spring(0.4,0.75)  spinner=linear(0.8).repeatForever }
```

---

## Screens

| Screen | Status | Source |
|--------|--------|--------|
| Article List | ✅ Implemented | `Verso/Sources/Screens/ArticleList/` |
| Article Reader | ✅ Implemented | `Verso/Sources/Screens/ArticleReader/` |
| Onboarding | ✅ Implemented | `Verso/Sources/Screens/Onboarding/` |
| Settings | ✅ Implemented | `Verso/Sources/Screens/Settings/` |
| Launch | ✅ Implemented | `Verso/Sources/Screens/Launch/` |
| Share Extension | ✅ Implemented | `Verso/ShareExtension/` |

New screens go under `Verso/Sources/Screens/<ScreenName>/`.

---

## Services (existing)

### Core Services

| File | Purpose |
|------|---------|
| `Services/ArticleLibraryService.swift` | Central article library — list, filter, search |
| `Services/ArticleParserService.swift` | Orchestrates parsing pipeline |
| `Services/MarkdownReader.swift` | Reads article `.md` files from disk; gracefully adopts files with no frontmatter or no `title` (FAB-290) instead of skipping them |
| `Services/MarkdownWriter.swift` | Writes article `.md` files to disk; `adoptIfNeeded` performs the one-time rename+merge for manually-added files (FAB-290) |
| `Services/AdoptionNoticeService.swift` | Publishes the one-time "file adopted" notice shown at the app root (FAB-290) |
| `Services/ReadabilityParser.swift` | Extracts readable content from HTML |
| `Services/FolderBookmarkService.swift` | Persists iCloud folder security-scoped bookmark |
| `Services/ICloudFileWatcher.swift` | Watches iCloud folder for file changes |
| `Services/ReadingPreferencesService.swift` | Persists font, size, spacing preferences |
| `Services/RelatedArticlesService.swift` | Finds related articles by tag/domain |
| `Services/TTSService.swift` | Text-to-speech playback |
| `Services/AnalyticsService.swift` | TelemetryDeck event logging |
| `Services/ArticleMarkdownImageLocalizer.swift` | Downloads and localizes remote images |
| `Services/PendingArticleIngester.swift` | Ingests articles queued by Share Extension |
| `Services/ArticlePlainText.swift` | Converts articles to plain text |
| `Services/DebugSeedService.swift` | Seeds test data for debugging |
| `Services/ParsedArticle.swift` | Data model for parsed article content |

### Import Services

| File | Purpose |
|------|---------|
| `Services/Import/ImportOrchestrator.swift` | Bulk import entry point |
| `Services/Import/ImportFileParser.swift` | Parses generic import file formats |
| `Services/Import/PocketParser.swift` | Parses Pocket export CSV |
| `Services/Import/InstapaperParser.swift` | Parses Instapaper export CSV |
| `Services/Import/GoodLinksParser.swift` | Parses GoodLinks export |
| `Services/Import/MatterParser.swift` | Parses Matter export |
| `Services/Import/ReadwiseParser.swift` | Parses Readwise export |

### Shared Utilities (App + Share Extension)

| File | Purpose |
|------|---------|
| `Shared/AppConstants.swift` | App-wide constants and configuration |
| `Shared/ArticleDuplicateFinder.swift` | Deduplication logic |
| `Shared/ArticleParsingError.swift` | Error types for parsing pipeline |
| `Shared/DuplicateSaveResolution.swift` | Duplicate resolution strategy |
| `Shared/LibraryBookmarkResolver.swift` | Resolves security-scoped bookmark to folder URL |
| `Shared/PendingArticle.swift` | Data model for articles pending ingestion |
| `Shared/ReadingEstimate.swift` | WPM-based reading time calculation |
| `Shared/ShareDuplicateArticleTitle.swift` | Duplicate detection for Share Extension |
| `Shared/SwiftSoupParser.swift` | HTML parsing via SwiftSoup |
| `Shared/VersoArticleURL.swift` | Article URL parsing and validation |

---

## Doc Map — Fetch Only What You Need

| Working on… | Read this file |
|-------------|---------------|
| Component dimensions, padding, corner radius | `docs/COMPONENT_SPECS.md` |
| Token hex values and WCAG rationale | `docs/DESIGN_TOKENS.md` |
| Error states (8 scenarios, copy, accessibility) | `docs/ERROR_STATES_SPEC.md` |
| Animation implementation (SwiftUI code examples) | `docs/animation-spec.md` |
| Accessibility (touch targets, VoiceOver, QA checklist) | `docs/accessibility-specs.md` |
| All UI copy strings (iOS + Web base `en`) | `docs/copy/UI_COPY.md` |
| Codegen: generate Localizable.xcstrings / L10n.swift / Web message JSONs | `docs/copy/codegen/generate.py` |
| Codegen: pseudo-locale for layout-flex QA (accented +30%) | `docs/copy/codegen/pseudolocalize.py` |
| Localization — locales, plurals, formatting, invariants, pseudolocalization (EN-CA/FR-CA/PT-BR) | `docs/LOCALIZATION.md` |
| Linguistic review checklist (send to translator) | `docs/copy/UI_COPY_LINGUISTIC_REVIEW_fr-CA.md` or `docs/copy/UI_COPY_LINGUISTIC_REVIEW_pt-BR.md` |
| App Store Connect listing draft (EN) | `docs/APP_STORE_LISTING.md` |
| App Store Connect listing draft (fr-CA / pt-BR) | `docs/APP_STORE_LISTING_LOCALIZED.md` |
| User flows and navigation mechanics | `docs/user-flows.md`, `docs/navigation-patterns.md` |
| Design system philosophy and reading behavior | `docs/DESIGN_SYSTEM_FOUNDATIONS.md` |
| iCloud/Obsidian file-first decisions | `docs/OBSIDIAN_INTEGRATION.md` |
| Analytics strategy, event catalog, TelemetryDeck integration | `docs/ANALYTICS_STRATEGY.md` |
| Figma token naming | `docs/FIGMA_DESIGN_SYSTEM_REFERENCE.md` |
| Full product requirements | `docs/PRD_MinimalistReaderApp.md` |
| Web CSS tokens (authoritative source) | `verso-web/app/globals.css` |
| Web theme provider implementation | `verso-web/app/providers/ThemeProvider.tsx` |

---

## Key Constraints — iOS

- **Minimum touch target:** 44×44pt with 8pt spacing between targets
- **WCAG AA required:** All text on all 4 themes (4.5:1 normal, 3:1 large)
- **Dynamic Type:** Reading view supports 6 body sizes; UI uses system TextStyle
- **Reduce Motion:** Suppress auto-hide animations; replace with instant show/hide
- **MVP search:** Title-only (no full-text body search)
- **No proprietary database** — never store canonical article data in Core Data

## Key Constraints — Web

- **Token parity:** CSS custom properties in `globals.css` must stay in sync with `docs/DESIGN_TOKENS.md`. If a token value changes, update both.
- **WCAG AA required:** Same contrast requirements as iOS apply to all 4 themes on web.
- **Theme data attribute:** Always set theme via `data-theme` on `<html>` — never via class names — so CSS variable scoping works correctly.
- **File-first:** The web platform reads the same Markdown files as iOS (via the filesystem or iCloud). No separate database.
- **OpenDyslexic:** Must be bundled locally (`public/fonts/`) — do not load from an external CDN.
