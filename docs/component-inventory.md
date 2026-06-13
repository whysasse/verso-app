# Component Inventory — Verso

**Version:** 1.4  
**Date:** 2026-05-02  
**Status:** Ready for implementation  
**Related:** FAB-68

**Related docs:**
- Token names, values, and usage intent → `DESIGN_TOKENS.md`
- Token-to-component mapping, anatomy, and color rules → `COMPONENT_SPECS.md`
- Behavioral specs, reading controls, immersive mode → `DESIGN_SYSTEM_FOUNDATIONS.md`

---

## Overview

This document catalogs all UI components needed for Verso. Each component includes its name, variants, states, and behavioral specifications.

> **Note on token references:** Component entries below reference tokens by display name (e.g., "Surface", "Text Primary") for readability. For exact Swift identifiers and per-state token mapping, see `COMPONENT_SPECS.md`. For token values across all four themes, see `DESIGN_TOKENS.md`.

**Navigation model:** Verso uses a Navigation-stack flow (push/pop), not a TabBar. There is no tab bar component. The three main surfaces — Article List, Article Detail, and Settings — are reached via NavigationLink and a Settings icon in the nav bar.

---

## 1. Article List Screen

### 1.1 NavigationBar

Large title navigation bar at the top of the article list.

| Property | Value |
|----------|-------|
| Title | "Verso" |
| Style | Large title (collapsed on scroll) |
| Font | SF Bold, 34pt (per DS 3.5) |
| Padding | Safe area + 4pt (per DS 7.3) |
| Behavior | Collapses to compact (inline) on scroll |

**Variants:**
- Expanded (default): Large title visible
- Compact: Title in navigation bar, triggered on scroll

**States:**
- Default: Large title visible
- Scrolled: Compact style; title becomes inline

---

### 1.2 SearchBar

Search input for filtering articles by title.

| Property | Value |
|----------|-------|
| Placeholder | "Search titles..." |
| Font | SF Regular, 17pt (per DS 3.5) |
| Corner radius | 10pt |
| Background | Surface (per DS 2.1) |
| Icon | SF Symbol `magnifyingglass` |

**States:**
- Inactive: Placeholder visible, icon Text Secondary
- Active: Cursor blinking, keyboard shown
- Has-text: "Clear" button (SF Symbol `xmark.circle.fill`) appears

---

### 1.3 FilterChipBar

Horizontal scrolling bar containing a set of FilterChip components (see §5.6).

| Property | Value |
|----------|-------|
| Height | 36pt |
| Horizontal padding | md (16pt per DS 7.1) |
| Chip gap | xs (8pt per DS 7.3) |
| Scroll | Horizontal, no snap |

**Chips (in order):**
- All: Shows total article count
- Unread: Shows unread count
- Reading: Shows currently reading count
- Read: Shows completed count

Single-selection — one chip is always active. Default: All.

---

### 1.4 ArticleCard

Card component displaying a single article in the list.

| Property | Value |
|----------|-------|
| Padding | md (16pt per DS 7.1) |
| Corner radius | 12pt |
| Background | Surface (per DS 2.1) |
| Margin between cards | sm (12pt) |

**Elements:**

| Child | Property | Value |
|-------|----------|-------|
| Title | Font | SF Semibold, 17pt (per DS 3.5) |
| Title | Color | Text Primary |
| Title | Line height | 1.3× |
| Source | Font | SF Regular, 15pt, 1.4× line height (per DS 3.5) |
| Source | Color | Text Secondary |
| Date | Font | SF Regular, 13pt (per DS 3.5) |
| Date | Color | Text Secondary |
| Status badge | Position | Top-right corner |
| Status badge | Size | 12pt diameter (unread dot) or 8pt height (badge) |

**States:**
- Unread: 12pt Accent dot indicator visible
- Reading: "Reading" badge, 8pt height, Accent background
- Read: "Read" badge, 8pt height, Text Secondary background

---

### 1.5 EmptyState

Displayed when no articles match the current filter.

| Property | Value |
|----------|-------|
| Vertical spacing | 2xl (48pt per DS 7.1) |
| Horizontal padding | md (16pt) |

**Elements:**

| Child | Property | Value |
|-------|----------|-------|
| Icon | SF Symbol | `doc.text.magnifyingglass` |
| Icon | Size | 48pt |
| Icon | Color | Text Secondary |
| Headline | Font | SF Semibold, 20pt (per DS 3.5) |
| Headline | Color | Text Primary |
| Subheadline | Font | SF Regular, 15pt (per DS 3.5) |
| Subheadline | Color | Text Secondary |

