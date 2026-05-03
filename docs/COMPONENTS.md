# Components — Verso

**Version:** 1.0  
**Date:** 2026-04-22  
**Status:** Draft

This file maps design tokens to UI components. For each component it answers one question: *which token goes on which element, and how does that change across states?*

This file is not a full behavioral spec. For sizes, animations, copy, and interaction details, see `component-inventory.md`. For token values and usage intent, see `DESIGN_TOKENS.md`.

**Naming contract:** Swift view names here match the identifiers used in the codebase. When a token name appears, it matches `DESIGN_TOKENS.md` exactly.

---

## 1. Article List Screen

---

### `ArticleCard`

The primary list item. Displays one saved article.

| Element | Token | Style |
|---------|-------|-------|
| Container background | `surface` | |
| Container border | `border` | 1pt |
| Article title | `textPrimary` | `type.ui.listTitle` |
| Source name | `textSecondary` | `type.ui.listSubtitle` |
| Save date / read time | `textSecondary` | `type.ui.caption` |
| Thumbnail placeholder | `placeholder` | Shown while image loads or when no image |

**State variations:**

| State | Element | Token |
|-------|---------|-------|
| Default — Unread | Status indicator | `statusUnread` |
| Default — Reading | Status indicator | `statusReading` |
| Default — Read | Status indicator | `statusRead` |
| Pressed | Container background | `surface` at 80% opacity |
| Loading (skeleton) | Title, source, date blocks | `placeholder` (shimmer base) |

---

### `FilterChip`

A single chip inside the `FilterChipBar`. One chip is always selected.

| Element | Token | Style |
|---------|-------|-------|
| Label | `textSecondary` (unselected) / `accent` (selected) | `type.ui.listSubtitle` Semibold |
| Background | Transparent (unselected) / `accent` at 15% opacity (selected) | |
| Border | `border` (unselected) / none (selected) | 1pt |

**State variations:**

| State | Element | Token |
|-------|---------|-------|
| Unselected | Label | `textSecondary` |
| Unselected | Background | Transparent |
| Selected | Label | `accent` |
| Selected | Background | `accent` at 15% opacity |
| Zero count | Entire chip | 50% opacity applied — all tokens retain their state values |
| Pressed | Background | `accent` at 25% opacity |

**Note on zero-count state:** the chip remains visible and tappable regardless of count. Dimming signals "nothing here" without hiding the filter. See `DESIGN_TOKENS.md → filter chips` and the filter chips empty state decision in Linear.

---

### `SearchBar`

Title search input at the top of the article list.

| Element | Token | Style |
|---------|-------|-------|
| Container background | `surface` | |
| Container border | `border` | 1pt |
| Placeholder text | `textSecondary` | `type.ui.input` |
| Input text | `textPrimary` | `type.ui.input` |
| Search icon | `textSecondary` | |
| Clear button | `textSecondary` | Appears when field has text |

**State variations:**

| State | Element | Token |
|-------|---------|-------|
| Focused | Container border | `accent` |
| Has text | Clear icon | `textSecondary` |

---

### `EmptyState`

Shown when a filter or search yields no results.

| Element | Token | Style |
|---------|-------|-------|
| Icon | `textSecondary` | 48pt SF Symbol |
| Headline | `textPrimary` | `type.ui.listTitle` |
| Subheadline | `textSecondary` | `type.ui.listSubtitle` |
| Screen background | `background` | |

---

## 2. Reading View

---

### `ReadingChrome`

Top and bottom bars that appear on tap during reading.

| Element | Token | Style |
|---------|-------|-------|
| Bar background | `surface` at 95% opacity | Both top and bottom bar |
| Bar border | `border` | Bottom edge of top bar; top edge of bottom bar |
| Back button icon | `accent` | `IconButton` |
| Article title (truncated) | `textSecondary` | `type.ui.caption` |
| Remaining read time | `textSecondary` | `type.ui.caption` |

**State variations:**

| State | Element | Token |
|-------|---------|-------|
| Visible | Bar background | `surface` at 95% opacity |
| Hidden | — | Opacity 0; tokens unchanged |

**Note:** `ReadingChrome` does not define icon tokens directly — those belong to the `IconButton` component it contains. See `IconButton` below.

---

### `IconButton`

Icon-only button used throughout `ReadingChrome` and the article list navigation bar.

| Element | Token | Style |
|---------|-------|-------|
| Icon (default) | `textSecondary` | 24pt SF Symbol |
| Icon (active/selected) | `accent` | 24pt SF Symbol |
| Touch target | — | 44×44pt minimum |
| Background | Transparent | |

**State variations:**

| State | Element | Token |
|-------|---------|-------|
| Default | Icon | `textSecondary` |
| Active / selected | Icon | `accent` |
| Pressed | Icon | `accent` at 60% opacity |
| Disabled | Icon | `textSecondary` at 30% opacity |

---

### `ScrollProgress`

Thin progress bar pinned to the top of the reading view, below `ReadingChrome`.

| Element | Token | Style |
|---------|-------|-------|
| Track (background) | `border` | 3pt height, full width |
| Fill | `accent` | Grows left to right with scroll position |

---

### `ArticleHeader`

Title and metadata block at the top of the article.

| Element | Token | Style |
|---------|-------|-------|
| Article title | `textPrimary` | `type.reading.h1` |
| Source name | `textSecondary` | `type.ui.listSubtitle` |
| Publish date | `textSecondary` | `type.ui.caption` |
| Screen background | `background` | |

---

