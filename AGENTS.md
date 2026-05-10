# AGENTS.md

## Project
Verso — a minimalist iOS article reader app. Currently in **design/discovery phase**.

## Linear
Issues: https://linear.app/fabiosasseron/project/verso-095ee52ef44b/issues

## Figma
File: https://www.figma.com/design/WCPHZNg1my8VSSMbLO5bvX/Reader-UI
- 🧩 Components: node-id=13:201
- 📱 Home screen: node-id=30:41
- 📖 Reading view: node-id=31:1701
- ⚙️ Settings screen: node-id=34:2877

## Implementation Entry Point

**Before starting any implementation task, read `docs/HANDOFF.md` first.** It is the authoritative entry point — inline essentials for the design system, screens, and services, plus a doc map that tells you which file to fetch for each domain (components, tokens, error states, animations, accessibility, copy, user flows).

## Architecture (from PRD)

- **File-first**: Articles saved as Markdown files to user-selected iCloud Drive folder. No proprietary database.
- **Core Data**: Used only as local read cache, rebuilt from files — never the source of truth
- **Bundle ID**: `com.fabiosasseron.verso`
- **Tech Stack**: SwiftUI, iOS 16+, iCloud Drive
- **Share Extension**: Separate entry point for saving articles from other apps
- **Design system code**: 5 Swift files in `Verso/Sources/Design/` (Colors, Typography, Spacing, Radius, ThemeManager)

## Key Design Decisions

- Single NavigationStack (no tab bar)
- Article status: Unread → Reading → Read (auto-tracked on scroll)
- Filter chips: All / Unread / Reading / Read
- MVP has title search only, no full-text search in body

## Running Commands

The Xcode project is generated via XcodeGen. To regenerate: `cd Verso && ./generate-xcodeproj.sh` (bootstraps `Secrets.xcconfig` from the template when missing). If secrets already exist, `cd Verso && xcodegen generate` is equivalent.

Open `Verso/Verso.xcodeproj` in Xcode and press ⌘R. No CLI `xcodebuild` commands are configured.

---

## Source Layout

```
Verso/
  project.yml                        ← XcodeGen config (edit this, not .xcodeproj)
  Sources/
    App/
      VersoApp.swift                 ← Entry point
      ContentView.swift              ← Root view (NavigationStack lives here)
      DocumentPicker.swift
    Design/
      Colors.swift                   ← VersoTheme, ThemeColors, ArticleStatus, SemanticColors
      Typography.swift               ← VersoTypography
      Spacing.swift                  ← VersoSpacing
      Radius.swift                   ← VersoRadius
      Animation.swift                ← VersoAnimation
      ThemeManager.swift             ← @EnvironmentObject for theming
      DesignSystemPreview.swift
    Components/
      Buttons/VersoButton.swift
      Cards/ArticleCard.swift, EmptyState.swift, LoadingState.swift
      Indicators/StatusBadge.swift
      Inputs/FilterChip.swift, FilterChipBar.swift, SearchBar.swift, VersoTextField.swift
      Reading/ArticleHeader.swift, ImmersiveHintPill.swift, MarkdownBodyView.swift,
              ReadingChrome.swift, ReadingControls.swift, RelatedArticlesSection.swift, ScrollProgress.swift
      Settings/SettingsRow.swift, ThemeSelector.swift
      FolderPickerPrompt.swift
      VersoNavigationBar.swift
    Screens/
      ArticleList/ArticleListView.swift, AddArticleView.swift
      ArticleReader/ArticleReaderView.swift
      Launch/LaunchView.swift
      Onboarding/OnboardingFlowView.swift, WelcomeView.swift, OnboardingFolderPickerView.swift,
                 OnboardingThemePickerView.swift, QuickTourView.swift, AnalyticsConsentView.swift
      Settings/SettingsView.swift, AboutView.swift, ImportView.swift, InAppWebView.swift, PrivacyPolicyView.swift
    Services/
      ArticleLibraryService.swift    ← Main article store
      ArticleParserService.swift     ← Parsing orchestration
      FolderBookmarkService.swift    ← iCloud folder selection & security-scoped access
      ICloudFileWatcher.swift        ← File system observer
      MarkdownReader.swift / MarkdownWriter.swift
      ParsedArticle.swift            ← Parsed article value type
      PendingArticleIngester.swift
      ReadabilityParser.swift        ← HTML → readable content
      ReadingPreferencesService.swift
      RelatedArticlesService.swift
      TTSService.swift
      AnalyticsService.swift         ← TelemetryDeck wrapper
      DebugSeedService.swift
      Import/
        ImportOrchestrator.swift
        PocketParser, InstapaperParser, ReadwiseParser, GoodLinksParser, MatterParser
```

---

## Design System — Swift Identifiers

### Theme

```swift
// Colors.swift
enum VersoTheme: String { case paper, sepia, night, ink }
```

`ThemeManager` injected as `@EnvironmentObject`. Access colors via `themeManager.colors` → `ThemeColors`.

