# Accessibility Specs & Checklist — Verso

**Version:** 1.3
**Date:** 2026-09-06
**Status:** Final — all decisions resolved, ready for Figma handoff and development. Contrast enforcement moved to `scripts/check_contrast.py` (see §3.3).
**Related:** FAB-67 · [Design System Foundations](DESIGN_SYSTEM_FOUNDATIONS.md)

---

## 1. Purpose

This document defines Verso's non-negotiable accessibility requirements. It is a design-time reference, not a post-launch audit. Every requirement here must be met before a screen is considered ready for development.

Accessibility is treated as a first-class design constraint, not an afterthought. Where a design decision conflicts with an accessibility requirement, the accessibility requirement wins.

---

## 2. Touch Targets

### 2.1 Minimum size

All interactive elements must meet a **minimum touch target of 44×44pt**, per Apple's Human Interface Guidelines and WCAG 2.5.5 (AAA target, but treated as mandatory here).

This applies to every tappable element in the app — buttons, icons, toggles, list rows, and inline controls.

| Element | Visual size | Tap area | Notes |
|---------|------------|----------|-------|
| Bottom bar icon buttons (font −/+, spacing, margin, theme, mark read) | 24pt icon | 44×44pt | Invisible tap area extends beyond visual icon |
| Top bar back button | 28pt icon | 44×44pt | |
| Reading list rows | Full width × variable height | Min 44pt height | List rows are inherently wide; height is the constraint |
| Theme chips (Reading View) | ~36×36pt visual | 44×44pt | Use padding or `contentEdgeInsets` to extend |
| Onboarding theme cards | Large card | Already exceeds 44pt | No action needed |
| Settings rows | Full width × 44pt | Meets by default (UITableViewCell) | Verify custom cells |
| Font size stepper (− / +) | 28pt each | 44×44pt each | Both buttons must independently meet the minimum |

### 2.2 Spacing between targets

Adjacent touch targets must have at least **8pt of non-interactive space** between them to prevent mis-taps. In the bottom reading bar where controls are dense, use `contentEdgeInsets` rather than reducing the visual size of icons.

---

## 3. Color Contrast

### 3.1 Targets

| Text type | Minimum ratio | WCAG criterion |
|-----------|--------------|----------------|
| Body text, UI labels (normal size, < 18pt regular / < 14pt bold) | **4.5:1** | AA 1.4.3 |
| Large text (≥ 18pt regular or ≥ 14pt bold) | **3:1** | AA 1.4.3 |
| UI component borders, icons, focus indicators | **3:1** | AA 1.4.11 (Non-text Contrast) |

Verso targets **WCAG AA** for all text pairs. AA Enhanced (AAA, 7:1) is not required but is noted where it is naturally achieved.

### 3.2 Verified contrast ratios — all themes

Ratios are calculated against WCAG 2.1 relative luminance formula. ✅ = passes required threshold. ❌ = fails and requires a color fix before handoff.

Context for Text Secondary: used at 15pt Regular (list subtitles) and 13pt Regular (captions) — both are **normal text**, requiring 4.5:1.

Context for Accent: used for interactive elements (buttons, links, active states). As a text element (links), requires 4.5:1. As a non-text UI component, requires 3:1.

#### Paper (`#F5F0E8` bg / `#EDE8DF` surface)

| Pair | Ratio | Normal text | Large text | Notes |
|------|-------|-------------|------------|-------|
| Text Primary (`#2C2924`) on Background | 12.77:1 | ✅ | ✅ | |
| Text Primary on Surface | 11.87:1 | ✅ | ✅ | |
| Text Secondary (`#6E675F`) on Background | 4.91:1 | ✅ | ✅ | Fixed from `#8C857D` (was 3.21:1) |
| Text Secondary on Surface | 4.57:1 | ✅ | ✅ | Fixed from 2.98:1 |
| Accent (`#766655`) on Background | 4.87:1 | ✅ | ✅ | Fixed from `#7B6B5A` (surface was 4.20:1) |
| Accent on Surface | 4.53:1 | ✅ | ✅ | Fixed from 4.20:1 |

#### Sepia (`#F2E8D5` bg / `#E8DEC7` surface)