**Variants:**
- No articles: "No articles yet"
- No results: "No articles match your search"

---

### 1.6 LoadingState

Skeleton shimmer while loading articles.

| Property | Value |
|----------|-------|
| Animation | Shimmer moving left to right, 1.5s duration |
| Skeleton block fill | Placeholder (per DS 2.1) |
| Shimmer highlight | Text Secondary at 30% opacity |
| Background | Surface |

**Elements:**

5 ArticleCard skeletons at standard spacing. Each skeleton renders three shimmer blocks in place of the card's live content:

| Block | Approx. width | Height | Represents |
|-------|--------------|--------|------------|
| Title block | 75% of card width | 17pt | Article title |
| Source line | 40% of card width | 13pt | Source name |
| Date line | 25% of card width | 13pt | Date |

Status badge area is omitted in skeleton state. Corner radius matches the live card (12pt).

---

## 2. Article Detail Screen

### 2.1 ReadingChrome

Top and bottom bars that hide during reading.

| Property | Value |
|----------|-------|
| Background | Surface (per DS 2.1) at 95% opacity |
| Transition duration | Hide: 300ms ease-out; Reveal: 200ms ease-in |
| Height | Top: safe area + 44pt; Bottom: 44pt + safe area |

**Top bar elements:**
- Back button (SF Symbol `chevron.left`, 24pt)
- Article title (truncated, SF Regular, 15pt)
- Open externally button (SF Symbol `arrow.up.right`, 24pt) — top-right

**Bottom bar elements (all use IconButton, §5.5):**
- Font size controls (− / +): SF Symbols `minus` / `plus`
- Line spacing: SF Symbol `text.alignleft`
- Margin: SF Symbol `arrow.left.and.right.righttriangle`
- Theme: SF Symbol `circle.lefthalf.filled`
- Mark as read: SF Symbol `checkmark.circle`

**States:**
- Visible: Opacity 1.0
- Hidden: Opacity 0.0
- Auto-hide: After 2s no interaction (per DS 5.1)

**First-use hint:** when ReadingChrome first enters Hidden state, it triggers the ImmersiveHintPill (§2.6) if the hint has not been shown before. The pill is a separate component — ReadingChrome is responsible only for signalling the trigger, not rendering the pill.

---

### 2.2 ArticleHeader

Header area with title and metadata.

| Property | Value |
|----------|-------|
| Vertical spacing | lg (24pt per DS 7.1) |
| Horizontal padding | User's selected margins (per DS 4.2) |

**Elements:**

| Child | Property | Value |
|-------|----------|-------|
| Title (H1) | Font | User's selected font, Bold 28pt (per DS 3.4) |
| Title | Line height | 1.2× |
| Title | Color | Text Primary |
| Source | Font | SF Regular, 15pt |
| Source | Color | Text Secondary |
| Date | Font | SF Regular, 13pt |
| Date | Color | Text Secondary |

---

### 2.3 MarkdownBody

The rendered article content.

| Property | Value |
|----------|-------|
| Font | User's selected font at selected size (per DS 3.2) |
| Line height | User's selected line spacing (per DS 4.1) |
| Horizontal padding | User's selected margins (per DS 4.2) |
| Color | Text Primary |
| Max width (iPad) | 680px (per DS 4.2) |

**Markdown elements supported:**
- Paragraphs
- Headings (H1–H4 use DS 3.4)
- Bold / Italic
- Links (Accent color, underlined)
- Lists (ordered, unordered)
- Blockquotes (border-left Accent)
- Code blocks (Surface background, SF Mono)
- Images (aspect fit, full width)
- Horizontal rules

---

### 2.4 ScrollProgress

Progress indicator showing read position.

| Property | Value |
|----------|-------|
| Height | 3pt |
| Background | Divider |
| Fill | Accent |
| Position | Top of screen, below ReadingChrome |

**States:**
- Empty: 0% fill
- In-progress: Percentage matches scroll position
- Complete: 100% fill

---

### 2.5 ReadingControls

Bottom sheet that slides up from the bottom of the Reading View. Two variants, toggled by the relevant bottom-bar icon.

| Property | Value |
|----------|-------|
| Background | Surface |
| Corner radius | 16pt (top corners) |
| Top drag handle | 36×4pt pill, Border color |
| Padding | 20pt horizontal, 16pt top, 28pt bottom |

