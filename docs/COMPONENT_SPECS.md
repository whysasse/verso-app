# Component Specs — Verso

**Version:** 1.1
**Date:** 2026-08-29
**Status:** Draft
**Related:** FAB-87, FAB-292

This document is the developer-handoff view of Verso's UI components. For each component it provides anatomy, exact dimensions, typography, and color rules (tokens per element, per state) in a single place.

**Source docs (authoritative):**
- Token names, values, and usage intent → `DESIGN_TOKENS.md`
- Behavioral specs, interaction, copy → `component-inventory.md`

> **Note:** This document consolidates component specs from `COMPONENTS.md` (v1.1, archived) and `component-inventory.md` v1.4. Token-to-element mapping and per-state color rules are defined here.

**Token naming:** all token names match `DESIGN_TOKENS.md` exactly. For resolved hex values per theme, refer to that file.

---

## 1. Article List Screen

---

### NavigationBar

Large-title navigation bar at the top of the article list. Collapses to compact (inline) on scroll.

**Anatomy**
- Large title label ("Verso")
- Settings icon button (trailing)

**Dimensions**

| Property | Value |
|----------|-------|
| Style | iOS large title (system-managed height) |
| Font size | 34pt (collapsed: system compact) |
| Safe area | Respects top safe area |
| Trailing padding | System default + 4pt |

**Typography**

| Element | Font | Weight | Size |
|---------|------|--------|------|
| Title (expanded) | SF Pro | Bold | 34pt |
| Title (collapsed) | SF Pro | Semibold | 17pt (system) |

**Color rules**

| Element | Token | Notes |
|---------|-------|-------|
| Background | `background` | System `NavigationView` background |
| Title | `textPrimary` | |
| Settings icon | `textSecondary` (idle) / `accent` (active) | `IconButton` rules apply |

---

### SearchBar

Title search input below the navigation bar.

**Anatomy**
- Search icon (leading)
- Placeholder / input text
- Clear button (trailing, visible when field has text)
- Container

**Dimensions**

| Property | Value |
|----------|-------|
| Height | 44pt |
| Corner radius | 10pt (`radius/sm`) |
| Horizontal padding (internal) | md — 16pt |
| Vertical padding (internal) | xs — 8pt |
| Icon size | 17pt SF Symbol `magnifyingglass` |

**Typography**

| Element | Font | Weight | Size |
|---------|------|--------|------|
| Placeholder text | SF Pro | Regular | 17pt |
| Input text | SF Pro | Regular | 17pt |

**Color rules**

| Element | Token | State |
|---------|-------|-------|
| Container background | `surface` | All |
| Container border | `border` 1pt | Default |
| Container border | `accent` 1pt | Focused |
| Placeholder text | `textSecondary` | Empty |
| Input text | `textPrimary` | Has text |
| Search icon | `textSecondary` | All |
| Clear icon | `textSecondary` | Has text |

---

### Article List Header Row (FAB-292)

Replaced the previous stacked search bar / tag-filter button / date-range row / `FilterChipBar` (all four removed) with a single row shared with the "Verso" title.

**Anatomy**
- Title ("Verso", `screenTitle` — 34pt bold), leading
- Four plain icon buttons, trailing, tight 2pt gaps: search (magnifying glass), filter (funnel — opens `FilterPanel`, covering both tags and date range), Add (a filled accent circle with a plus glyph), overflow ("•••", opens a menu with Select and Settings)
- Tapping the search icon replaces this whole row with a full-width `SearchBar` + a "Cancel" button (existing `SearchBar` component, unchanged dimensions)
- While bulk-select mode is active, this row becomes a leading "Cancel" button with the title still trailing

**Dimensions**

| Property | Value |
|----------|-------|
| Icon touch target | 44×44pt (each) |
| Gap between icons | 2pt |
| Add button visual circle | 32pt diameter, centered in its 44×44 target |
| Filter icon active-count badge | 16pt min-diameter capsule, `accent` fill, white text |

**Color rules**

| Element | Token | State |
|---------|-------|-------|
| Icons | `accent` | Always (plain, no background chip) |
| Add button circle | `accent` fill, white glyph | Always |
| Filter icon | `line.3.horizontal.decrease.circle` vs `.fill` variant | Filled when tags and/or a non-default date range are active |