**ThemeColors roles (9):** `background` · `surface` · `textPrimary` · `textSecondary` · `accent` · `accentPressed` · `accentSurface` · `border` · `placeholder`

**SemanticColors (theme-dependent):** `error` · `warning` · `success`

### Article Status

```swift
// Colors.swift
enum ArticleStatus: String { case unread, reading, read }
```

Badge colors: unread `#4A90D9` · reading `#D4A353` · read `#5AAF7A`
SF Symbols: `circle` · `book.open` · `checkmark` (white, 16pt, 28×28 circular badge)

### Spacing

```swift
// Spacing.swift — VersoSpacing
xxs=4  xs=8  sm=12  md=16  lg=24  xl=32  xxl=48  xxxl=64
```

### Radius

```swift
// Radius.swift — VersoRadius
sm=10  md=12  lg=18  pill=20
```

### Typography

**UI styles (static):** `screenTitle`(34/bold) · `listTitle`(17/semibold) · `listSubtitle`(15/regular) · `button`(17/semibold) · `caption`(13/regular) · `input`(17/regular)

**Reading styles (instance, font-family aware):** `h1`(28/bold) · `h2`(24/semibold) · `h3`(20/semibold) · `h4`(18/semibold) · `body(BodySize)` where `BodySize` ∈ {xs=14, sm=16, md=18, lg=20, xl=22, xxl=26}

### Animation

```swift
// Animation.swift — VersoAnimation
fast=easeOut(0.15)  normal=easeInOut(0.25)  slow=spring(0.4,0.75)  spinner=linear(0.8).repeatForever
```

---

## Key Constraints

- **Minimum touch target:** 44×44pt with 8pt spacing between targets
- **WCAG AA required:** All text on all 4 themes (4.5:1 normal text, 3:1 large text)
- **Dynamic Type:** Reading view supports 6 body sizes; UI uses system TextStyle
- **Reduce Motion:** Suppress auto-hide animations; replace with instant show/hide
- **MVP search:** Title-only (no full-text body search)
- **No proprietary database** — never store canonical article data in Core Data
- **Portrait only** — `UIRequiresFullScreen: true` in project.yml (required to avoid Xcode validation error)
- **iOS 16+ minimum**

---

## SwiftUI Gotchas (learned from this codebase)