**Variant: Font**

Shows two stacked control groups separated by a divider:

| Control | Type | Options |
|--------|------|---------|
| Font Size | Stepper (A− / value / A+) | XS 14pt → XXL 26pt (per DS 3.2) |
| Line Spacing | Segmented (icon tiles) | Compact, Normal, Relaxed (default), Airy (per DS 4.1) |

**Variant: Theme**

Shows a single row of 4 theme swatches:

| Control | Type | Options |
|--------|------|---------|
| Theme | Color tile + label | Paper, Sepia, Night, Ink |

Each swatch is a colored rectangle (32pt tall, full flex width) with the theme name below in 11pt. The active theme tile has a 2pt Accent border; others have a 1pt Border stroke.

---

### 2.6 ImmersiveHintPill

A one-time contextual hint shown the first time the Reading View chrome auto-hides. Not part of the chrome bars — it sits above article content on its own z-layer.

| Property | Value |
|----------|-------|
| Text | "Tap anywhere to reveal" |
| Font | SF Regular, 13pt |
| Text color | White |
| Background | `rgba(0, 0, 0, 0.70)` — fixed, not theme-aware |
| Corner radius | 20pt (fully rounded pill) |
| Padding | 6pt vertical, 14pt horizontal |
| Position | Horizontally centered; ~100pt above bottom safe area |
| Z-order | Above MarkdownBody, below ReadingChrome bars |
| Animation in | Fade in, 200ms ease-in |
| Animation out | Fade out on tap, 200ms ease-out |

**Why theme-agnostic background:** the pill must be legible on all four themes. A fixed dark semi-transparent background with white text passes contrast on Paper and Sepia (light) without issue, and remains visible on Night and Ink (dark) due to the white text and alpha contrast. A theme-aware variant can be considered post-MVP if dark-theme legibility proves insufficient.

**Lifecycle:**

| Event | Condition | Action |
|-------|-----------|--------|
| Show | Chrome auto-hides for the first time AND `hasShownImmersiveHint == false` AND VoiceOver is inactive | Fade in |
| Dismiss | User taps anywhere on screen | Fade out; set `hasShownImmersiveHint = true` in UserDefaults |
| Suppress | `UIAccessibility.isVoiceOverRunning == true` | Never shown; flag is not written (see accessibility-specs.md §5.3) |

**States:**
- Visible: Opacity 1.0, shown over article content
- Hidden: Not rendered (after permanent dismissal or suppressed by VoiceOver)

**Relationship to ReadingChrome:** the hint's show condition is triggered by ReadingChrome entering its Hidden state for the first time. The hint does not affect chrome visibility — tapping to dismiss the hint simultaneously reveals the chrome (both are responses to the same tap event).

---

## 3. Settings Screen

The Settings screen has four labeled sections and a copyright footer. It does **not** use InsetGrouped SwiftUI list style — sections are laid out manually with plain text headers and component rows. Font size, line spacing, and margin controls live in the Reading Controls bottom sheet (§2.5), not here.

**Sections (top to bottom):**
1. Theme
2. Typography
3. Folder
4. Links
5. Settings/Copyright footer

---

### 3.1 ThemeSelector

Four ThemeChip components displayed in a horizontal row under a "Theme" section label.

| Property | Value |
|----------|-------|
| Chip size | 80pt wide × 100pt tall |
| Chip gap | ~12.7pt (evenly distributed across 358pt container) |
| Section label | "Theme", SF Regular, 13pt, Text Secondary |

**ThemeChip variants:**
- Paper (default, selected): `#F5F0E8` swatch, 2pt Accent border, label "Paper"
- Sepia: `#F2E8D5` swatch, 1pt Border stroke, label "Sepia"
- Night: `#1C1A16` swatch, 1pt Border stroke, label "Night"
- Ink: `#111418` swatch, 1pt Border stroke, label "Ink"

Each chip shows a 32pt-tall color rectangle (corner radius 8pt) with the theme name below it in 11pt SF Regular.

---

### 3.2 FontFamilySelector (Settings/Type)

A selectable list of font options under a "Typography" section label. Each option is a `Settings/Type` row component.

| Property | Value |
|----------|-------|
| Section label | "Typography", SF Regular, 13pt, Text Secondary |
| Row height | ~78–79pt |
| Options | New York (default), Georgia, SF Pro, OpenDyslexic |

