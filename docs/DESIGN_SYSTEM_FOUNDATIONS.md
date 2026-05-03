# Design System Foundations — Verso

**Version:** 1.8  
**Date:** 2026-05-01  
**Status:** Decided — ready for Figma implementation

**Related:**
- Token registry (authoritative token names + values) → `DESIGN_TOKENS.md`
- Theme intent and personality → `THEMES.md`
- Component token mapping → `COMPONENTS.md`
- Figma token naming conventions → `FIGMA_DESIGN_SYSTEM_REFERENCE.md`

> **Note on scope:** This document captures design rationale, philosophy, and behavioral specifications. It is not the authoritative source for token values, component token usage, or theme rationale — those have dedicated files listed above. When this document and `DESIGN_TOKENS.md` conflict on a value, `DESIGN_TOKENS.md` wins.

---

## 1. Design Philosophy

The app should feel like reading a book, not using software. Every decision — color, type, spacing, behavior — serves that single idea. The interface is a guest in the reader's experience: it appears when needed and disappears when it isn't.

**Principles:**
- **Warmth over precision.** Colors reference physical materials (paper, ink, candlelight), not screens.
- **Generosity in layout.** Wide margins, open line spacing, unhurried rhythm. Never cramped.
- **Interface as guest.** Chrome hides during reading. Content is the host.
- **Opinionated defaults, user freedom.** The defaults are carefully chosen. Users can adjust — but they don't have to.

---

## 2. Color Themes

Four themes covering warm-light, classic-warm, warm-dark, and cool-dark. All themes share the same structure — only the values change.

The default is **Paper**. Users choose their theme during onboarding and can change it anytime in Settings.

> **Authoritative source for token values:** `DESIGN_TOKENS.md` §1–2. The tables below are maintained for design rationale and context. If a hex value here conflicts with `DESIGN_TOKENS.md`, the latter is correct.  
> **Authoritative source for theme intent and personality:** `THEMES.md`.

### 2.1 Paper *(default)*

Inspired by aged, quality paper stock. The workhorse theme — comfortable in daylight.

| Token | Value | Usage |
|-------|-------|-------|
| Background | `#F5F0E8` | Article background, main screens |
| Text Primary | `#2C2924` | Body text, titles |
| Text Secondary | `#6E675F` | Metadata (source, date), captions |
| Surface | `#EDE8DF` | Top/bottom reading bars, cards |
| Accent | `#766655` | Interactive elements, active states |
| Accent Pressed | `#584D40` | Pressed/active state of interactive elements |
| Accent Surface | `rgba(#766655, 15%)` | Background behind accent-colored text (e.g. selected FilterChip) |
| Border | `#DDD8CE` | Separators, list item borders |
| Placeholder | `#CEC8BC` | Image placeholders, skeleton loading fills |

### 2.2 Sepia

Classic warm sepia — closer to vintage books and warm lamp light.

| Token | Value | Usage |
|-------|-------|-------|
| Background | `#F2E8D5` | Article background, main screens |
| Text Primary | `#2E2013` | Body text, titles |
| Text Secondary | `#755E40` | Metadata, captions |
| Surface | `#E8DEC7` | Reading bars, cards |
| Accent | `#825A37` | Interactive elements, active states |
| Accent Pressed | `#614429` | Pressed/active state of interactive elements |
| Accent Surface | `rgba(#825A37, 15%)` | Background behind accent-colored text |
| Border | `#D9CAAC` | Separators |
| Placeholder | `#C8BCA0` | Image placeholders, skeleton loading fills |

### 2.3 Night *(warm dark)*

A dark room lit by a lamp. Warm dark for low-light reading — less harsh than cold dark themes.

| Token | Value | Usage |
|-------|-------|-------|
| Background | `#1C1A16` | Article background, main screens |
| Text Primary | `#E8E0D0` | Body text, titles |
| Text Secondary | `#8F897F` | Metadata, captions |
| Surface | `#252320` | Reading bars, cards |
| Accent | `#C4A97D` | Interactive elements, active states |
| Accent Pressed | `#937F5E` | Pressed/active state of interactive elements |
| Accent Surface | `rgba(#C4A97D, 15%)` | Background behind accent-colored text |
| Border | `#2E2B26` | Separators |
| Placeholder | `#302E2A` | Image placeholders, skeleton loading fills |

