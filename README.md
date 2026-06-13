# Verso — Minimalist Article Reader App

## Project Overview
Verso is a minimalist article reader app focused on providing a beautiful, book-like reading experience. It now spans two platforms — **iOS** (SwiftUI) and **Web** (Next.js) — both in active implementation. For the authoritative, up-to-date status of each platform, see `docs/PROJECT_STATUS.md`.

## Key Documentation
- **Developer Handoff**: `docs/HANDOFF.md` (start here)
- **Design System Foundations**: `docs/DESIGN_SYSTEM_FOUNDATIONS.md`
- **Authoritative Design Tokens**: `docs/DESIGN_TOKENS.md`
- **Figma Design System Reference**: `docs/FIGMA_DESIGN_SYSTEM_REFERENCE.md`
- **Product Requirements**: `docs/PRD_MinimalistReaderApp.md`
- **Issue Tracker**: `docs/BACKLOG.md` (Linear retired 2026-06-12)

## Figma Design System
- **File**: https://www.figma.com/design/WCPHZNg1my8VSSMbLO5bvX/Reader-UI
- **Components Page**: https://www.figma.com/design/WCPHZNg1my8VSSMbLO5bvX/Reader-UI?node-id=13-201
- **Key Features**:
  - Multi-mode color variables (`Verso/Colors` with paper/sepia/night/ink modes)
  - Typography tokens (`type.reading.*` and `type.ui.*` namespaces)
  - Spacing and corner radius token collections
  - Comprehensive component library (buttons, inputs, cards, navigation bars, reading-specific controls)

## Tech Stack (from PRD)
- **Language**: SwiftUI
- **Minimum iOS Version**: 16+
- **State Management**: File-first (Markdown files in iCloud Drive) + Core Data read cache
- **Bundle ID**: `com.fabiosasseron.verso`
- **Features**: Share extension for saving articles from other apps

## Running Commands

The Xcode project is generated via XcodeGen. Regenerate after editing `project.yml`: `cd Verso && ./generate-xcodeproj.sh` (creates local `Secrets.xcconfig` from the template if needed — see `Verso/Secrets.xcconfig.template`). Open `Verso/Verso.xcodeproj` in Xcode to build and run.