**Settings/Type row:**

| Element | Property | Value |
|---------|----------|-------|
| Font name | Font | The row's own font family, Semibold, 17pt |
| Font name | Color | Text Primary |
| Preview text | Font | The row's own font family, Regular, 15pt |
| Preview text | Color | Text Secondary |
| Preview text | Content | "The quick brown fox jumps over the laz..." |
| Selection indicator | Style | Filled dot, Accent color, top-right of row |

**Variants:**
- `Selected`: shows selection dot indicator
- `Enabled`: no indicator, full opacity

---

### 3.3 FolderPicker

iCloud Drive folder selector under a "Folder" section label. Uses a `Settings/Row` (Type=Folder).

| Property | Value |
|----------|-------|
| Section label | "Folder", SF Regular, 13pt, Text Secondary |
| Row label | "Reading Folder" |
| Value | Current folder path (e.g., "~/Documents/Verso") |
| Trailing | `›` chevron |
| Action | Opens iCloud Drive file picker |
| Empty state | "Select folder" |

---

### 3.4 Links

Two navigation rows under a "Links" section label. Uses `Settings/Row` (Type=Default).

| Row | Label | Action |
|-----|-------|--------|
| Privacy Policy | "Privacy Policy" | Opens web view or Safari |
| About | "About this app" | Opens About screen |

---

### 3.5 Settings/Copyright

Footer component pinned to the bottom of the Settings screen.

| Property | Value |
|----------|-------|
| Content | "Verso v1.0 · Built with care" |
| Font | SF Regular, 13pt |
| Color | Text Secondary |
| Alignment | Center |
| Height | 56pt |
| Background | Background |

---

### 3.6 ConfirmationDialog (Folder Change)

Modal dialog shown when user picks a new iCloud Drive folder and existing articles need to be migrated.

| Property | Value |
|----------|-------|
| Component | `Settings/ConfirmationDialog` |
| Title | "Move Articles?" |
| Body | "Move your existing articles to the new folder? Your old folder won't be touched if you choose No." |
| Primary action | "Move" (Primary button, Accent) |
| Secondary action | "Keep here" (Secondary button) |

---

## 4. Share Extension

### 4.1 ShareSheet

Modal sheet when share extension opens.

| Property | Value |
|----------|-------|
| Style | Compact sheet |
| Corner radius | 12pt (top) |
| Background | Surface |

---

### 4.2 ArticlePreview

Preview of the article being saved.

| Property | Value |
|----------|-------|
| Padding | md (16pt) |
| Elements | URL, Title (if available), Favicon/domain |

**States:**
- Loading: Shimmer placeholder
- Loaded: Shows title, URL, source
- Error: "Could not extract article" message

---

### 4.3 SaveButton

Primary action button in share extension.

| Property | Value |
|----------|-------|
| Style | Primary (filled, Accent background) |
| Height | 50pt (per DS 6.1: minimum 44pt + margin) |
| Corner radius | 12pt |
| Text | "Save to Verso" |

**States:**
- Default: Accent background, white text
- Loading: Accent background at 50% opacity, spinner
- Success: Success color checkmark (per DS 2.5), "Saved!"
- Error: Error color background (per DS 2.5), "Try again"

---

### 4.4 CancelButton

Secondary action to dismiss share sheet.

| Property | Value |
|----------|-------|
| Style | Text button |
| Text | "Cancel" |
| Color | Accent |

---

## 5. Common Components

### 5.1 PrimaryButton

Filled button with Accent background.

| Property | Value |
|----------|-------|
| Height | 50pt (per DS 6.1) |
| Corner radius | 12pt |
| Font | SF Semibold, 17pt |
| Text color | White |
| Background | Accent (per DS 2.1) |

**States:**
- Default: Accent background
- Pressed: Accent Pressed background (per DS 2.1)
- Disabled: Accent at 40% opacity, non-interactive

---

### 5.2 SecondaryButton

Outlined button with Accent border.

| Property | Value |
|----------|-------|
| Height | 50pt |
| Corner radius | 12pt |
| Border | 1.5pt Accent |
| Font | SF Semibold, 17pt |
| Text color | Accent |

**States:**
- Default: Transparent background, Accent border
- Pressed: Accent at 15% opacity background
- Disabled: Border at 40% opacity, non-interactive

---

### 5.3 TextButton

Button without background.

| Property | Value |
|----------|-------|
| Font | SF Semibold, 17pt |
| Text color | Accent |