---

### Article List Sections (FAB-292)

Replaced the status `FilterChipBar` (all-time filter by tap) with always-visible, collapsible `List` sections, grouped from the same fetch rather than gated by a single active filter.

**Anatomy**
- **Continue Reading** — status `.reading` articles, pinned first; each card shows `ScrollProgress` + a "N% read" caption instead of the date line (see `ArticleCard`'s `showsProgress` mode below)
- **Unread** — status `.unread`
- **Read** — status `.read`, collapsed by default (chevron toggle, "Collapsed — tap to expand" caption shown while collapsed)
- **Archived** — status `.archived`, collapsed by default, same treatment as Read
- Any section with zero matching articles is omitted entirely, not shown empty

**Dimensions**

| Property | Value |
|----------|-------|
| Section header height | ≥36pt (touch target for the collapsible ones) |
| Section header top padding | md — 16pt |
| Section header bottom padding | xs — 8pt |

**Typography**

| Element | Font | Weight | Size |
|---------|------|--------|------|
| Section header label | `listTitle` | Semibold | 17pt |
| Collapsed caption | `caption` | Regular | 13pt |

---

### ArticleCard

Primary list item. Displays one saved article.

**Anatomy**
- Container (rounded rect, `surface` background)
- Status badge (top-right)
- Article title
- Source name
- Date / read time

**Dimensions**

| Property | Value |
|----------|-------|
| Padding (all sides) | md — 16pt |
| Corner radius | 12pt (`radius/md`) |
| Margin between cards | sm — 12pt |
| Status badge — unread dot | 12pt diameter circle |
| Status badge — reading/read | 8pt height, ≥16pt width |

**Typography**

| Element | Font | Weight | Size | Line height |
|---------|------|--------|------|-------------|
| Title | SF Pro | Semibold | 17pt | 1.3× |
| Source name | SF Pro | Regular | 15pt | 1.4× |
| Date / read time | SF Pro | Regular | 13pt | — |

**Progress mode (FAB-292)** — `showsProgress: Bool` param, used by the article list's Continue Reading section: replaces the date line with a `ScrollProgress` bar (4pt tall, `xxs` — 4pt top padding) plus a "N% read" caption in the same `caption` style. Percentage is `Article.scrollPosition` (already persisted by `ArticleReaderView`), not a new field.

**Color rules**

| Element | Token | State |
|---------|-------|-------|
| Container background | `surface` | Default |
| Container background | `surface` at 80% opacity | Pressed |
| Container border | `border` 1pt | All |
| Title | `textPrimary` | All |
| Source name | `textSecondary` | All |
| Date / read time | `textSecondary` | All |
| Thumbnail placeholder | `placeholder` | Loading / no image |
| Status badge | `statusUnread` | Unread |
| Status badge | `statusReading` | Reading |
| Status badge | `statusRead` | Read |
| Title, source, date blocks | `placeholder` (shimmer base) | Skeleton loading |

---

### EmptyState

Shown when a filter or search yields no results.

**Anatomy**
- Icon (SF Symbol, centered)
- Headline
- Subheadline

**Dimensions**

| Property | Value |
|----------|-------|
| Vertical spacing between elements | 2xl — 48pt |
| Horizontal padding | md — 16pt |
| Icon size | 48pt SF Symbol `doc.text.magnifyingglass` |

**Typography**

| Element | Font | Weight | Size |
|---------|------|--------|------|
| Headline | SF Pro | Semibold | 20pt |
| Subheadline | SF Pro | Regular | 15pt |

**Color rules**

| Element | Token |
|---------|-------|
| Screen background | `background` |
| Icon | `textSecondary` |
| Headline | `textPrimary` |
| Subheadline | `textSecondary` |

**Variants:** "No articles yet" (no articles) / "No articles match your search" (search/filter miss)

---

### LoadingState

Skeleton shimmer shown while articles are loading. Renders 5 `ArticleCard`-shaped skeletons.

**Anatomy**
- 5 skeleton cards at standard `ArticleCard` spacing
- Each card: 3 shimmer blocks (title, source, date)

**Dimensions**

| Block | Approx. width | Height |
|-------|--------------|--------|
| Title block | 75% of card width | 17pt |
| Source line | 40% of card width | 13pt |
| Date line | 25% of card width | 13pt |

Corner radius: 12pt (matches live card). Status badge area omitted in skeleton state.

**Color rules**

| Element | Token |
|---------|-------|
| Skeleton block fill | `placeholder` |
| Shimmer highlight | `textSecondary` at 30% opacity |
| Card background | `surface` |

Animation: shimmer moves left to right, 1.5s duration.

---

## 2. Article Detail Screen

---

### ReadingChrome

Top and bottom bars that show and hide during reading.

**Anatomy — Top bar**
- Back button (`chevron.left`, leading)
- Article title (truncated, center)
- Open-externally button (`arrow.up.right`, trailing)

**Anatomy — Bottom bar**
- Font size controls (`minus` / `plus`)
- Line spacing icon (`text.alignleft`)
- Margin icon (`arrow.left.and.right.righttriangle`)
- Theme icon (`circle.lefthalf.filled`)
- Mark-as-read icon (`checkmark.circle`)

All bottom-bar icons use the `IconButton` component (see §5).

**Dimensions**

| Property | Value |
|----------|-------|
| Top bar height | 44pt + top safe area |
| Bottom bar height | 44pt + bottom safe area |
| Icon size | 24pt SF Symbol |

**Typography**

| Element | Font | Weight | Size |
|---------|------|--------|------|
| Article title (truncated) | SF Pro | Regular | 15pt |

**Color rules**

| Element | Token | State |
|---------|-------|-------|
| Bar background | `surface` at 95% opacity | Visible |
| Bar border | `border` 1pt | Bottom of top bar; top of bottom bar |
| Article title | `textSecondary` | All |
| Icons | See `IconButton` | — |

**States:** Visible (opacity 1.0) → Hidden (opacity 0.0). Transition: hide 300ms ease-out, reveal 200ms ease-in. Auto-hide after 2s of no interaction.

---

### ScrollProgress

Thin progress bar showing read position, pinned below `ReadingChrome`.

**Anatomy**
- Track (full width)
- Fill (grows left to right)

**Dimensions**

| Property | Value |
|----------|-------|
| Height | 3pt |
| Width | Full screen width |
| Position | Top of screen, below top ReadingChrome bar |

**Color rules**

| Element | Token |
|---------|-------|
| Track (background) | `border` |
| Fill | `accent` |

---

### ArticleHeader

Title and metadata block at the top of the article body.

**Anatomy**
- Article title (H1)
- Source name
- Publish date

**Dimensions**

| Property | Value |
|----------|-------|
| Vertical spacing between elements | lg — 24pt |
| Horizontal padding | User's selected margin setting |

**Typography**

| Element | Font | Weight | Size | Line height |
|---------|------|--------|------|-------------|
| Title | User-selected reading font | Bold | 28pt (`type.reading.h1`) | 1.2× |
| Source name | SF Pro | Regular | 15pt | — |
| Publish date | SF Pro | Regular | 13pt | — |

**Color rules**

| Element | Token |
|---------|-------|
| Screen background | `background` |
| Article title | `textPrimary` |
| Source name | `textSecondary` |
| Publish date | `textSecondary` |

---

### MarkdownBody

Rendered article content. Font family and size are user-controlled.

**Anatomy**
- Paragraphs, headings (H1–H4), bold/italic
- Links (underlined)
- Blockquotes (left border)
- Code blocks (surface background, monospace)
- Ordered and unordered lists
- Images (full-width, aspect fit)
- Horizontal rules

**Dimensions**

| Property | Value |
|----------|-------|
| Horizontal padding | User's selected margin |
| Max width (iPad) | 680pt |
| Blockquote left border | 3pt |
| Code block corner radius | `radius/sm` — 10pt |

**Typography**

| Element | Font | Size | Line height |
|---------|------|------|-------------|
| Body text | User-selected | User-selected (XS 14pt → XXL 26pt) | 1.5×–1.75× (scales with size) |
| H1 | User-selected | 28pt | 1.2× |
| H2 | User-selected | 24pt | 1.25× |
| H3 | User-selected | 21pt | 1.3× |
| H4 | User-selected | 18pt | 1.35× |
| Code block text | SF Mono | 13pt (`type.ui.caption` size) | — |

**Color rules**

| Element | Token | State |
|---------|-------|-------|
| Screen background | `background` | All |
| Body text | `textPrimary` | All |
| H1–H4 | `textPrimary` | All |
| Links | `accent` underlined | Default |
| Links | `accentPressed` | Pressed |
| Blockquote border | `accent` | All |
| Blockquote text | `textSecondary` | All |
| Code block background | `surface` | All |
| Code block text | `textPrimary` | All |
| Horizontal rule | `border` 1pt | All |

---

### ImmersiveHintPill

One-time contextual hint shown the first time `ReadingChrome` auto-hides.

**Anatomy**
- Pill-shaped container
- Text label ("Tap anywhere to reveal")

**Dimensions**

| Property | Value |
|----------|-------|
| Corner radius | 20pt (fully rounded, `radius/pill`) |
| Vertical padding | 6pt |
| Horizontal padding | 14pt |
| Position | Horizontally centered; ~100pt above bottom safe area |

**Typography**

| Element | Font | Weight | Size |
|---------|------|--------|------|
| Hint text | SF Pro | Regular | 13pt |

**Color rules**

| Element | Value | Notes |
|---------|-------|-------|
| Background | `rgba(0, 0, 0, 0.70)` fixed | Not theme-aware — must be legible on all 4 themes |
| Text | White fixed | Not a design token |

Animation in: fade in 200ms ease-in. Animation out: fade out on tap 200ms ease-out.

---

### ReadingControls

Bottom sheet for font, spacing, margin, and theme adjustments. Two variants.

**Anatomy (shared)**
- Sheet container with drag handle
- Section dividers between control groups

**Anatomy — Font variant**
- Font size stepper (A− / value / A+)
- Line spacing segmented control

**Anatomy — Theme variant**
- 4 theme swatch tiles in a row

**Dimensions**

| Property | Value |
|----------|-------|
| Corner radius (top corners) | 16pt |
| Drag handle | 36×4pt pill |
| Horizontal padding | 20pt |
| Top padding | 16pt |
| Bottom padding | 28pt |
| Theme swatch height | 32pt |
| Theme swatch corner radius | 8pt |
| Theme label font size | 11pt |
| Active theme border | 2pt `accent` |
| Inactive theme border | 1pt `border` |

**Typography**

| Element | Font | Weight | Size |
|---------|------|--------|------|
| Section labels | SF Pro | Regular | 13pt |
| Control labels | SF Pro | Regular | 15pt |

**Color rules**

| Element | Token |
|---------|-------|
| Sheet background | `surface` |
| Sheet top border | `border` 1pt |
| Drag handle | `border` |
| Section labels | `textSecondary` |
| Control labels | `textPrimary` |
| Active segment / selected value | `accent` |
| Inactive segment | `textSecondary` |

---

## 3. Settings Screen

---

### ThemeSelector

Four `ThemeChip` components in a horizontal row under a "Theme" section label.

**Anatomy**
- Section label ("Theme")
- 4 `ThemeChip` tiles: Paper · Sepia · Night · Ink

**Dimensions**

| Property | Value |
|----------|-------|
| Chip width | 80pt |
| Chip height | 100pt |
| Chip gap | ~12.7pt (4 chips evenly distributed in a 358pt container) |
| Swatch height (inside chip) | 32pt |
| Swatch corner radius | 8pt |
| Label font size | 11pt |

**Color rules**

| Chip | Swatch color | Border |
|------|-------------|--------|
| Paper (selected) | `#F5F0E8` | 2pt `accent` |
| Sepia | `#F2E8D5` | 1pt `border` |
| Night | `#1C1A16` | 1pt `border` |
| Ink | `#111418` | 1pt `border` |

---

### FontFamilySelector

Selectable list of reading font options under a "Typography" section label.

**Anatomy**
- Section label ("Typography")
- 4 `Settings/Type` rows: New York · Georgia · SF Pro · OpenDyslexic

**Dimensions**

| Property | Value |
|----------|-------|
| Row height | ~78–79pt |

**Per-row typography**

| Element | Font | Weight | Size |
|---------|------|--------|------|
| Font name | Row's own family | Semibold | 17pt |
| Preview text | Row's own family | Regular | 15pt |

Preview text content: "The quick brown fox jumps over the laz…"

**Color rules**

| Element | Token | State |
|---------|-------|-------|
| Font name | `textPrimary` | All |
| Preview text | `textSecondary` | All |
| Selection indicator dot | `accent` | Selected |

---

### FolderPicker

iCloud Drive folder selector.

**Anatomy**
- Section label ("Folder")
- `Settings/Row` with label, current path value, trailing chevron

**Dimensions**

| Property | Value |
|----------|-------|
| Row | Standard iOS list row height (44pt) |

**Color rules**

| Element | Token |
|---------|-------|
| Label | `textPrimary` |
| Value / path | `textSecondary` |
| Chevron | `textSecondary` |

**Empty state value:** "Select folder"

---

### Settings/Copyright

Footer pinned to the bottom of the Settings screen.

**Anatomy**
- Single text label

**Dimensions**

| Property | Value |
|----------|-------|
| Height | 56pt |
| Alignment | Center |

**Typography**

| Element | Font | Weight | Size |
|---------|------|--------|------|
| Footer text | SF Pro | Regular | 13pt |

**Color rules**

| Element | Token |
|---------|-------|
| Background | `background` |
| Text | `textSecondary` |

Content: "Verso v1.0 · Built with care"

---

### ConfirmationDialog (Folder change)

Modal confirmation when the user picks a new iCloud Drive folder.

**Anatomy**
- Title ("Move Articles?")
- Body text
- Primary action button ("Move")
- Secondary action button ("Keep here")

**Color rules:** Uses `PrimaryButton` and `SecondaryButton` token rules (see §5).

---

## 4. Share Extension

---

### ShareSheet

Modal sheet presented when saving from another app.

**Anatomy**
- Sheet container
- `ArticlePreview` (top section)
- `SaveButton` + `CancelButton` (bottom)

**Dimensions**

| Property | Value |
|----------|-------|
| Style | Compact sheet |
| Corner radius (top) | 12pt (`radius/md`) |

**Color rules**

| Element | Token |
|---------|-------|
| Sheet background | `surface` |
| Top border | `border` 1pt |

---

### ArticlePreview

Preview of the article being saved, inside the share sheet.

**Anatomy**
- URL / domain
- Article title (when available)
- Favicon / thumbnail placeholder

**Dimensions**

| Property | Value |
|----------|-------|
| Padding | md — 16pt |

**Typography**

| Element | Font | Weight | Size |
|---------|------|--------|------|
| Title | SF Pro | Semibold | 17pt |
| URL / domain | SF Pro | Regular | 13pt |

**Color rules**

| Element | Token | State |
|---------|-------|-------|
| Title | `textPrimary` | Loaded |
| URL / domain | `textSecondary` | Loaded |
| Placeholder blocks | `placeholder` (shimmer) | Loading |
| Error message | `error` | Error |

---

### SaveButton

Primary action button in the share extension. Uses `PrimaryButton` rules with additional states.

**Dimensions**

| Property | Value |
|----------|-------|
| Height | 50pt |
| Corner radius | 12pt (`radius/md`) |

**Typography:** SF Pro Semibold, 17pt, white text.

**Color rules**

| State | Background token |
|-------|-----------------|
| Default | `accent` |
| Loading | `accent` at 50% opacity + spinner |
| Success | `success` |
| Error | `error` |

---

## 5. Common Components

---

### PrimaryButton

Filled button. Main call-to-action.

**Anatomy**
- Label text
- Filled background

**Dimensions**

| Property | Value |
|----------|-------|
| Height | 50pt |
| Corner radius | 12pt (`radius/md`) |
| Horizontal padding | md — 16pt (minimum) |

**Typography**

| Element | Font | Weight | Size |
|---------|------|--------|------|
| Label | SF Pro | Semibold | 17pt |

**Color rules**

| Element | Token | State |
|---------|-------|-------|
| Background | `accent` | Default |
| Background | `accentPressed` | Pressed |
| Background | `accent` at 40% opacity | Disabled |
| Background | `accent` at 50% opacity + spinner | Loading |
| Label | White (fixed) | All — white on `accent` verified AA on all themes |

---

### SecondaryButton

Outlined button. Secondary action.

**Anatomy**
- Label text
- Transparent background with border

**Dimensions**

| Property | Value |
|----------|-------|
| Height | 50pt |
| Corner radius | 12pt (`radius/md`) |
| Border | 1.5pt |
| Horizontal padding | md — 16pt (minimum) |

**Typography**

| Element | Font | Weight | Size |
|---------|------|--------|------|
| Label | SF Pro | Semibold | 17pt |

**Color rules**

| Element | Token | State |
|---------|-------|-------|
| Background | Transparent | Default |
| Background | `accent` at 15% opacity | Pressed |
| Border | `accent` 1.5pt | Default |
| Border | `accentPressed` 1.5pt | Pressed |
| Border | `accent` at 40% opacity | Disabled |
| Label | `accent` | Default / Pressed |
| Label | `accent` at 40% opacity | Disabled |

---

### TextButton

Label-only button. Tertiary or dismissal action.

**Anatomy**
- Label text only (no background, no border)

**Dimensions**

Minimum touch target: 44×44pt.

**Typography**

| Element | Font | Weight | Size |
|---------|------|--------|------|
| Label | SF Pro | Semibold | 17pt |

**Color rules**

| Element | Token | State |
|---------|-------|-------|
| Label | `accent` | Default |
| Label | `accent` at 60% opacity | Pressed |

---

### IconButton

Icon-only button. Used in `ReadingChrome` bottom bar, navigation bars.

**Anatomy**
- SF Symbol icon
- Transparent background (touch target larger than icon)

**Dimensions**

| Property | Value |
|----------|-------|
| Touch target | 44×44pt |
| Icon size | 24pt SF Symbol |

**Color rules**

| Element | Token | State |
|---------|-------|-------|
| Icon | `textSecondary` | Default (idle) |
| Icon | `accent` | Active / selected |
| Icon | `accent` at 60% opacity | Pressed |
| Icon | `textSecondary` at 30% opacity | Disabled |
| Background | Transparent | All |

---

### StatusBadge

Small visual indicator of article status. Always paired with a visible text label — never used alone.

**Anatomy**
- Dot (Unread variant) or pill with label (Reading / Read variants)

**Dimensions**

| Variant | Dimension |
|---------|-----------|
| Unread dot | 12pt diameter circle |
| Reading / Read badge height | 8pt |
| Reading / Read badge min-width | 16pt |

**Color rules**

| Variant | Element | Token / Value |
|---------|---------|--------------|
| Unread | Dot | `statusUnread` |
| Reading | Badge background | `statusReading` |
| Reading | Label | White (fixed) |
| Read | Badge background | `statusRead` |
| Read | Label | White (fixed) |

---

### TextField

Text input for forms and settings.

**Anatomy**
- Placeholder / input text
- Container with border
- Error message (below, when in error state)

**Dimensions**

| Property | Value |
|----------|-------|
| Height | 44pt |
| Corner radius | 10pt (`radius/sm`) |
| Horizontal padding | md — 16pt |

**Typography**

| Element | Font | Weight | Size |
|---------|------|--------|------|
| Placeholder / input text | SF Pro | Regular | 17pt |
| Error message | SF Pro | Regular | 13pt |

**Color rules**

| Element | Token | State |
|---------|-------|-------|
| Background | `surface` | All |
| Border | `border` 1pt | Default |
| Border | `accent` 1pt | Focused |
| Border | `error` 1pt | Error |
| Placeholder text | `textSecondary` | Empty |
| Input text | `textPrimary` | Has text |
| Error message | `error` | Error |

---

## 6. Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-05-03 | Initial unified component spec for developer handoff. Consolidates `component-inventory.md` v1.4 and `COMPONENTS.md` v1.1 into per-component anatomy + dimensions + typography + color rules. Covers all 25 components across 5 screens. (FAB-87) |
