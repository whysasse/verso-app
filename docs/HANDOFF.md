# Verso — Developer Handoff

**Version:** 1.0 | **Date:** 2026-05-03 | **Status:** Ready for development

This is the AI entry point for implementation. Read this file first, then fetch the linked docs only for the specific domain you're working in.

---

## Architecture

- **Platform:** SwiftUI, iOS 16+, iCloud Drive
- **Bundle ID:** `com.fabiosasseron.verso`
- **Entry point:** `Verso/Sources/App/VersoApp.swift` → `ContentView.swift`
- **File-first:** Articles are Markdown files in a user-selected iCloud Drive folder. This is the source of truth.
- **Core Data** (`CoreDataStack.shared`) is a read cache only — never write authoritative state to it.
- **No tab bar.** Single `NavigationStack` throughout.
- **Share Extension** is a separate app target for saving articles from other apps.

---

## Design System — Swift Identifiers

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

| Screen | Status | Primary components |
|--------|--------|--------------------|
| Article List | Design complete | NavigationBar, SearchBar, FilterChips, ArticleRow |
| Reading View | Design complete | TopBar (auto-hide), BodyText, BottomBar (auto-hide), ReadingControls sheet |
| Settings | Design complete | ThemePicker, FontPicker, SpacingSlider, FolderPicker |
| Onboarding | Design complete | FolderPicker, CTA |
| Share Extension | Design complete | ParseProgress, ArticlePreview, SaveButton |

Source files for screens are not yet created — screens are to be implemented. Place them under `Verso/Sources/Screens/<ScreenName>/`.

---

## Services (existing)

| File | Purpose |
|------|---------|
| `Services/ArticleParserService.swift` | Orchestrates parsing pipeline |
| `Services/ArticleParsingError.swift` | Error enum for parsing failures |
| `Services/ParsedArticle.swift` | Parsed article value type |
| `Services/PendingArticle.swift` | In-flight article before save |
| `Services/MarkdownReader.swift` | Reads article `.md` files from disk |
| `Services/MarkdownWriter.swift` | Writes article `.md` files to disk |
| `Services/ReadabilityParser.swift` | Extracts readable content from HTML |
| `Services/SwiftSoupParser.swift` | HTML parsing via SwiftSoup |

---

## Doc Map — Fetch Only What You Need

| Working on… | Read this file |
|-------------|---------------|
| Component dimensions, padding, corner radius | `docs/COMPONENT_SPECS.md` |
| Token hex values and WCAG rationale | `docs/DESIGN_TOKENS.md` |
| Error states (8 scenarios, copy, accessibility) | `docs/ERROR_STATES_SPEC.md` |
| Animation implementation (SwiftUI code examples) | `docs/animation-spec.md` |
| Accessibility (touch targets, VoiceOver, QA checklist) | `docs/accessibility-specs.md` |
| All UI copy strings | `docs/copy/UI_COPY.md` |
| User flows and navigation mechanics | `docs/user-flows.md`, `docs/navigation-patterns.md` |
| Design system philosophy and reading behavior | `docs/DESIGN_SYSTEM_FOUNDATIONS.md` |
| iCloud/Obsidian file-first decisions | `docs/OBSIDIAN_INTEGRATION.md` |
| Analytics strategy, event catalog, TelemetryDeck integration | `docs/ANALYTICS_STRATEGY.md` |
| Figma token naming | `docs/FIGMA_DESIGN_SYSTEM_REFERENCE.md` |
| Full product requirements | `docs/PRD_MinimalistReaderApp.md` |

---

## Key Constraints

- **Minimum touch target:** 44×44pt with 8pt spacing between targets
- **WCAG AA required:** All text on all 4 themes (4.5:1 normal, 3:1 large)
- **Dynamic Type:** Reading view supports 6 body sizes; UI uses system TextStyle
- **Reduce Motion:** Suppress auto-hide animations; replace with instant show/hide
- **MVP search:** Title-only (no full-text body search)
- **No proprietary database** — never store canonical article data in Core Data