### 2.4 Ink *(cool dark)*

Cooler and more neutral. For users who prefer a modern dark mode over a warm one.

| Token | Value | Usage |
|-------|-------|-------|
| Background | `#111418` | Article background, main screens |
| Text Primary | `#E4E6EB` | Body text, titles |
| Text Secondary | `#7E8492` | Metadata, captions |
| Surface | `#181C22` | Reading bars, cards |
| Accent | `#7B9FD4` | Interactive elements, active states |
| Accent Pressed | `#5C779F` | Pressed/active state of interactive elements |
| Accent Surface | `rgba(#7B9FD4, 15%)` | Background behind accent-colored text |
| Border | `#1E2228` | Separators |
| Placeholder | `#202630` | Image placeholders, skeleton loading fills |

### 2.5 Semantic Colors

Semantic tokens communicate status and outcome. Because each theme has very different background luminance, each theme defines its own values — light themes use dark, saturated tones; dark themes use light, desaturated tones. All values must meet WCAG AA (4.5:1) on both Background and Surface within their theme.

| Token   | Paper       | Sepia       | Night       | Ink         | Usage |
|---------|-------------|-------------|-------------|-------------|-------|
| Error   | `#C0392B`   | `#C0392B`   | `#F87171`   | `#FC8181`   | Validation errors, destructive states |
| Warning | `#B45309`   | `#B45309`   | `#FCD34D`   | `#F6E05E`   | Cautions, non-critical issues |
| Success | `#166534`   | `#166534`   | `#4ADE80`   | `#68D391`   | Confirmations, completed actions |

**Usage notes:**
- Error and Success tokens are used as icon/text tints and as border colors on interactive elements (e.g., text field validation). They are not used as large fill backgrounds.
- Warning is used for inline notices and caution badges only — not for actionable states.
- Verify these pairs against their theme's Background and Surface before Figma handoff.

### 2.6 Accessibility note on color

All text/background pairs in all four themes must meet **WCAG AA contrast** (4.5:1 for body text, 3:1 for large text). Verify all token pairs before Figma handoff. Pay special attention to Text Secondary on Surface in Night and Ink themes.

---

## 3. Typography

> **Authoritative source for typography tokens:** `DESIGN_TOKENS.md` §6. The specs below are maintained for design rationale and reading behavior context.

### 3.1 Font choices

Users select one of four fonts. The default is New York.

| Font | Type | Source | Notes |
|------|------|--------|-------|
| **New York** *(default)* | System serif | Apple system font (iOS 13+) | Designed by Apple for reading on screens. Elegant, warm, book-like. Best match for the app's aesthetic. |
| **Georgia** | Classic serif | System font | Universally loved for long-form reading. Safe, familiar, slightly more traditional. |
| **San Francisco** | System sans-serif | Apple system font | Clean and modern. For users who prefer sans-serif body text. |
| **OpenDyslexic** | Dyslexia-adapted | Bundled (open-source, free) | Mandatory accessibility option. Must be bundled with the app — not a system font. |

**Font weight handling for OpenDyslexic:** OpenDyslexic's weight variants are separate font files (Regular/Bold), not weight axes. The app loads both variants and maps: Regular → OpenDyslexic-Regular, Semibold/Bold → OpenDyslexic-Bold.

### 3.2 Font size scale

Six steps. Default is Medium. Size labels shown to user; pt values used in implementation.

| Label | Size | Weight | Line Height | Notes |
|-------|------|--------|--------------|-------|
| XS | 14pt | 400 (Regular) | 1.75× | Very small — for users with excellent eyesight |
| S | 16pt | 400 (Regular) | 1.75× | Small |
| **M** | **18pt** | **400 (Regular)** | **1.75×** | **Default** |
| L | 20pt | 400 (Regular) | 1.75× | Comfortable for most users |
| XL | 22pt | 400 (Regular) | 1.6× | Large — slightly tighter for legibility |
| XXL | 26pt | 400 (Regular) | 1.5× | Extra large — approaches large print |