- **`#Preview` wrappers:** `@Previewable @State` does not compile on iOS 16. Always wrap preview state in a `private struct`.
- **Core Data preview context:** Use `CoreDataStackValue.preview` (it's the class with the preview context). `CoreDataStack` is a namespace enum only.
- **`NavigationStack` layout:** `ScrollView` must be a direct child of `NavigationStack`. Wrapping it in a `VStack` misaligns the nav bar inset, clipping the first element.
- **Background + safe area:** `.background(color.ignoresSafeArea())` propagates to the parent, starting content at Y=0 behind the nav bar. Use `.background(color)` on content views, not the root.
- **Toolbar button style:** `.buttonStyle(.plain)` alone doesn't remove the iOS 16+ bubble background. Add `.tint(.clear)` as well.
- **UIWindow background:** SwiftUI `ignoresSafeArea()` doesn't reach the `UIWindow`. Set `backgroundColor` via `UIApplication` on `.onAppear` and on theme change.
- **iCloud security-scoped access:** Must call `startAccessingSecurityScopedResource()` / `stopAccessingSecurityScopedResource()` when reading articles from iCloud Drive bookmark URLs.

---

## External Dependencies

| Package | Source | Purpose |
|---------|--------|---------|
| SwiftSoup ≥2.7.6 | github.com/scinfu/SwiftSoup | HTML parsing |
| TelemetryClient ≥2.0.0 | TelemetryDeck/SwiftClient | Analytics |

Analytics App ID: `AF772698-A152-4DBF-AEAA-B49EFDC7BF8C`

---

## Docs Reference

Only fetch what you need:

| Working on… | Read this |
|-------------|-----------|
| Component dimensions, padding, corner radius | `docs/COMPONENT_SPECS.md` |
| Token hex values and WCAG rationale | `docs/DESIGN_TOKENS.md` |
| Error states (8 scenarios, copy, a11y) | `docs/ERROR_STATES_SPEC.md` |
| Animation SwiftUI code examples | `docs/animation-spec.md` |
| Accessibility (touch targets, VoiceOver, QA checklist) | `docs/accessibility-specs.md` |
| All UI copy strings | `docs/copy/UI_COPY.md` |
| User flows and navigation mechanics | `docs/user-flows.md`, `docs/navigation-patterns.md` |
| Design system philosophy | `docs/DESIGN_SYSTEM_FOUNDATIONS.md` |
| iCloud / file-first decisions | `docs/OBSIDIAN_INTEGRATION.md` |
| Analytics event catalog | `docs/ANALYTICS_STRATEGY.md` |
| Full product requirements | `docs/PRD_MinimalistReaderApp.md` |
| Authoritative entry point summary | `docs/HANDOFF.md` |

## Figma & Linear Tool Status

### Critical Finding
⚠️ Most Figma REST API tools don't exist - they only exist as `figma-console_*` versions requiring the Desktop Bridge plugin.

### Model Limitations
| Limitation | Affected Tools | Workaround |
|------------|-----------------|------------|
| Most Figma tools only as figma-console_* | See table below | Requires Desktop Bridge |
| Model cannot analyze images | figma-console_figma_capture_screenshot, figma-console_figma_get_component_image | SKIP |

### Figma REST API Tools (Limited)
| Tool | Status | Notes |
|------|--------|-------|
| figma_get_design_context | ❌ | Returns error on use |
| figma_get_variable_defs | ✅ | Returns color values |
| figma_get_metadata | ✅ | Returns canvas tree |
| figma_create_design_system_rules | ⚠️ | Wrong tool - generates code |

## Tools Not Tested / Failed

### Untested (need testing)
- linear_save_issue
- linear_create_attachment
- figma-console_figma_set_text
- figma-console_figma_create_child
- figma-console_figma_setup_design_tokens

### Tools DON'T EXIST (Use figma-console_* versions)
| Tool | Notes |
|------|-------|
| figma_get_component | Only figma-console version |
| figma_get_component_for_development | Only figma-console version |
| figma_get_styles | Only figma-console version |
| figma_get_variables | Only figma-console version |
| figma_get_file_data | Only figma-console version |
| figma_get_design_system_kit | Only figma-console version |
| figma_get_comments | Only figma-console version (requires scope) |
| figma_get_screenshot | DOES NOT EXIST |

### Figma Plugin/Console Tools (require Desktop Bridge)
| Tool | Status | Notes |
|------|--------|-------|
| figma-console_figma_get_file_data | ✅ | Works |
| figma-console_figma_get_variables | ✅ | Works - 24 variables |
| figma-console_figma_get_component | ✅ | Works |
| figma-console_figma_get_component_for_development | ✅ | Works |
| figma-console_figma_get_component_for_development_deep | ✅ | Works |
| figma-console_figma_analyze_component_set | ✅ | Works |
| figma-console_figma_get_file_for_plugin | ✅ | Works |
| figma-console_figma_get_text_styles | ✅ | Works - 30 styles |
| figma-console_figma_lint_design | ✅ | Works |
| figma-console_figma_audit_component_accessibility | ✅ | Works |
| figma-console_figma_get_design_system_kit | ⚠️ | Input validation error (include param) |
| figma-console_figma_execute | ✅ | Works |
| figma-console_figma_get_comments | ❌ | Missing scope (403) |
| figma-console_figma_capture_screenshot | ❌ SKIP | Model can't analyze images |
| figma-console_figma_get_component_image | ❌ SKIP | Model can't analyze images |

Write/Manipulation Tools: (Tested)
| Tool | Status | Notes |
|------|--------|-------|
| figma-console_figma_resize_node | ✅ | Works |
| figma-console_figma_move_node | ✅ | Works |
| figma-console_figma_set_fills | ✅ | Works |
| figma-console_figma_clone_node | ✅ | Works |
| figma-console_figma_rename_node | ✅ | Works |
| figma-console_figma_set_text | ✅ | Works |
| figma-console_figma_create_child | ✅ | Works |

Variable Management:
| Tool | Status | Notes |
|------|--------|-------|
| figma-console_figma_create_variable_collection | ✅ | Works |
| figma-console_figma_add_mode | ✅ | Works |
| figma-console_figma_create_variable | ✅ | Works |
| figma-console_figma_update_variable | ✅ | Works |
| figma-console_figma_batch_create_variables | ✅ | Works |
| figma-console_figma_setup_design_tokens | ✅ | Works |

### Linear Tools (Full Support)
| Tool | Status | Notes |
|------|--------|-------|
| linear_get_issue | ✅ | Works |
| linear_list_issues | ✅ | Works |
| linear_save_issue | ✅ | Works |
| linear_list_issue_statuses | ✅ | Works |
| linear_get_issue_status | ✅ | Works |
| linear_list_issue_labels | ✅ | Works |
| linear_create_issue_label | ✅ | Works |
| linear_list_projects | ✅ | Works |
| linear_get_project | ✅ | Works |
| linear_save_project | ✅ | Works |
| linear_list_project_labels | ✅ | Works |
| linear_list_milestones | ✅ | Works |
| linear_get_milestone | ✅ | Works |
| linear_save_milestone | ✅ | Works |
| linear_list_teams | ✅ | Works |
| linear_get_team | ✅ | Works |
| linear_list_users | ✅ | Works |
| linear_get_user | ✅ | Works |
| linear_list_comments | ✅ | Works |
| linear_save_comment | ✅ | Works |
| linear_delete_comment | ✅ | Works |
| linear_get_document | ✅ | Works |
| linear_list_documents | ✅ | Works |
| linear_save_document | ✅ | Works |
| linear_get_attachment | ✅ | Works |
| linear_create_attachment | ✅ | Works |
| linear_delete_attachment | ✅ | Works |
| linear_list_cycles | ✅ | Works |
| linear_search_documentation | ✅ | Works |