# Design Tokens — Verso

**Version:** 1.1  
**Date:** 2026-05-02  
**Status:** Draft

This file is the authoritative token registry for Verso's design system. Every token listed here has a corresponding Swift identifier — names match exactly. When values or intent conflict with another doc, this file wins.

**Related:**
- Design rationale and reading behavior → `DESIGN_SYSTEM_FOUNDATIONS.md`
- Figma token naming conventions → `FIGMA_DESIGN_SYSTEM_REFERENCE.md`
- Component-level token usage and per-state color rules → `COMPONENT_SPECS.md`

---

## Naming contract

Token names here match Swift identifiers exactly. If a token is `textPrimary` in Swift, it is `textPrimary` in this file — not "Text Primary", not "primary-text". This is intentional: when in doubt, search this file for the exact identifier.

---

## 1. Color Tokens — Theme-Dependent

These tokens change with the active theme. All four themes share the same semantic roles; only the values differ.

---

### `background`

**Role:** The canvas. The lowest visual layer of every screen.  
**Use for:** Article reading view, list screen, settings screen, onboarding screens — any full-screen background fill.  
**Don't use for:** Cards, sheets, or surfaces that sit *on top of* the background. Use `surface` instead.  
**WCAG:** `textPrimary` on `background` must be ≥ 4.5:1. `textSecondary` on `background` must be ≥ 4.5:1. `accent` on `background` must be ≥ 4.5:1 (used as link text).

| Theme | Hex |
|-------|-----|
| Paper | `#F5F0E8` |
| Sepia | `#F2E8D5` |
| Night | `#1C1A16` |
| Ink   | `#111418` |

---

### `surface`

**Role:** The layer above the background. Used for elements that need to be visually distinct from the canvas without introducing hierarchy noise.  
**Use for:** Article list rows, top reading bar, bottom reading bar, cards, modal sheets, filter chip container strip.  
**Don't use for:** The full-screen background. Use `background` instead. Don't use for text or icons.  
**WCAG:** `textPrimary` on `surface` must be ≥ 4.5:1. Verify at each theme — the surface-to-background contrast is intentionally subtle, so surface alone is not accessible for text.

| Theme | Hex |
|-------|-----|
| Paper | `#EDE8DF` |
| Sepia | `#E8DEC7` |
| Night | `#252320` |
| Ink   | `#181C22` |

---

### `textPrimary`

**Role:** The primary reading and UI text color. Maximum emphasis.  
**Use for:** Article body text, article headings, article list titles, screen titles, button labels, any text that must be read without effort.  
**Don't use for:** Metadata, captions, timestamps, or any text that is supplementary to the main content. Use `textSecondary` instead.  
**WCAG:** Must achieve ≥ 4.5:1 on both `background` and `surface` in all four themes. This is verified — do not alter these values without re-checking contrast.

| Theme | Hex |
|-------|-----|
| Paper | `#2C2924` |
| Sepia | `#2E2013` |
| Night | `#E8E0D0` |
| Ink   | `#E4E6EB` |

---

### `textSecondary`

**Role:** Secondary text color. Reduced emphasis, supporting information.  
**Use for:** Article source name, save date, estimated reading time, section labels, captions, filter chip labels when not selected.  
**Don't use for:** Body copy, headings, or any text the user needs to read to understand primary content. Don't use for interactive elements like links or buttons.  
**WCAG:** Must achieve ≥ 4.5:1 on both `background` and `surface`. Note: these values have been revised from initial choices to pass this threshold — do not revert.

| Theme | Hex |
|-------|-----|
| Paper | `#6E675F` |
| Sepia | `#755E40` |
| Night | `#8F897F` |
| Ink   | `#7E8492` |

---

### `accent`

**Role:** The single interactive color of the system. Communicates "this responds to a tap."  
**Use for:** Article links, active filter chip background, reading progress indicator fill, any tappable element that needs a color signal.  
**Don't use for:** Decorative color, backgrounds, or anything that doesn't respond to user interaction. Do not use for status indicators — use the status tokens instead.  
**WCAG:** Must achieve ≥ 4.5:1 on `background` when used as text (links). Reading bar icon controls are icon-only — they use `accent` as a tint on `surface`, which must achieve ≥ 3:1.

| Theme | Hex |
|-------|-----|
| Paper | `#766655` |
| Sepia | `#825A37` |
| Night | `#C4A97D` |
| Ink   | `#7B9FD4` |

---

### `accentPressed`

**Role:** The pressed/active state of `accent`. Used for moment-of-interaction feedback.  
**Use for:** The exact same elements as `accent`, but only in their pressed or actively-held state. Should feel like the element sinking slightly — darker in light themes, lighter in dark themes.  
**Don't use for:** Default or resting state. Do not use in place of `accent` for static display.  
**WCAG:** Inherits the same requirements as `accent`. Derived at ~25% darker than `accent` per theme.