**Rationale:** All reading sizes use Regular (400) weight — Medium/Bold weights reduce legibility at smaller sizes and add visual weight inappropriate for long-form reading. The line height decreases slightly at larger sizes (XXL) to maintain visual balance with longer lines.

### 3.3 Dynamic Type

The app must support iOS Dynamic Type. The font scale above maps to `UIFont.TextStyle` sizes and scales with the user's system accessibility settings. A user who has set their system font to "Accessibility Extra Large" should see that respected in the reading view.

### 3.4 Heading typography (in articles)

Article headings use the same font family as body text but with adjusted weight and spacing.

| Level | Size | Weight | Line Height | Notes |
|-------|------|--------|--------------|-------|
| H1 | 28pt | 700 (Bold) | 1.2× | Article title — largest, most prominent |
| H2 | 24pt | 600 (Semibold) | 1.25× | Section heads |
| H3 | 20pt | 600 (Semibold) | 1.3× | Subsection heads |
| H4 | 18pt | 600 (Semibold) | 1.35× | Minor heads |

**Rationale:** Bold/Semibold headings create clear hierarchy without competing with body text. Tight line heights keep headings visually coherent as block-level elements.

### 3.5 UI typography (non-reading)

For UI elements outside the reading view (list, settings, navigation): use **San Francisco** at system sizes, regardless of the user's chosen reading font. The reading font applies only inside the Reading View.

| Element | Size | Weight | Line Height |
|---------|------|--------|--------------|
| Screen title | 34pt | Bold | 1.2× |
| List item title | 17pt | Semibold | 1.3× |
| List item subtitle | 15pt | Regular | 1.4× |
| Button label | 17pt | Semibold | 1.0× |
| Caption | 13pt | Regular | 1.3× |

---

## 4. Reading Controls

Users can adjust two reading parameters beyond font: **line spacing** and **margins**. Both use stepped presets. Controls are accessible from the Reading View's bottom bar.

### 4.1 Line spacing

Four presets. Default is Relaxed — more generous than typical apps, matching the book-like aesthetic.

| Label | Line height multiplier | Character |
|-------|----------------------|-----------|
| Compact | 1.3× | Dense, efficient |
| Normal | 1.5× | Standard readable |
| **Relaxed** | **1.75×** | **Default — open, book-like** |
| Airy | 2.0× | Maximum breathing room |

### 4.2 Margins (horizontal)

Four presets controlling the horizontal padding around the article text. Default is Wide — generous, like a well-designed book.

| Label | Horizontal padding | Notes |
|-------|-------------------|-------|
| Compact | 16px each side | Near edge — for small screens or those who prefer dense layouts |
| Normal | 24px each side | Standard reading app default |
| **Wide** | **40px each side** | **Default — book-like, comfortable** |
| Extra Wide | 56px each side | Strong centering; best on larger iPhones and iPad |

**Max content width (iPad):** Cap the text column at 680px regardless of margin setting, to prevent excessively long lines on large screens.

---

## 5. Immersive Reading Mode

The Reading View operates in an immersive mode where the interface hides during reading and reappears on tap.

### 5.1 Behavior

| State | Chrome visibility | Trigger |
|-------|-------------------|---------|
| Entry | Visible | Always shown when article opens |
| Reading | Hidden | Auto-hides after 2 seconds of no interaction |
| Revealed | Visible | User taps anywhere on screen |
| Auto-hide | Hidden | Returns to hidden after 3 seconds of no interaction |

**Scroll does not trigger show/hide.** Only taps do. This allows continuous scrolling without chrome flickering.

**Exception:** If the user is actively interacting with a reading control (adjusting font size, spacing, theme), the chrome remains visible until they dismiss the control.

### 5.1b First-use hint

The first time chrome auto-hides (on first ever article open), a "Tap anywhere to reveal" pill is shown centered over the article content. It is dismissed on the user's first tap and never shown again (`UserDefaults` flag: `hasShownImmersiveHint`). The hint is suppressed entirely when VoiceOver is active — since auto-hide is disabled for VoiceOver users, the hint condition is never met. The flag must not be written during a VoiceOver session (see accessibility-specs.md §5.3).

### 5.2 Chrome elements