**States:**
- Default: Accent text
- Pressed: Accent at 60% opacity

---

### 5.4 StatusBadge

Small badge indicating article status.

| Property | Value |
|----------|-------|
| Unread dot | 12pt circle |
| Badge | 8pt height, 16pt minimum width |

**Variants:**
- Unread: Accent dot
- Reading: "Reading" label, Accent background, white text
- Read: "Read" label, Text Secondary background, white text

---

### 5.5 IconButton

Icon-only button used in the ReadingChrome bottom bar and other contexts where a label would clutter the UI.

| Property | Value |
|----------|-------|
| Touch target | 44×44pt (per DS 6.1) |
| Icon size | 24pt |
| Icon color | Text Secondary (idle), Accent (active/selected) |
| Background | Transparent |

**States:**
- Default: Icon at Text Secondary color
- Active / Selected: Icon at Accent color (e.g., when a control is engaged)
- Pressed: Opacity 60%
- Disabled: Opacity 30%, non-interactive

**Usage:** Font size `−` / `+` controls, line spacing icon, margin icon, theme icon, and mark-as-read icon in ReadingChrome. Also used for the Settings icon in the Article List navigation bar.

---

### 5.6 FilterChip

Individual chip within a FilterChipBar. Displays a label and an article count.

| Property | Value |
|----------|-------|
| Font | SF Semibold, 15pt (per DS 3.5) |
| Height | 36pt |
| Horizontal padding | sm (12pt per DS 7.1) |
| Corner radius | 18pt (fully rounded) |

**States:**
- Unselected: Background transparent, text Text Secondary
- Selected: Background Accent at 15% opacity, text Accent

**Count display:** Count is shown inline after the label (e.g., "Unread 12"). When count is zero the chip is shown but dimmed to 50% opacity; it remains tappable to clear the filter.

---

### 5.7 TextField

Text input for forms and search.

| Property | Value |
|----------|-------|
| Height | 44pt (per DS 6.1) |
| Corner radius | 10pt |
| Font | SF Regular, 17pt |
| Horizontal padding | md (16pt) |
| Background | Surface |
| Border | 1pt Divider |

**States:**
- Empty: Placeholder visible
- Filled: Text visible
- Error: Border Error (per DS 2.5), error message below in Error color

---

## 6. Design Tokens Reference

> This section has been superseded by dedicated token documents. Do not update values here.
>
> - Token names, values, and usage intent (all themes) → `DESIGN_TOKENS.md`
> - Which tokens apply to which component elements, per state → `COMPONENTS.md`
> - Accessibility requirements → `DESIGN_SYSTEM_FOUNDATIONS.md` §6

---

## 7. Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.4 | 2026-05-02 | Rewrote §3 Settings Screen to match final hi-fi design: replaced 8 sub-sections with 6 that reflect the actual layout (Theme, FontFamilySelector, FolderPicker, Links, Copyright, ConfirmationDialog). FontSizeSelector, LineSpacingSelector, and MarginSelector removed from Settings — these live in §2.5 ReadingControls. Updated §2.5 ReadingControls to document Font and Theme variants of the bottom sheet. Updated §2.1 ReadingChrome top bar to include the open-externally icon. |
| 1.3 | 2026-04-22 | Updated overview to note COMPONENTS.md and DESIGN_TOKENS.md as authoritative sources for token mapping and values. Replaced §6 Design Tokens Reference with pointers to the new dedicated files — values are no longer maintained here. |
| 1.2 | 2026-04-20 | Aligned with DS v1.5: PrimaryButton Pressed state now references `Accent Pressed` token instead of opacity trick. LoadingState skeleton blocks now reference `Placeholder` token as base fill. Added `Accent Pressed` and `Placeholder` to the Design Tokens Reference table (§6.1). |
| 1.1 | 2026-04-19 | Added ImmersiveHintPill (§2.6) — new component for the first-use hint in Reading View. Updated ReadingChrome (§2.1) to reference the trigger relationship. |
| 1.1 | 2026-04-19 | Fixed TextField error state to use Error token (DS 2.5). Added IconButton (§5.5) and FilterChip (§5.6) as common components. Clarified FilterChipBar to reference FilterChip. Expanded LoadingState skeleton spec. Added navigation model note. Updated Design Tokens Reference to include Error, Warning, Success. |
| 1.0 | 2026-04-19 | Initial component inventory for FAB-68 |