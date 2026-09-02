# Verso — Project Status

**Date:** 2026-09-01 | **PRD Version:** 1.7

---

## What is Verso?

Verso is a minimalist, open-source article reader with iOS and web platforms. Articles are saved as plain Markdown files to a user-selected iCloud Drive folder — no proprietary database, no accounts, no lock-in. It targets readers who value owning their data, especially those already using Obsidian.

**Core differentiator:** File-first architecture. Your articles live in your own files, not a company's database.

---

## Platforms

| Platform | Status |
|----------|--------|
| **iOS** (SwiftUI, iOS 16+) | Implementation underway |
| **Web** (Next.js 16 + TypeScript + Tailwind) | Phases 1–3 complete ✅; Phase 4+ in backlog |

---

## iOS — Current State

The design system and all screen designs are **complete**. Implementation is actively underway.

### ✅ Done

- **Design System** — `Colors.swift`, `Typography.swift`, `Spacing.swift`, `Radius.swift`, `ThemeManager.swift`, `Animation.swift`
- **4 Themes** — Paper, Sepia, Night, Ink (9 semantic color roles each)
- **Services** — Article parsing pipeline: `ArticleParserService`, `MarkdownReader`, `MarkdownWriter`, `ReadabilityParser`, `SwiftSoupParser`
- **Screens (implemented):**
  - Article List (`ArticleListView`, `AddArticleView`)
  - Article Reader (`ArticleReaderView`, `ArticleTagsEditorSheet`)
  - Onboarding flow (Welcome, Theme Picker, Folder Picker, Analytics Consent, Quick Tour)
  - Settings (main view, About, Import, Privacy Policy, in-app web view)
  - Launch screen
- **Components (implemented):**
  - Navigation (`VersoNavigationBar`)
  - Cards (`ArticleCard`, `EmptyState`, `LoadingState`)
  - Inputs (`SearchBar`, `FilterChip`, `FilterChipBar`, `VersoTextField`)
  - Indicators (`StatusBadge`)
  - Buttons (`VersoButton`)
  - Reading (`MarkdownBodyView`, `HighlightableRegionText`, `ReadingChrome`, `ReadingControls`, `ArticleHeader`, `ScrollProgress`, `RelatedArticlesSection`, `ImmersiveHintPill`)
  - Settings (`ThemeSelector`, `SettingsRow`)
- **Live data wiring** — Screens read from Core Data via `@FetchRequest` against `ArticleLibraryService` (e.g. `ArticleListView`); no mock data remains
- **iCloud Drive folder picker** — End-to-end via `FolderBookmarkService` and security-scoped bookmarks (FAB-44, FAB-99)
- **Auto-status progression** — `unread → reading → read` tracked on scroll, persisted to Core Data and YAML frontmatter (FAB-113)
- **Search** — Title-only real-time filter on Home, wired to `SearchBar` (MVP scope; full-text body search is a separate, unshipped issue — FAB-50)
- **Core Data read cache** — Rebuilt from `.md` files via `ICloudFileWatcher` (FAB-9, FAB-12, FAB-13); Phase 2 additions (tags, scroll position, bulk actions) shipped in `d560482` (FAB-51–53)

### 🔲 Remaining (iOS)

Remaining iOS work is tracked in **`docs/BACKLOG.md`** (the issue tracker of record). Non-iPad work is sequenced into three phases as of 2026-08-24 (see BACKLOG.md's "Current sequencing" note for full detail):

- **Phase A (in progress) — ship this release.** FAB-163 (duplicate detection) verified complete and closed 2026-08-24. FAB-164 (GoodLinks import) closed 2026-08-26: a real-file smoke test surfaced a second bug (native-array imports always landed as `.unread`), fixed and reverified against Fabio's real export (86 read / 395 unread, matching the source data) — see `docs/DONE.md`. FAB-150 (App Store release checklist): signing, privacy manifest, the CI release path, and Store & compliance metadata (subtitle, description, keywords, screenshots, privacy nutrition labels, age rating, App Review notes) are all done — Fabio reviewed and entered everything into App Store Connect 2026-08-25, see `docs/APP_STORE_LISTING.md`. Only the final binary submission itself remains.
- **Phase B — localization (FAB-275).** Done 2026-08-25 — all 8 steps complete (see `docs/DONE.md`): FR-CA/PT-BR translated and linguistically QA'd, App Store metadata localized and pasted into App Store Connect, Québec Bill 96 posture decided (risk-accepted, not legally confirmed). FAB-284 (language picker, iOS + Web) also done 2026-08-28 — nothing open in this area.
- **Phase C (after launch) — polish backlog.** Highlighting (FAB-54) done 2026-09-01, and its follow-up FAB-303 (highlighting v2) done 2026-09-02 — the parent issue's original 5 steps and all 3 named follow-ups (headings/lists/blockquotes joining selectable regions; merging with an existing highlight, same-block only; blockquote's colored accent bar) have all shipped — see `docs/DONE.md`. RSVP reading mode (FAB-277) and VoiceOver progress announcement (FAB-278) still need a UX decision from Fabio before implementation.
- **Phase 4 (deferred, excluded from this sequencing): iPad support** (FAB-131, FAB-154 → FAB-162).
- First TestFlight round (FAB-285–288, 2026-08-23): fixed onboarding tour navigation, live file sync on foreground, stale status badges, and the "All" filter count including archived articles — all four caught during Fabio's own TestFlight testing.

