# Verso — Project Status

**Date:** 2026-06-12 | **PRD Version:** 1.7

---

## What is Verso?

Verso is a minimalist, open-source article reader with iOS and web platforms. Articles are saved as plain Markdown files to a user-selected iCloud Drive folder — no proprietary database, no accounts, no lock-in. It targets readers who value owning their data, especially those already using Obsidian.

**Core differentiator:** File-first architecture. Your articles live in your own files, not a company's database.

---

## Platforms

| Platform | Status |
|----------|--------|
| **iOS** (SwiftUI, iOS 16+) | Implementation underway |
| **Web** (Next.js 16 + TypeScript + Tailwind) | Scaffolded, Phase 1 in progress |

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
  - Reading (`MarkdownBodyView`, `ReadingChrome`, `ReadingControls`, `ArticleHeader`, `ScrollProgress`, `RelatedArticlesSection`, `ImmersiveHintPill`)
  - Settings (`ThemeSelector`, `SettingsRow`)

### 🔲 Remaining (iOS)

- Wiring screens to live data via the services layer
- iCloud Drive folder picker integration end-to-end
- Auto-status progression on scroll (unread → reading → read)
- Search functionality (title-only MVP)
- Core Data read cache sync

---

## Web — Current State

Scaffolded as a Next.js 16 app. Phase 1 (data layer) is underway.

### ✅ Done

- Project scaffold (`verso-web/`)
- Design tokens as CSS custom properties in `globals.css` (mirroring iOS tokens)
- Theme system (`ThemeProvider.tsx`) — context, `localStorage` persistence, system dark-mode detection
- Data layer foundation: `FileSystemService.ts`, `article.ts` types, `useArticleLibrary` hook

### 🔲 Remaining (Web)

Web platform issues are tracked in **`docs/BACKLOG.md`** (the issue tracker of record). Current work spans phases 1–5, from data layer through to PWA support and advanced features (FAB-166 → FAB-174).

---

## Documentation

All design specs are finalized in `docs/`:

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