**Top bar (visible on tap):**
- Back button / chevron (left) → Reading List
- Article title (truncated, centered) — reminds user what they're reading
- Estimated reading time remaining (right, post-MVP)

**Bottom bar (visible on tap):**
- Font size controls (− / +)
- Line spacing selector (icon → popover with 4 presets)
- Margin selector (icon → popover with 4 presets)
- Theme switcher (icon → shows 4 theme chips inline)
- Mark as read toggle

### 5.3 Transitions

- **Hide:** Fade to opacity 0, 300ms ease-out
- **Reveal:** Fade to opacity 1, 200ms ease-in
- Both bars animate together (not independently)

---

## 6. Accessibility

### 6.1 Mandatory requirements

- **WCAG AA contrast** for all text/background pairs across all 4 themes — including Accent token where used as text (links)
- **Minimum touch target size:** 44×44pt for all interactive controls (iOS HIG standard)
- **VoiceOver support:** All interactive elements have descriptive accessibility labels; article content reads as a continuous flow. Chrome remains visible whenever `UIAccessibility.isVoiceOverRunning` is true (overrides 2-second auto-hide in immersive mode).
- **Dynamic Type:** All text scales with system accessibility settings (see Section 3.3)
- **Reading bar controls are icon-only** — no text labels — so Dynamic Type size does not affect reading bar layout
- **OpenDyslexic font option** (see Section 3.1)

### 6.2 iOS accessibility features to support

- **Display & Text Size settings** (bold text, larger text, button shapes, increase contrast, reduce transparency)
- **Reduce Motion:** Respect `UIAccessibility.isReduceMotionEnabled` — disable or reduce fade animations in immersive mode
- **Switch Control and AssistiveTouch:** Ensure all reading controls are reachable without tap gestures

### 6.3 Color contrast targets (verify all pairs)

Priority pairs to check across all themes:
- Text Primary on Background
- Text Primary on Surface
- Text Secondary on Background
- Text Secondary on Surface
- Accent on Background (for buttons/links)

---

## 7. Spacing Scale

> **Authoritative source for spacing tokens:** `DESIGN_TOKENS.md` §4. The tables below are maintained for Dynamic Type rationale and contextual usage guidance.

Base unit: **8px**. All spacing values are multiples of 8, with Dynamic Type scaling.

### 7.1 Core spacing tokens

| Token | Value | Usage |
|------|-------|-------|
| xxs | 4px | Minimal inline gaps |
| xs | 8px | Tight component spacing |
| sm | 12px | Filter chip interior spacing |
| md | 16px | Standard content padding |
| lg | 24px | Section spacing |
| xl | 32px | Major section divisions |
| 2xl | 48px | Screen-level vertical rhythm |
| 3xl | 64px | Extra breathing room |

### 7.2 Dynamic Type scaling

Spacing scales proportionally with typography. Vertical rhythm = 2× font size.

| Text Style | Base Font | S | M (default) | L | XL |
|-----------|-----------|---|-------------|---|-----|
| Body | 18pt | 16pt → 32pt | 18pt → 36pt | 20pt → 40pt | 22pt → 44pt |
| Title | 28pt | 24pt → 48pt | 28pt → 56pt | 32pt → 64pt | — |
| Caption | 13pt | 11pt → 22pt | 13pt → 26pt | 15pt → 30pt | — |

### 7.3 Contextual spacing

| Context | Token | Notes |
|---------|-------|-------|
| Screen margins | md (16pt) | Leading/trailing: safe area + 4pt minimum |
| Content padding | md (16pt) | Horizontal and vertical |
| Filter chip gaps | xs (8pt) | Between chips |
| Section separators | lg (24pt) | Vertical space between sections |

### 7.4 Implementation notes

- Use `@ScaledMetric` in SwiftUI for Dynamic Type spacing
- Spacing always rounds to multiples of 8 after scaling
- Minimum spacing never goes below the base token value

---

## 8. Corner Radius Scale

> **Authoritative source for radius tokens:** `DESIGN_TOKENS.md` §5.

All components use named radius tokens. This prevents ad-hoc values and ensures every element fits the same family of shapes.

### 8.1 Core radius tokens