| Theme | Hex |
|-------|-----|
| Paper | `#584D40` |
| Sepia | `#614429` |
| Night | `#937F5E` |
| Ink   | `#5C779F` |

---

### `accentSurface`

**Role:** A 15%-opacity tint of the theme's `accent` color. Background fill for elements whose label or icon uses `accent`.  
**Use for:** `FilterChip` selected-state background, any chip, tag, or badge where the foreground uses `accent` and needs a background hint.  
**Don't use for:** Standalone backgrounds without accent-colored content, text color, or as a replacement for `accent` on interactive controls.  
**WCAG:** Not a text element. Always paired with `accent` foreground — the combination is the accessible unit.

| Theme | Value |
|-------|-------|
| Paper | `#766655` @ 15% opacity |
| Sepia | `#825A37` @ 15% opacity |
| Night | `#C4A97D` @ 15% opacity |
| Ink   | `#7B9FD4` @ 15% opacity |

---

### `border`

**Role:** Structural lines and dividers. Defines edges without drawing attention.  
**Use for:** List row separators, card borders, reading bar edge lines, input field outlines, modal sheet borders.  
**Don't use for:** Text, icons, or any element that needs to communicate meaning. Borders are structural, not semantic.  
**WCAG:** Not a text element — no contrast requirement. Should be barely perceptible against both `background` and `surface`.

| Theme | Hex |
|-------|-----|
| Paper | `#DDD8CE` |
| Sepia | `#D9CAAC` |
| Night | `#2E2B26` |
| Ink   | `#1E2228` |

---

### `placeholder`

**Role:** Fill for image placeholders and skeleton loading states.  
**Use for:** Article thumbnail placeholder before image loads, skeleton shimmer base color, empty state illustrations that should blend into the background.  
**Don't use for:** Permanent UI elements. This token signals "something is loading or missing" — using it for static UI would create false loading signals.  
**WCAG:** Not a text element — no contrast requirement.

| Theme | Hex |
|-------|-----|
| Paper | `#CEC8BC` |
| Sepia | `#C8BCA0` |
| Night | `#302E2A` |
| Ink   | `#202630` |

---

## 2. Color Tokens — Semantic (Theme-Dependent)

These tokens communicate state and outcome. Because themes vary widely in luminance, each theme defines its own values — light themes use dark saturated tones; dark themes use light desaturated tones.

**Usage constraint for all semantic tokens:** Used as text tints and border colors only. Never as large fill backgrounds.

---

### `error`

**Role:** Validation failures, destructive actions, unrecoverable states.  
**Use for:** Text field validation error message, destructive action confirmation, error toast.  
**Don't use for:** Warnings, cautions, or any state that isn't clearly a failure.  
**WCAG:** ≥ 4.5:1 on both `background` and `surface` per theme.

| Theme | Hex |
|-------|-----|
| Paper | `#C0392B` |
| Sepia | `#C0392B` |
| Night | `#F87171` |
| Ink   | `#FC8181` |

---

### `warning`

**Role:** Cautions and non-critical notices that require user awareness but not immediate action.  
**Use for:** Inline notices, caution badges, sync delay warnings.  
**Don't use for:** Actionable states or errors. If the user needs to do something, use `error`.  
**WCAG:** ≥ 4.5:1 on both `background` and `surface` per theme.

| Theme | Hex |
|-------|-----|
| Paper | `#B45309` |
| Sepia | `#B45309` |
| Night | `#FCD34D` |
| Ink   | `#F6E05E` |

---

### `success`

**Role:** Confirmations and completed actions.  
**Use for:** Save confirmation toast, article marked-as-read state indicator, successful sync.  
**Don't use for:** Progress in motion — only the completed state.  
**WCAG:** ≥ 4.5:1 on both `background` and `surface` per theme.

| Theme | Hex |
|-------|-----|
| Paper | `#166534` |
| Sepia | `#166534` |
| Night | `#4ADE80` |
| Ink   | `#68D391` |

---

## 3. Color Tokens — Article Status (Theme-Independent)

These tokens are fixed across all themes. They represent a meaningful lifecycle state, not a visual preference, so they don't change with the reading theme.

**Usage constraint:** Always used as a small indicator (dot, badge, chip accent) alongside text — never as a large background fill or as the sole means of communicating status (pair with a label for accessibility).

---

### `statusUnread`

**Role:** The article has been saved and not yet opened.  
**Use for:** Status dot in article list row, "Unread" filter chip active indicator.  
**WCAG:** Must achieve ≥ 3:1 against all four theme backgrounds when used as a dot. Verify especially on Paper and Sepia.

| State | Hex |
|-------|-----|
| Unread | `#4A90D9` |