| Pair | Ratio | Normal text | Large text | Notes |
|------|-------|-------------|------------|-------|
| Text Primary (`#2E2013`) on Background | 12.97:1 | ✅ | ✅ | |
| Text Primary on Surface | 11.79:1 | ✅ | ✅ | |
| Text Secondary (`#755E40`) on Background | 5.04:1 | ✅ | ✅ | Fixed from `#8A7355` (was 3.70:1) |
| Text Secondary on Surface | 4.58:1 | ✅ | ✅ | Fixed from 3.37:1 |
| Accent (`#825A37`) on Background | 4.98:1 | ✅ | ✅ | Fixed from `#8B6340` (was 4.37:1 / 3.97:1) |
| Accent on Surface | 4.53:1 | ✅ | ✅ | Fixed from 3.97:1 |

#### Night (`#1C1A16` bg / `#252320` surface)

| Pair | Ratio | Normal text | Large text | Notes |
|------|-------|-------------|------------|-------|
| Text Primary (`#E8E0D0`) on Background | 13.24:1 | ✅ | ✅ | |
| Text Primary on Surface | 11.94:1 | ✅ | ✅ | |
| Text Secondary (`#8F897F`) on Background | 5.01:1 | ✅ | ✅ | Fixed from `#8A847A` (surface was 4.23:1) |
| Text Secondary on Surface | 4.52:1 | ✅ | ✅ | Fixed from 4.23:1 |
| Accent (`#C4A97D`) on Background | 7.71:1 | ✅ | ✅ | |
| Accent on Surface | 6.95:1 | ✅ | ✅ | |

#### Ink (`#111418` bg / `#181C22` surface)

| Pair | Ratio | Normal text | Large text | Notes |
|------|-------|-------------|------------|-------|
| Text Primary (`#E4E6EB`) on Background | 14.79:1 | ✅ | ✅ | |
| Text Primary on Surface | 13.69:1 | ✅ | ✅ | |
| Text Secondary (`#7E8492`) on Background | 4.93:1 | ✅ | ✅ | Fixed from `#7B818F` (surface was 4.38:1) |
| Text Secondary on Surface | 4.56:1 | ✅ | ✅ | Fixed from 4.38:1 |
| Accent (`#7B9FD4`) on Background | 6.82:1 | ✅ | ✅ | |
| Accent on Surface | 6.31:1 | ✅ | ✅ | |

### 3.3 Remaining color issues

Text Secondary has been resolved in all themes (see tables above).

**Superseded 2026-09-06 (FAB-314).** This section previously read *"All color
issues are resolved. No remaining failures"* — true only for the 6 pairs this
table happens to audit (Text Primary/Secondary/Accent against
Background/Surface). It never checked what the rest of `Colors.swift`'s
tokens do in combination, and a critique pass later found several pairs
outside that set — some already fixed since (badge icons, swipe-action
tints, and `border` — all FAB-325, 2026-09-05), some still open.

Contrast is now enforced by **`scripts/check_contrast.py`** in CI (the
`contrast-check` job in `.github/workflows/ci.yml`), computed directly from
`Verso/Shared/Colors.swift`'s real hex values rather than hand-maintained
here — this table stays as historical record of the original 24-pair audit,
but is no longer the source of truth for whether contrast passes.

Two pairs the script checks are genuine, currently-failing debt, tracked as
**FAB-336**:

