# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**Verso** — a minimalist iOS article reader app. Currently in **design/discovery phase**.

- Linear issues: https://linear.app/fabiosasseron/project/verso-095ee52ef44b/issues
- Figma file: https://www.figma.com/design/WCPHZNg1my8VSSMbLO5bvX/Reader-UI

## Build & Run

The Xcode project is generated via [XcodeGen](https://github.com/yonaskolb/XcodeGen). To regenerate after editing `project.yml`:

```
cd Verso && xcodegen generate
```

Open `Verso/Verso.xcodeproj` in Xcode to build and run. No CLI build commands are configured yet.

## Architecture

### Tech Stack
- SwiftUI, iOS 16+, iCloud Drive
- Bundle ID: `com.fabiosasseron.verso`

### Core Design Decisions
- **File-first**: Articles saved as Markdown files to a user-selected iCloud Drive folder — no proprietary database
- **Core Data**: Used only as a local read cache rebuilt from files; never the source of truth
- **Single NavigationStack** (no tab bar)
- Article status lifecycle: `Unread → Reading → Read` (auto-tracked on scroll)
- Filter chips: All / Unread / Reading / Read
- MVP: title search only (no full-text body search)
- Share Extension: separate entry point for saving articles from other apps

### Source Layout (`Verso/Sources/`)
- `App/` — entry point (`VersoApp.swift`) and root view (`ContentView.swift`)
- `Design/` — design system: `Colors.swift` (4 themes × `ThemeColors`), `Typography.swift`, `Spacing.swift`, `Radius.swift`, `ThemeManager.swift`, `DesignSystemPreview.swift`

### Themes
Four reading themes defined in `VersoTheme` enum: **Paper**, **Sepia**, **Night**, **Ink**. Each has 9 semantic color roles: `background`, `surface`, `textPrimary`, `textSecondary`, `accent`, `accentPressed`, `accentSurface`, `border`, `placeholder`.

### Article Status Colors
Defined in `ArticleStatus` enum in `Colors.swift`: Unread (blue `4A90D9`), Reading (amber `D4A353`), Read (green `5AAF7A`).

## Figma Plugin

`docs/figma-plugin/` creates design tokens in Figma (12 color variables × 4 modes, 16 text styles, 8 spacing tokens, 4 radius tokens). Load via **Plugins → Development → Import plugin from manifest.json**, then Run.

## Docs

`docs/` contains design research, PRD, wireframes, and specs.

**Before starting any implementation task, read `docs/HANDOFF.md` first.** It is the authoritative entry point — a thin index with inline essentials and pointers to authoritative docs by topic, optimized for token efficiency.

Other key files:
- `PRD_MinimalistReaderApp.md` — full product requirements
- `DESIGN_SYSTEM_FOUNDATIONS.md` — typography, spacing, color system reference
- `FIGMA_DESIGN_SYSTEM_REFERENCE.md` — Figma token naming conventions