---

### `statusReading`

**Role:** The article has been opened and is in progress.  
**Use for:** Status dot in article list row, "Reading" filter chip active indicator, reading progress bar fill.

| State | Hex |
|-------|-----|
| Reading | `#D4A353` |

---

### `statusRead`

**Role:** The article has been fully read.  
**Use for:** Status dot in article list row, "Read" filter chip active indicator.

| State | Hex |
|-------|-----|
| Read | `#5AAF7A` |

---

## 4. Spacing Tokens

Base unit: 8pt. All values are multiples of 4 (with `xxs` as the minimum). Spacing scales proportionally with Dynamic Type — use `@ScaledMetric` in SwiftUI.

| Token | Value | Use for |
|-------|-------|---------|
| `spacing.xxs` | 4pt | Inline gaps between tightly coupled elements (e.g., icon + label) |
| `spacing.xs` | 8pt | Gap between filter chips, tight internal padding |
| `spacing.sm` | 12pt | Filter chip interior horizontal padding |
| `spacing.md` | 16pt | Standard content padding, screen horizontal margins |
| `spacing.lg` | 24pt | Section spacing, gap between list rows |
| `spacing.xl` | 32pt | Major section divisions |
| `spacing.2xl` | 48pt | Screen-level vertical rhythm |
| `spacing.3xl` | 64pt | Extra breathing room, large screen compensation |

---

## 5. Corner Radius Tokens

All components use named radius tokens. Ad-hoc values are not permitted.

| Token | Value | Use for |
|-------|-------|---------|
| `radius.sm` | 10pt | Inputs, search bars |
| `radius.md` | 12pt | Cards, buttons, sheets, modals |
| `radius.lg` | 18pt | Chips (fully rounded at standard chip height) |
| `radius.pill` | 20pt | Pill-shaped elements; safe fallback when component height is uncertain |

---

## 6. Typography Tokens

Typography tokens follow a two-namespace structure: `type.reading.*` for inside the reading view (uses user's chosen font), and `type.ui.*` for all other screens (always San Francisco).

### Reading Typography — `type.reading.*`

Font family: user-selected (New York default, Georgia, San Francisco, OpenDyslexic). Size is user-selected from the scale below. The default is `md`.

| Token | Size | Weight | Line Height | Use for |
|-------|------|--------|-------------|---------|
| `type.reading.h1` | 28pt | Bold (700) | 1.2× | Article title |
| `type.reading.h2` | 24pt | Semibold (600) | 1.25× | Section headings |
| `type.reading.h3` | 20pt | Semibold (600) | 1.3× | Subsection headings |
| `type.reading.h4` | 18pt | Semibold (600) | 1.35× | Minor headings |
| `type.reading.body.xs` | 14pt | Regular (400) | 1.75× | Body text at XS size setting |
| `type.reading.body.sm` | 16pt | Regular (400) | 1.75× | Body text at S size setting |
| `type.reading.body.md` | 18pt | Regular (400) | 1.75× | Body text at M (default) |
| `type.reading.body.lg` | 20pt | Regular (400) | 1.75× | Body text at L size setting |
| `type.reading.body.xl` | 22pt | Regular (400) | 1.6× | Body text at XL size setting |
| `type.reading.body.xxl` | 26pt | Regular (400) | 1.5× | Body text at XXL size setting |

**Why Regular only for body:** Bold/Semibold weights reduce legibility at reading sizes and add visual weight inappropriate for long-form content. Headings are the only exception.

### UI Typography — `type.ui.*`

Font family: San Francisco (system), always — regardless of user's reading font preference.

| Token | Size | Weight | Line Height | Use for |
|-------|------|--------|-------------|---------|
| `type.ui.screenTitle` | 34pt | Bold | 1.2× | Library screen title, settings title |
| `type.ui.listTitle` | 17pt | Semibold | 1.3× | Article list row title |
| `type.ui.listSubtitle` | 15pt | Regular | 1.4× | Article list row metadata (source, date, read time) |
| `type.ui.button` | 17pt | Semibold | 1.0× | Buttons and tappable labels |
| `type.ui.caption` | 13pt | Regular | 1.3× | Timestamps, section labels |
| `type.ui.input` | 17pt | Regular | 1.0× | Text field input text |

---

## 7. Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.1 | 2026-05-02 | Added `accentSurface` token (15%-opacity accent tint, for chip/chip-like selected-state backgrounds). Added to Swift `ThemeColors` struct. |
| 1.0 | 2026-04-22 | Initial token registry. Consolidates color tokens from DESIGN_SYSTEM_FOUNDATIONS.md §2, spacing from §7, radius from §8, and typography from §3. Values authoritative from DESIGN_SYSTEM_FOUNDATIONS.md v1.6. |