- `placeholder` vs `surface` (SearchBar's clear icon) — 1.12–1.55:1 across
  the 4 themes, needs 3:1 non-text.
- `error` (SemanticColors) vs `surface` (VersoTextField's inline error
  caption, 13pt) — 4.46:1 (Paper) / 4.07:1 (Sepia), needs 4.5:1. Night and
  Ink already pass.

Two tokens the critique also flagged, `accentPressed` and `warning`, are
**not** checked and not tracked as failures: neither is used anywhere in
shipped UI today (`accentPressed` only appears in the dev-only
`DesignSystemPreview.swift`; `warning` doesn't appear in any SwiftUI view at
all) — their contrast numbers are real but nothing on screen exercises them,
so there's no live accessibility bug to fix. `scripts/check_contrast.py`
picks up either token automatically the day something actually renders with
it.

| Theme | Token | Old value | New value | Status |
|-------|-------|-----------|-----------|--------|
| Paper | Text Secondary | `#8C857D` | `#6E675F` | ✅ Fixed |
| Sepia | Text Secondary | `#8A7355` | `#755E40` | ✅ Fixed |
| Night | Text Secondary | `#8A847A` | `#8F897F` | ✅ Fixed |
| Ink | Text Secondary | `#7B818F` | `#7E8492` | ✅ Fixed |
| Paper | Accent | `#7B6B5A` | `#766655` | ✅ Fixed — Accent is used as link text, requires 4.5:1 |
| Sepia | Accent | `#8B6340` | `#825A37` | ✅ Fixed — Accent is used as link text, requires 4.5:1 |

### 3.4 Never communicate information through color alone

Color must never be the only way to convey meaning. Examples:
- A "Mark as read" state must use a label, icon, or position change in addition to a color change.
- Error states must include text or an icon alongside any red color.
- The active theme chip in the theme picker must use a checkmark or border in addition to the highlighted color.

---

## 4. Font Scaling Rules (Dynamic Type)

### 4.1 Requirement

The app must respect the user's iOS system font size setting (Settings → Accessibility → Display & Text Size → Larger Text). This is mandatory, not optional.

### 4.2 Reading View — font size behavior

The Reading View has its own 6-step size scale (XS → XXL). This scale is the user's explicit in-app preference and takes priority in the reading context. Dynamic Type applies *additively* on top of the base scale.

Implementation rule: map each step to the corresponding `UIFont.TextStyle` so that the OS accessibility multiplier is preserved. A user at "Accessibility Extra Large" and in-app "M" should see a larger result than a user at standard system size and in-app "M".

| In-app label | Base size | UIFont.TextStyle mapping |
|-------------|-----------|--------------------------|
| XS | 14pt | `.footnote` |
| S | 16pt | `.callout` |
| M (default) | 18pt | `.body` |
| L | 20pt | `.title3` |
| XL | 22pt | `.title2` |
| XXL | 26pt | `.title1` |

### 4.3 UI typography (outside Reading View)

All UI text (list screens, settings, navigation) uses San Francisco at system sizes and must scale automatically with Dynamic Type. Use `UIFont.preferredFont(forTextStyle:)` — never hard-coded point sizes.

| Element | TextStyle |
|---------|-----------|
| Screen title | `.largeTitle` |
| List item title | `.headline` |
| List item subtitle | `.subheadline` |
| Button label | `.headline` |
| Caption / metadata | `.caption1` |

### 4.4 Layout must accommodate scaling

Layouts must not clip, overlap, or truncate text at any Dynamic Type size up to **Accessibility Extra Large (XXXL)**. Specific rules:

- **Labels in the bottom reading bar** must not clip at large sizes. If labels are hidden (icon-only bar), this is not a concern — confirm final design.
- **Article list rows** must expand in height to accommodate larger text; never fixed-height cells with truncated subtitles.
- **Onboarding screens** must reflow gracefully at large sizes. Test on iPhone SE (smallest screen) at max Dynamic Type.
- **Avoid single-line forced layouts** for any user-facing text. Use `numberOfLines = 0` and let the layout expand.

### 4.5 OpenDyslexic

When the user selects OpenDyslexic as their reading font, the app loads the bundled OpenDyslexic font files and the Dynamic Type multiplier still applies. OpenDyslexic does not have a weight axis — map weights as follows:

| App weight need | OpenDyslexic file |
|----------------|------------------|
| Regular / Medium | OpenDyslexic-Regular |
| Semibold / Bold | OpenDyslexic-Bold |

---

## 5. Focus States & VoiceOver

### 5.1 VoiceOver labeling requirements

Every interactive element must have a descriptive `accessibilityLabel`. The default label (derived from title or icon name) is almost never sufficient for icon buttons.

| Element | Required accessibility label | Hint (if needed) |
|---------|-----------------------------|--------------------|
| Bottom bar font decrease | "Decrease font size" | — |
| Bottom bar font increase | "Increase font size" | — |
| Bottom bar line spacing | "Line spacing" | "Double tap to open spacing options" |
| Bottom bar margins | "Margins" | "Double tap to open margin options" |
| Bottom bar theme | "Theme" | "Double tap to open theme options" |
| Bottom bar mark as read | "Mark as read" / "Mark as unread" (toggled dynamically) | — |
| Top bar back button | "Back to Reading List" | — |
| Reading list article row | "[Article title], [source], [estimated read time]" | "Double tap to open" |
| Theme chips (onboarding & reading bar) | "[Theme name] theme" | "Double tap to select" |
| Font size stepper options | "[XS/S/M/L/XL/XXL] font size" | — |

### 5.2 Reading View content

Article content in the Reading View must be presented as a continuous readable flow, not as a grid of individual elements. Use appropriate `accessibilityTraits` and group related elements.

- The article body renders as a `WKWebView` or `UITextView` — VoiceOver will read it sequentially, which is correct.
- The article title in the top bar should be `accessibilityHidden = true` when the full article is visible (it's redundant — VoiceOver will encounter the title as the first element in the article body).
- Progress indicators (reading time remaining) must be labeled: "Approximately [N] minutes remaining".

### 5.3 Immersive mode and VoiceOver

**Decision:** When VoiceOver is active, the chrome must remain visible at all times. The 2-second auto-hide behavior is suppressed whenever `UIAccessibility.isVoiceOverRunning` returns `true`.

Implementation spec for developers:
- Check `UIAccessibility.isVoiceOverRunning` before starting the auto-hide timer. If true, skip the timer entirely and keep chrome visible.
- Register for `UIAccessibility.voiceOverStatusDidChangeNotification` to respond dynamically if the user toggles VoiceOver mid-session.
- Set `isHidden = false` and control chrome visibility via `alpha` only — never `isHidden = true`, which removes elements from the accessibility tree entirely.
- The chrome should still respond to tap-to-toggle while VoiceOver is active, but should never auto-hide.

**First-use hint suppression:** The "Tap anywhere to reveal" hint pill (shown once on first auto-hide) must never appear when VoiceOver is active. Because auto-hide is suppressed, the hint condition is never met — no special handling is required beyond the timer suppression above. Additionally, the `hasShownImmersiveHint` UserDefaults flag must **not** be written during a VoiceOver session. Gate the flag write on `!UIAccessibility.isVoiceOverRunning`, so that a user who first opens the app with VoiceOver on will still see the hint on their first non-VoiceOver session.

### 5.4 Focus order

VoiceOver focus order must follow a logical reading order. In the Reading View:

1. Top bar: Back button → Article title
2. Article body (sequential)
3. Bottom bar: Font − → Font + → Line spacing → Margins → Theme → Mark as read

Verify focus order after any layout change. SwiftUI and UIKit handle this differently — confirm with the developer.

### 5.4b Reading bar layout at large Dynamic Type sizes

**Decision:** Reading bar controls are icon-only — no text labels — at all Dynamic Type sizes. This means Dynamic Type scaling does not affect the reading bar layout and no scrollable treatment is needed. Icon size remains fixed at 24pt regardless of system font size.

All icons must have VoiceOver labels (see Section 5.1) to compensate for the absence of visible text labels.

### 5.5 Keyboard and Switch Control

For users on Switch Control or external keyboards:

- All interactive elements must be reachable without custom gestures.
- The immersive mode tap-to-reveal gesture must have a keyboard/switch equivalent. A single switch scan of the screen (which triggers a tap) should reveal the chrome.
- No critical action may require a swipe gesture as its only trigger.

---

## 6. iOS System Accessibility Settings

The following iOS accessibility settings must be respected. Each must be tested as part of QA.

| Setting | Verso behavior |
|---------|---------------|
| **Larger Text** (Display & Text Size) | All text scales via Dynamic Type. See Section 4. |
| **Bold Text** | SF system fonts will automatically bold. Reading fonts (New York, Georgia, OpenDyslexic) do not change — this is acceptable, as the reading font is a user-chosen preference. |
| **Button Shapes** | Tappable elements with text labels should acquire an underline or border when this setting is on. Verify bottom bar icon buttons — they may need explicit shape treatment since they have no text labels. |
| **Increase Contrast** | Check all themes. Text Secondary passes its 4.5:1 floor everywhere already (fixed v1.1, see §3.2), but with the least headroom of the audited pairs (~2%) — Increase Contrast mode is the setting most likely to expose that fragility if a token value ever nudges. |
| **Reduce Transparency** | Any blurred or translucent surfaces must become opaque. If the reading bars use blur effects, they must fall back to a solid color. |
| **Reduce Motion** | Respect `UIAccessibility.isReduceMotionEnabled`. The immersive mode fade animations (300ms/200ms, Section 5 of Design System Foundations) must be disabled or replaced with an instant show/hide. |
| **Differentiate Without Color** | No information should rely solely on color. See Section 3.4. |
| **On/Off Labels** | Toggle switches in Settings should show I/O labels when this is enabled. Use standard `UISwitch` — it handles this automatically. |

---

## 7. QA Accessibility Checklist

Use this checklist for every screen before marking a feature as done. Check each item on a real device, not the simulator.

### 7.1 Touch targets

- [ ] Every interactive element is at least 44×44pt (use Xcode's Accessibility Inspector to verify)
- [ ] No two adjacent touch targets overlap
- [ ] Minimum 8pt separation between adjacent targets

### 7.2 Color contrast

- [ ] Text Primary on Background passes 4.5:1 in all 4 themes
- [ ] Text Primary on Surface passes 4.5:1 in all 4 themes
- [ ] Text Secondary on Background passes 4.5:1 in all 4 themes *(fixed v1.1 — `scripts/check_contrast.py` covers this in CI now, see §3.3)*
- [ ] Text Secondary on Surface passes 4.5:1 in all 4 themes *(fixed v1.1 — same)*
- [ ] Accent on Background passes 4.5:1 where used as text, 3:1 where used as UI component
- [ ] No information conveyed by color alone

### 7.3 Dynamic Type

- [ ] All UI text (outside Reading View) scales with Dynamic Type
- [ ] Reading View text scales correctly at all 6 in-app size steps
- [ ] No text clips, overlaps, or truncates at Accessibility Extra Large
- [ ] Tested on smallest supported device (iPhone SE) at max Dynamic Type
- [ ] OpenDyslexic font scales correctly with Dynamic Type

### 7.4 VoiceOver

- [ ] Enable VoiceOver and navigate the full screen without visual reference
- [ ] Every interactive element announces a meaningful label
- [ ] Focus order is logical (top-to-bottom, left-to-right)
- [ ] Article content reads as a continuous flow
- [ ] Immersive mode chrome is accessible when visually hidden
- [ ] Dynamic labels (e.g., "Mark as read" ↔ "Mark as unread") update correctly

### 7.5 iOS system settings

- [ ] Bold Text: verify UI text appears bold
- [ ] Button Shapes: verify interactive elements are visually identifiable
- [ ] Increase Contrast: verify contrast improves (or at minimum does not worsen)
- [ ] Reduce Transparency: verify any blurred surfaces become opaque
- [ ] Reduce Motion: verify immersive fade animations are disabled
- [ ] Switch Control: verify all controls are reachable by scanning

### 7.6 Orientation and layout

- [ ] All screens function in both portrait and landscape
- [ ] No content is cut off or inaccessible in either orientation
- [ ] iPad layouts respect the 680px max content width (reading view)

---

## 8. Design Decisions Log

All open questions resolved. No outstanding items.

| # | Question | Decision | Documented in |
|---|----------|----------|--------------|
| 1 | Text Secondary contrast failures | Darken tokens to minimum compliant values, preserving hue by shifting RGB uniformly | Section 3.2–3.3; Design System v1.1 |
| 2 | Accent as link text | Confirmed: Accent is used for inline links in articles. Accent tokens fixed in Paper and Sepia to pass 4.5:1. | Section 3.2–3.3; Design System v1.2 |
| 3 | Bottom bar at Accessibility Extra Large | Reading bar controls are icon-only at all sizes. No scrollable treatment needed. Fixed 24pt icon size regardless of Dynamic Type. | Section 5.4b |
| 4 | Immersive mode auto-hide with VoiceOver active | VoiceOver overrides auto-hide: chrome stays visible whenever `UIAccessibility.isVoiceOverRunning` is true. App listens for `voiceOverStatusDidChangeNotification` to respond dynamically. | Section 5.3 |

---

## 9. Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.3 | 2026-09-06 | FAB-314: corrected §3.3's "no remaining failures" claim, which only ever covered the 6 pairs in §3.2. Contrast is now enforced by `scripts/check_contrast.py` in CI, computed from `Colors.swift` directly; §3.2's tables stay as historical record only. 2 genuine open failures tracked as FAB-336. |
| 1.2 | 2026-04-19 | Accent tokens fixed in Paper (`#7B6B5A` → `#766655`) and Sepia (`#8B6340` → `#825A37`). All 3 open design questions resolved and documented in Section 8. Status updated to Final. |
| 1.1 | 2026-04-19 | Text Secondary tokens fixed in all 4 themes. Paper: `#8C857D` → `#6E675F`. Sepia: `#8A7355` → `#755E40`. Night: `#8A847A` → `#8F897F`. Ink: `#7B818F` → `#7E8492`. All Text Secondary pairs now pass WCAG AA. |
| 1.0 | 2026-04-19 | Initial spec. Contrast ratios computed for all 4 themes. Failures documented with remediation guidance. Touch targets, Dynamic Type mapping, VoiceOver labels, iOS system settings, and QA checklist defined. |