---

## Web — Current State

**Phases 1–3 ✅ Complete** (FAB-165 → FAB-170). Scaffolded as a Next.js 16 app with design system ported, article list and reader screens wired to live data, and the full reading experience (scroll persistence, auto-status progression, auto-hide chrome) in place.

### ✅ Done (Phases 1–3)

- Project scaffold (`verso-web/`) — Next.js 16.2.6 + TypeScript 5 (strict mode), Tailwind CSS 4 + PostCSS, directory structure (`app/`, `components/`, `hooks/`, `services/`, `types/`, `public/fonts/`)
- Design tokens ported to `globals.css` — all 4 themes (Paper, Sepia, Night, Ink) + fixed tokens (spacing, typography, radius); `ThemeProvider.tsx` with localStorage persistence and system dark-mode detection (FAB-165)
- Data layer — `Article` type mirroring iOS YAML frontmatter, `FileSystemService` (File System Access API), `useArticleLibrary` hook (FAB-166)
- Article list screen — `ArticleListPage`, `FilterChipBar`, `SearchBar`, `ArticleCard`, `EmptyState`, `LoadingState`, unsupported-browser gate (FAB-167)
- Article reader — `ArticleReaderPage`, `MarkdownRenderer` (`react-markdown` + `remark-gfm`), typography controls (font family/size/line-height), persisted prefs (FAB-168)
- Auto-hide chrome + reading controls panel — `useIdleChrome`, `ScrollProgressBar`, first-use hint, mark-as-read (FAB-169)
- Scroll position persistence + auto-status progression — mirrors iOS: scroll restore/save to YAML frontmatter, `unread → reading` on open, `reading → read` at 90% scroll (FAB-170)
- Dev server verified: `npm run dev` runs cleanly at http://localhost:3000

### 🔲 Remaining (Web)

Web platform issues are tracked in **`docs/BACKLOG.md`** (the issue tracker of record). Phases 4–5 (FAB-171 → FAB-175) remain: URL article ingestion, bulk import (Pocket/Instapaper/GoodLinks), PWA support, and advanced features (TTS, related articles, tags, keyboard shortcuts).

---

## Localization — FAB-275 (EN-CA, FR-CA, PT-BR)

The localization epic is broken into phases reflecting implementation ordering:

| Phase | FAB-275 step | Scope | Status |
|-------|-------------|-------|--------|
| **Phase A** | Steps 6–8 prep | Interim key cleanup, QuickTourView rebuild, AboutView, Obsidian tip, font-size translations, codegen plural fix | ✅ Done 2026-06-21 |
| **Phase B** | Step 6 | Pseudolocalization + layout flex QA (Web pseudo-locale infra, ControlRow label fix) | ✅ Done 2026-06-21 |
| **Phase C** | Step 7 | FR-CA & PT-BR translation + linguistic/diacritic QA | ✅ Done 2026-08-25 |
| **Phase D** | Step 8 | App Store metadata + Québec/Bill 96 compliance | ✅ Done 2026-08-25 |
| **Phase E** | FAB-284 (post-275) | Language picker (iOS + Web) | ✅ Done 2026-08-28 |

See `docs/BACKLOG.md` for detailed step checklists and `docs/DONE.md` for completed issues.

- `HANDOFF.md` — authoritative dev entry point
- `PRD_MinimalistReaderApp.md` — full product requirements
- `DESIGN_TOKENS.md` — hex values and WCAG rationale
- `COMPONENT_SPECS.md` — dimensions, padding, corner radii
- `DESIGN_SYSTEM_FOUNDATIONS.md` — typography, spacing, color philosophy
- `accessibility-specs.md` — touch targets, VoiceOver, QA checklist
- `animation-spec.md` — SwiftUI animation implementation
- `ERROR_STATES_SPEC.md` — 8 error scenarios, copy, accessibility
- `user-flows.md` / `navigation-patterns.md` — flows and navigation mechanics
- `copy/UI_COPY.md` — all UI copy strings
- `ANALYTICS_STRATEGY.md` — TelemetryDeck integration

---

## Key Links

- **Issue Tracker:** `docs/BACKLOG.md` (Linear retired 2026-06-12)
- **Figma:** https://www.figma.com/design/WCPHZNg1my8VSSMbLO5bvX/Reader-UI
