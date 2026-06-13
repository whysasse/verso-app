> 🗄️ **ARCHIVED 2026-06-12.** Per-issue working document; issue complete. Kept for history; do not implement from this document.

# FAB-77 — Reading View Variants

**Linear:** https://linear.app/fabiosasseron/issue/FAB-77  
**Figma page:** "Reading view" — https://www.figma.com/design/WCPHZNg1my8VSSMbLO5bvX/Reader-UI  
**Status:** Complete — 17 screens

---

## Purpose

Reference set of 17 hi-fi Reading View screens showing the full matrix of visual variants: all 4 themes, all 6 font size presets, all 4 margin presets, immersive mode, and both Reading Controls bottom sheet variants. Used to validate the design system and inform SwiftUI implementation.

---

## Sample Article (used on all 14 screens)

- **Title:** The Architecture of Silence
- **Byline:** By Sarah Mitchell · April 15, 2026 · 5 min read
- **Body:** 3 paragraphs of reading prose (~300 words), no section headings

---

## Group A — Themes (4 screens)

Fixed defaults: body size **18pt (md)**, margin **40px Wide**, font **New York**.

| Frame name | Theme | Background | Text Primary |
|------------|-------|------------|--------------|
| Paper - Reading View \| Paper theme · 18pt · 40px | Paper | `#F5F0E8` | `#2C2924` |
| Sepia - Reading View \| Sepia theme · 18pt · 40px | Sepia | `#F2E8D5` | `#2E2013` |
| Night - Reading View \| Night theme · 18pt · 40px | Night | `#1C1A16` | `#E8E0D0` |
| Ink - Reading View \| Ink theme · 18pt · 40px     | Ink   | `#111418` | `#E4E6EB` |

---

## Group B — Font Size Variants (6 screens)

Fixed: Paper theme, Wide margin (40px), New York font. Line height multipliers from `Typography.swift`.

| Frame name | Size | pt | Line height |
|------------|------|----|-------------|
| Paper - XS Font Size \| 14pt · 1.75lh        | xs  | 14 | 1.75× |
| Paper - S Font Size \| 16pt · 1.75lh         | sm  | 16 | 1.75× |
| Paper - M (Default) Font Size \| 18pt · 1.75lh | md | 18 | 1.75× |
| Paper - L Font Size \| 20pt · 1.75lh         | lg  | 20 | 1.75× |
| Paper - XL Font Size \| 22pt · 1.6lh         | xl  | 22 | 1.6×  |
| Paper - XXL Font Size \| 26pt · 1.5lh        | xxl | 26 | 1.5×  |

Source: `Verso/Sources/Design/Typography.swift` — `VersoTypography.Reading.BodySize`

---

## Group C — Margin Variants (4 screens)

Fixed: Paper theme, md body size (18pt), New York font.

| Frame name | Label | Horizontal padding |
|------------|-------|--------------------|
| Paper - Narrow Margin \| 16px padding       | Compact    | 16px each side |
| Paper - Normal Margin \| 24px padding       | Normal     | 24px each side |
| Paper - Wide (Default) Margin \| 40px padding | Wide     | 40px each side |
| Paper - Extra Wide Margin \| 56px padding   | Extra Wide | 56px each side |

Source: `docs/DESIGN_SYSTEM_FOUNDATIONS.md` §4.2

---

## Group D — Reading Controls & Immersive Mode (3 screens)

Paper theme only. These screens show interactive states layered over the standard reading view.

| Frame name | What it shows |
|------------|---------------|
| Paper - Immersive Mode | Full-screen article, chrome hidden, `ImmersiveHintPill` ("Tap anywhere to reveal") centered ~100pt above bottom safe area |
| Paper - Reading Controls - Type | Font Size stepper + Line Spacing segmented tiles bottom sheet open over article |
| Paper - Reading Controls - Theme | Theme swatch picker (Paper · Sepia · Night · Ink) bottom sheet open over article |

---

## Notes

- The navigation bar top bar includes an ↗ open-externally icon in the top-right. This is present in all Reading View frames and does not respond to the user's margin setting — intentional.

---

## Related Files

| File | Role |
|------|------|
| `Verso/Sources/Design/Colors.swift` | Theme colour values |
| `Verso/Sources/Design/Typography.swift` | BodySize enum + line height multipliers |
| `docs/DESIGN_SYSTEM_FOUNDATIONS.md` §4.2 | Margin preset values |
| `docs/DESIGN_TOKENS.md` | Authoritative token values |
| `docs/THEMES.md` | Theme intent and personality |