| Token | Value | Usage |
|-------|-------|-------|
| `radius/sm` | 10pt | Inputs, search bars |
| `radius/md` | 12pt | Cards, buttons, sheets, modals |
| `radius/lg` | 18pt | Chips (fully rounded at 36pt height) |
| `radius/pill` | 20pt | Pill-shaped elements (fully rounded at 40pt height) |

**Implementation note:** `radius/lg` and `radius/pill` are designed to create fully rounded shapes at their respective component heights. If a component's height changes, revisit whether the token still produces the intended fully-rounded appearance, or use `radius/pill` as the safe fallback.

---

## 9. Theme Picker (Onboarding)

The theme picker appears in onboarding as **Screen 2** (immediately after Welcome), before the folder setup. Rationale: theme selection is the first delightful, personal interaction — it sets the tone before the functional setup steps. The user arrives at the folder picker already immersed in their chosen aesthetic.

**Screen layout:**
- Headline: "Choose your reading style"
- Four theme previews displayed as cards, each showing a short sample of article text rendered in that theme's actual colors and default font (New York)
- Selected theme has a visible active state (border or checkmark)
- Default selected: Paper
- CTA: "Continue" (always active — Paper is pre-selected)
- Secondary: "I'll decide later" (skips to folder setup, keeps Paper as default)

**Sample text for preview cards:**
A short, consistent excerpt that shows both heading and body text — approximately 2 lines of each — so the user can see the typeface and color in a realistic reading context.

---

## 9. Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.8 | 2026-05-01 | Added `Accent Surface` token to all four theme tables (§2.1–2.4): 15%-opacity tint of Accent, used as background behind accent-colored text elements. See `FIGMA_DESIGN_SYSTEM_REFERENCE.md` §1.4 for Figma implementation details. |
| 1.7 | 2026-04-22 | Added Related docs section and deference notices on §2, §3, §7, §8 pointing to DESIGN_TOKENS.md, THEMES.md, and COMPONENTS.md as authoritative sources for tokens and component mapping. |
| 1.6 | 2026-04-20 | Added Corner Radius Scale (§8) with four tokens: `radius/sm` 10pt, `radius/md` 12pt, `radius/lg` 18pt, `radius/pill` 20pt. Implemented as `Verso/Radius` variable collection in Figma. Also added `type/ui/input` text style (SF Pro Regular 17pt) for input field text. |
| 1.5 | 2026-04-20 | Added Accent Pressed token to all four themes (Paper `#584D40`, Sepia `#614429`, Night `#937F5E`, Ink `#5C779F`) — derived at 25% darker than Accent. Used for button and other interactive element pressed/active states. Added Placeholder token to all four themes (Paper `#CEC8BC`, Sepia `#C8BCA0`, Night `#302E2A`, Ink `#202630`) — for image placeholders and skeleton loading fills; positioned between Surface and Divider in each theme. |
| 1.4 | 2026-04-19 | Added semantic color tokens (Error, Warning, Success) for all four themes in new Section 2.5. Section numbering shifted: Accessibility note is now 2.6. |
| 1.3 | 2026-04-19 | Spacing scale revised to 8px base with Dynamic Type support (2× vertical rhythm). Added contextual spacing values for screen margins, content padding, filter chip gaps, and section separators. |
| 1.2 | 2026-04-19 | Accent tokens fixed in Paper and Sepia to pass WCAG AA on both Background and Surface. Paper: `#7B6B5A` → `#766655`. Sepia: `#8B6340` → `#825A37`. Decisions documented: Accent is used as link text (requires 4.5:1); reading bar controls are icon-only; VoiceOver overrides immersive mode auto-hide. |
| 1.1 | 2026-04-19 | Text Secondary tokens revised in all 4 themes to achieve WCAG AA (4.5:1) contrast on both Background and Surface. Paper: `#8C857D` → `#6E675F`. Sepia: `#8A7355` → `#755E40`. Night: `#8A847A` → `#8F897F`. Ink: `#7B818F` → `#7E8492`. |
| 1.0 | 2026-04-19 | Initial document. All foundations decided: 4 themes (Paper, Sepia, Night, Ink), 4 font choices (New York default, Georgia, SF, OpenDyslexic), line spacing and margin presets, immersive reading behavior, accessibility requirements. |