### `MarkdownBody`

The rendered article content. Font family and size are user-controlled; tokens apply to all variants.

| Element | Token | Style |
|---------|-------|-------|
| Screen background | `background` | |
| Body text | `textPrimary` | `type.reading.body.*` (user's size setting) |
| H1 | `textPrimary` | `type.reading.h1` |
| H2 | `textPrimary` | `type.reading.h2` |
| H3 | `textPrimary` | `type.reading.h3` |
| H4 | `textPrimary` | `type.reading.h4` |
| Links | `accent` | Underlined |
| Blockquote border | `accent` | Left border, 3pt |
| Blockquote text | `textSecondary` | Same size as body |
| Code block background | `surface` | |
| Code block text | `textPrimary` | SF Mono, `type.ui.caption` size |
| Horizontal rule | `border` | 1pt |

**State variations:**

| State | Element | Token |
|-------|---------|-------|
| Link pressed | Link text | `accentPressed` |

---

### `ImmersiveHintPill`

One-time hint shown when the reading chrome first auto-hides.

| Element | Token | Notes |
|---------|-------|-------|
| Background | Fixed `rgba(0,0,0,0.70)` | Not theme-aware — must be legible on all four themes |
| Text | Fixed white | Not a design token |

**Why not theme tokens:** this pill must be legible across all four themes simultaneously (it appears during a theme the user has already selected). A fixed dark semi-transparent background with white text is the only combination that works reliably on both light and dark themes without runtime branching.

---

### `ReadingControls`

Popover sheet for font, spacing, margin, and theme adjustments.

| Element | Token | Style |
|---------|-------|-------|
| Sheet background | `surface` | |
| Sheet border | `border` | 1pt, top edge |
| Section labels | `textSecondary` | `type.ui.caption` |
| Control labels | `textPrimary` | `type.ui.listSubtitle` |
| Active segment / selected value | `accent` | |
| Inactive segment | `textSecondary` | |

---

## 3. Common Components

---

### `PrimaryButton`

Filled button. Main call-to-action.

| Element | Token | Style |
|---------|-------|-------|
| Background | `accent` | |
| Label | Fixed white | Not theme-aware — white on `accent` is verified AA on all themes |
| Border | None | |

**State variations:**

| State | Element | Token |
|-------|---------|-------|
| Default | Background | `accent` |
| Pressed | Background | `accentPressed` |
| Disabled | Background | `accent` at 40% opacity |
| Loading | Background | `accent` at 50% opacity + spinner |

---

### `SecondaryButton`

Outlined button. Secondary action.

| Element | Token | Style |
|---------|-------|-------|
| Background | Transparent | |
| Border | `accent` | 1.5pt |
| Label | `accent` | `type.ui.button` |
| Corner radius | `radius/md` | 12pt |

**State variations:**

| State | Element | Token |
|-------|---------|-------|
| Pressed | Background | `accent` at 15% opacity |
| Pressed | Border | `accentPressed` |
| Pressed | Label | `accentPressed` |
| Disabled | Border | `accent` at 40% opacity |
| Disabled | Label | `accent` at 40% opacity |

---

### `TextButton`

Label-only button. Tertiary or dismissal action.

| Element | Token | Style |
|---------|-------|-------|
| Label | `accent` | `type.ui.button` |

**State variations:**

| State | Element | Token |
|-------|---------|-------|
| Pressed | Label | `accent` at 60% opacity |

---

### `StatusBadge`

Small visual indicator of article status. Always paired with a text label for accessibility — never used as the sole means of communication.

| Element | Token | Variant |
|---------|-------|---------|
| Dot (Unread) | `statusUnread` | 12pt circle |
| Badge background (Reading) | `statusReading` | |
| Badge background (Read) | `statusRead` | |
| Badge label | Fixed white | "Reading" / "Read" — not theme-aware |

---

### `TextField`

Text input used in settings and forms.

| Element | Token | Style |
|---------|-------|-------|
| Background | `surface` | |
| Border | `border` | 1pt |
| Input text | `textPrimary` | `type.ui.input` |
| Placeholder text | `textSecondary` | `type.ui.input` |

**State variations:**

| State | Element | Token |
|-------|---------|-------|
| Focused | Border | `accent` |
| Error | Border | `error` |
| Error | Message text below field | `error` |

---

## 4. Share Extension

---

### `ShareSheet`

Modal sheet presented when saving from another app.

| Element | Token | Style |
|---------|-------|-------|
| Sheet background | `surface` | |
| Sheet border | `border` | Top edge, 1pt |

---

### `ArticlePreview`

Preview of the article being saved, inside the share sheet.

| Element | Token | Style |
|---------|-------|-------|
| Title | `textPrimary` | `type.ui.listTitle` |
| URL / domain | `textSecondary` | `type.ui.caption` |
| Thumbnail placeholder | `placeholder` | |

**State variations:**

| State | Element | Token |
|-------|---------|-------|
| Loading | Title, URL blocks | `placeholder` (shimmer) |
| Error | Message text | `error` |

---

### `SaveButton`

Uses `PrimaryButton`. Refer to `PrimaryButton` token map above.

**Additional state:**

| State | Element | Token |
|-------|---------|-------|
| Success | Background | `success` |
| Error | Background | `error` |

---

## 5. Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.1 | 2026-05-01 | Added corner radius (`radius/md`, 12pt) to `SecondaryButton` spec. |
| 1.0 | 2026-04-22 | Initial token-to-component mapping. Covers all components from component-inventory.md v1.2. |
