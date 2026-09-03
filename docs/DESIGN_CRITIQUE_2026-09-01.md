# Design Critique — Verso iOS (onboarding · list · reader · settings)

**Date:** 2026-09-01
**Reviewer:** Claude (Cowork), at Fabio's request
**Stage assumed:** pre-1.0 polish — find what's wrong before it ships, not restructure
**Related:** [accessibility-specs.md](accessibility-specs.md) · [DESIGN_TOKENS.md](DESIGN_TOKENS.md) · [BACKLOG.md](BACKLOG.md)

---

## 1. Method and its limits

**What this is based on.** A full read of the SwiftUI source for the four screens and every component they use, plus contrast ratios computed numerically (WCAG 2.1 relative luminance) from the hex values in `Colors.swift` — not eyeballed. Every ratio quoted below is calculated, and the arithmetic is reproducible from the tokens.

**Four passes.** The first was source-only. The second used 20 iPhone 17 Pro captures (`docs/printscreens/design-review-2026-09-01/`) — the list in five states, Add Article in four, the Share Extension in two, the reader in five, Settings in two, all in Paper or Sepia at default text size. The third and fourth added 36 more captures in the same folder (`docs/printscreens/design-review-2026-09-03/`): the **Ink and Night themes**, the **full onboarding flow**, **immersive mode**, a **large system-text-size pass**, and an **iPhone SE (375×667pt)** pass. Every theme, every screen in scope, and both size dimensions have now been seen at least once.

The App Store captures in `docs/printscreens/app-store-2026-08/` are an older build and **nothing here rests on them.**

**The visual passes overturned three predictions**, all corrected in place below:

- **OpenDyslexic does load.** §7.3 predicted it was silently falling back to the system font. It isn't — it renders correctly. Only the missing Bold face survives, and the Ink pass made that one sharper: the article *H1* falls back to system bold while the body renders in OpenDyslexic.
- **Add Article does not strand the user.** A success state with no close button looked like a trap; there's a 1.5s auto-dismiss. Downgraded to a smaller, real problem (§5.8).
- **System menus do not break the theme.** §6.11 predicted a bright white panel over the dark themes. In Ink the overflow menu renders in the dark system material and reads correctly, because `ContentView`'s `.preferredColorScheme` drives it. Withdrawn — and it is the second reason not to remove that modifier while fixing the theme-switch bug (FAB-304).

Two findings were softened: article cards read more clearly than 1.08:1 suggests (§5.5), and the Settings dividers do real work (§3.12).

**Four new bugs came out of the Ink pass**, filed as FAB-330–333: the Continue Reading caption reads "0 read" rather than "0% read" (§5.12); articles at 0% progress fill that section (§5.13); a CNN share bar and the " | CNN" title suffix survive into the reader (§6.13); and the reading measure collapses to 25–30 characters with OpenDyslexic or at the largest in-app size (§6.14).

**A fourth prediction was overturned, and it is the important one.** §3.5 originally said `Font.system(size:)` scales with Dynamic Type and therefore the app's literal font sizes were a nuance rather than a defect. Large-text screenshots show the opposite: **nothing built from `VersoTypography` scales at all.** That reframes the finding from "audit for truncation" to "the app does not support Dynamic Type", and it is now the largest single item in this critique (FAB-309). One finding also looks refuted in the other direction — §6.1's claim that immersive mode gains no space at the top — see the note there.

**The three predictions that mattered most were all confirmed**, in the theme where they actually bite: the white-on-accent failure (§3.1) is plainly visible on Ink's `+` button and every CTA, the onboarding theme-card labels (§4.2) are visibly muddy, and the swipe-action tints (§3.9) render as a warm brown and a warm green against Ink's cool near-black.

Everything in this document is now filed in [BACKLOG.md](BACKLOG.md) as **FAB-304 through FAB-333**; §10's ranking maps to those issues.

Findings are marked `[code]` (read from source), `[computed]` (arithmetic on the tokens, certain), `[seen]` (confirmed in a current screenshot) or `[verify]` (still needs a device). §8 is what's left unverified — much shorter than it was.

**Not covered:** the Share Extension, AddArticleView, ImportView, AboutView, tags editor, related-articles section, iPad, and Web.

---

## 2. Overall impression

**The reading view is where the care went, and it shows in the source.** A ~313pt measure on a standard iPhone, a 1.75 line-height multiplier, New York at 18pt on `#F5F0E8`, `textPrimary` at 12.77:1 — those are the right numbers, chosen deliberately. Judging whether it *reads* as well as it specifies needs eyes on a current build.

Everything around it is weaker on paper, and the weakness has one shape: **the design system is defined well and applied inconsistently.** `docs/accessibility-specs.md` is a genuinely rigorous document — 44pt targets, contrast tables, Dynamic Type mappings, VoiceOver labels, all decided and signed off. The implementation then diverges from it in a dozen specific, fixable places. The gap is not judgment; it's drift. That is good news: almost everything below is a small, local fix, and several fixes already exist elsewhere in your own codebase.

The single most consequential finding is §3.1 — **white text on the accent colour fails contrast in both dark themes**, which means every primary button in Night and Ink is hard to read. You already solved it correctly once, in `FolderPickerPrompt`.

---

## 3. Cross-cutting findings

These are not screen-specific; they show up everywhere and are worth fixing once at the component level.

### 3.1 🔴 White-on-accent fails WCAG AA in Night and Ink `[computed]`

`VersoButtonStyle.primary` hardcodes `.foregroundColor(.white)` on a `theme.accent` fill. Accent is light in the dark themes:

| Theme | Accent | White label | Verdict (needs 4.5:1 at 17pt semibold) |
|---|---|---|---|
| Paper | `#766655` | 5.52:1 | ✅ |
| Sepia | `#825A37` | 6.06:1 | ✅ |
| **Night** | `#C4A97D` | **2.25:1** | ❌ fails AA, and fails even the 3:1 non-text floor |
| **Ink** | `#7B9FD4` | **2.71:1** | ❌ fails AA |

This is not one button. The same white-on-accent pattern appears in:

- every `.primary` button (all four onboarding CTAs, and every other primary action)
- the `+` add-article glyph in the list header (32pt accent circle, white `plus`)
- the active-filter count badge in the list header (11pt **bold** white on an accent capsule — the worst case on the screen)

**Fix — you already wrote it.** `FolderPickerPrompt` uses `.foregroundColor(themeManager.colors.background)` on its accent pill instead of `.white`. That inverts correctly per theme:

| Theme | `background` on `accent` |
|---|---|
| Paper | 4.87:1 ✅ |
| Sepia | 4.98:1 ✅ |
| Night | 7.71:1 ✅ |
| Ink | 6.82:1 ✅ |

Change `VersoButtonStyle.primary`, the add-glyph, and the filter badge to `theme.background`. One-line each, passes in all four themes, and it makes `FolderPickerPrompt` stop being the odd one out.

### 3.2 🔴 `accessibility-specs.md` says "no remaining failures" — it audited three token pairs out of many `[computed]`

§3.3 of that doc concludes *"All color issues are resolved. No remaining failures."* It checked `textPrimary`, `textSecondary` and `accent` against `background`/`surface`. It never checked what those tokens do in combination with each other, or the tokens outside that set. Unchecked and failing:

| Pair | Where | Ratio | Required |
|---|---|---|---|
| white glyph on `reading` badge `#D4A353` | Article card | **2.29:1** | 3:1 (icon) |
| white glyph on `read` badge `#5AAF7A` | Article card | **2.68:1** | 3:1 (icon) |
| white glyph on `unread` badge `#4A90D9` | Article card | 3.34:1 | 3:1 — passes, barely |
| `placeholder` on `surface` | Search clear button | **1.12–1.55:1** | 3:1 (control) |
| `border` on `background` | Text-field outlines, dividers, progress track | **1.16–1.33:1** | 3:1 where it bounds a control |
| `warning` on `background` (Paper / Sepia) | Semantic | **4.43 / 4.13:1** | 4.5:1 |
| `error` on `surface` (Paper / Sepia) | Field error text, 13pt | **4.46 / 4.07:1** | 4.5:1 |
| `accentPressed` on `background` (Ink) | Pressed states | **4.04:1** | 4.5:1 if used as text |
| white on swipe-action tint `#5AAF7A` / `#4A90D9` | List swipe actions | **2.68 / 3.34:1** | 4.5:1 |

Also worth knowing: `textSecondary` passes, but with **~2% headroom** (4.52–4.58:1 on `surface`). Any future nudge to a surface value breaks it silently. That's not a bug, it's a fragility — worth a note in the token doc.

**Recommendation:** replace §3.2's hand-maintained tables with a script that walks `Colors.swift` and asserts every *used* pair, run in CI. The doc's current claim is stronger than its evidence, and that's the part that's actually dangerous — it reads as "done".

### 3.3 🟡 The theme picker is implemented three separate times, three different ways `[code]`

| Where | Component | Swatch | Label size | Label colour source |
|---|---|---|---|---|
| Onboarding | `ThemePreviewCard` | 120pt card with fake text lines | 13pt | **that card's own theme** |
| Settings | `ThemeChip` | 32pt flat rectangle, fixed 80×100 frame | 11pt | current theme |
| Reading controls | `ThemeChipView` | 32pt flat rectangle, no fixed frame | 11pt | current theme |

Three implementations, three visual languages for one choice, and the swatch hex values are **copy-pasted literals** in two of them (`Color(hex: "F5F0E8")` etc.) rather than read from `ThemeColors.colors(for:)`. This is exactly the class of duplication a design system exists to prevent, and it has already produced a real bug (§4.2).

**Recommendation:** one `ThemeSwatch` component, size as a parameter, swatch colours always from `ThemeColors.colors(for: theme)`. The onboarding treatment (a miniature page with type on it) is the best of the three — it's the only one where Night and Ink are distinguishable (§6.2).

### 3.4 🟠 Touch targets below 44×44, against your own spec `[code]`

`accessibility-specs.md` §2.1 calls 44×44pt "mandatory" and even names the font stepper explicitly. Current violations:

| Control | Actual | Location |
|---|---|---|
| Reader font size `A` − / `A` + | ~**14×17** and ~**20×24** — bare `Text("A")`, no frame | `ReadingControls.fontControls` |
| Settings font size − / + | **32×32** | `SettingsView.readingSection` |
| Reader line-spacing buttons | 44×**36** | `ReadingControls.fontControls` |
| Onboarding "Skip" | ~**36×22** — bare text, `.buttonStyle(.plain)`, no padding | `QuickTourView.skipButton` |
| Search-bar clear `✕` | default symbol size, no frame | `SearchBar` |

The reader font stepper is the worst of these: it's the most-used control in the app's most-used screen, it's named in the spec as needing 44×44 each, and it currently has neither.

Separately, §2.2 requires 8pt of dead space between adjacent targets. The list header packs four 44pt buttons at `HStack(spacing: 2)` — **2pt apart**. Visually they look separated (the glyphs are 18pt inside 44pt frames) but the *tap* areas are nearly touching, which is precisely the mis-tap case the rule exists for.

### 3.5 🔴 The app ignores the system text size entirely `[seen]` → FAB-309

**Correction.** Earlier versions of this section said SwiftUI's `Font.system(size:)` *does* scale with Dynamic Type, and concluded "this is not 'Dynamic Type is broken'". **That was wrong, and it downgraded the most serious finding in this document.** `Font.system(size:)` is a fixed-size font and does not scale; the text styles (`.body`, `.headline`, …) do. `Font.custom(_:size:)` *does* scale relative to body by default since iOS 14.

Large-text screenshots on 2026-09-03, against a default-size control in the same theme, show exactly what that predicts. In Settings, every label built from `VersoTypography` — "GENERAL", "Language", "Automatic", "English", "Français (Canada)", "Português (Brasil)", "READING", "Font" — is pixel-identical at both sizes. The entire article list is identical too, while the system menu drawn on top of it is three times bigger.

The **only** things that grow are the font-picker rows, because they use `.custom(name, size:)` — and they grow badly: "OpenDyslexic" wraps mid-word to "OpenDysle / xic" and overflows its row; the Georgia and New York previews truncate to "The quick brown…".

Every token in `VersoTypography.UI` is a bare literal: `screenTitle` 34, `listTitle` 17, `listSubtitle` 15, `button` 17, `caption` 13, `input` 17. Several views hardcode sizes outside the tokens as well — `EmptyState` (20/15pt), `ArticleHeader` (15/13pt), `ThemeChip` (11pt), `ReadingTopBar` title (17pt), the filter badge (11pt).

`SettingsRow.fontRow` happens to contain its own control group, which makes this verifiable in one screenshot:

```swift
.font(name.isEmpty ? .system(size: 17, weight: .semibold) : .custom(name, size: 17).weight(.semibold))
```

Georgia, New York and OpenDyslexic take the `.custom` branch and scale; the "System" row takes `.system(size:)` and won't.

[accessibility-specs.md](accessibility-specs.md) §4.1 calls Dynamic Type "mandatory, not optional" and §4.3 prescribes the exact text-style mapping that was never implemented. For a reading app, readers who enlarge system text are close to the core audience.

The layout consequences the earlier draft listed are still real, but they are downstream: `.lineLimit(1)` on `SettingsRow.folderRow`, `fontRow`'s preview, `ArticleCard`'s source, `ReadingTopBar`'s title and `FilterPanel`'s tag rows; fixed frames on `ThemeChip` (80×100) and the reader's sheet detents (218/168); and fixed decorations like the 8pt selection dots, which stay 8pt while their labels triple. Fix the tokens first, then audit the layouts — otherwise you are fixing clipping in views that never move.

### 3.6 🟠 The reading chrome ships English-only accessibility labels `[code]`

After a full localization epic (FAB-275, FAB-284), `ReadingChrome.swift` still has seven hardcoded English strings:

```
"Back" · "Returns to the article list"
"Font and spacing" · "Adjust reading font size and line spacing"
"Listen to article" / "Stop listening" · "Reads the article aloud"
"Reading theme" · "Change paper, sepia, night, or ink theme"
```

Plus `SearchBar`'s default `placeholder: String = "Search titles..."` — currently every caller passes an `L10n` string, so it doesn't ship today, but it's a loaded gun for the next caller.

A French or Portuguese user running VoiceOver gets an English reading toolbar. Everything else in that file goes through `L10n`, so this is oversight, not decision.

### 3.7 🟠 Three VoiceOver decisions from the spec were never implemented `[code]`

`UIAccessibility.isVoiceOverRunning` **does not appear anywhere in the codebase.** Neither does `reduceTransparency` or `differentiateWithoutColor`. `accessibilityReduceMotion` appears exactly once (correctly, in the reader's immersive toggle).

Spec §5.3 decided, and logged in §8 as resolved:

- chrome must not auto-hide while VoiceOver is running
- the app must observe `voiceOverStatusDidChangeNotification`
- `hasShownImmersiveHint` must not be written during a VoiceOver session

None of that exists. A VoiceOver user entering the reader gets the same auto-hiding chrome as everyone else.

One thing the implementation *did* get right: the spec says control visibility via `alpha`, never `isHidden`, so elements stay in the accessibility tree — and `ReadingChrome` does use `.opacity()`. Which leads directly to the next finding.

### 3.8 🔴 Immersive mode probably leaves an invisible Back button live at the top of the screen `[code]` `[verify]`

`ReadingTopBar` hides itself with `.opacity(isVisible ? 1 : 0)`. In SwiftUI, **`.opacity(0)` does not disable hit testing** — the view is invisible but still receives taps, and it's layered above the ScrollView that carries the tap-to-reveal gesture.

Predicted behaviour: in immersive mode, tapping the top-left ~44×44pt of the screen dismisses the article back to the list instead of revealing the chrome. The rest of that 44pt band swallows the reveal tap silently.

**Repro:** open an article → tap to enter immersive → tap top-left corner. If you land back in the list, it's confirmed.

**Fix:** `.allowsHitTesting(isChromeVisible)` on the top bar. Note this interacts with §3.7 — the correct end state is "hit testing off when hidden, and never hidden while VoiceOver is on," which is one change, not two. The bottom bar collapses to `height: 0` so it's less likely affected, but it has the same `.opacity(0)` pattern and should get the same treatment.

### 3.9 🟡 Hardcoded colours that escape the theme system `[code]`

| Value | Where | Problem |
|---|---|---|
| `Color(hex: "766655")` | Archive/unarchive swipe tint | Paper's accent, used in **all four themes** — swipe in Night and you get a brown Paper button |
| `Color(hex: "4A90D9")` / `"5AAF7A"` | Mark read/unread swipe tint | Same, plus white label at 3.34 / 2.68:1 |
| `Color.black.opacity(0.7)` + `.white` | `ImmersiveHintPill` | Theme-agnostic; a black pill on cream is a foreign object in Paper |
| `Color.black.opacity(0.35)` | Filter-panel scrim | Nearly invisible over Night/Ink backgrounds |
| `.red.opacity(0.8)` | `AddArticleView:210` | Should be `semanticColors.error` |
| Status badge colours | `ArticleStatus.color` | Four fixed hues, identical across all themes — an iOS-system blue inside a warm paper palette |

The status badges deserve a deliberate decision rather than a fix: are they meant to be theme-independent (like a highlighter — you already argued this well for `VersoHighlightColor`), or should they take the theme? Right now it looks unconsidered rather than chosen. The `VersoHighlightColor` doc comment is a model of how to document that decision; the badges have nothing equivalent.

### 3.10 🟠 Four different ways to close or go back `[seen]`

Across the five screenshots that show a dismiss control, there are four distinct treatments for the same job:

| Surface | Treatment |
|---|---|
| Settings | chevron in a filled near-white circle, top-leading, title centred |
| Add Article | ✕ in a filled near-white circle, top-leading, title centred |
| Reader top bar | bare chevron, no circle, top-leading, title centred |
| Filter panel | bare ✕, top-trailing, title leading |
| Reader control sheets | bare ✕, top-trailing, floating over content |

Leading-vs-trailing, circled-vs-bare, ✕-vs-chevron — every axis varies, and not along any rule a user could learn. The circled variants also use a fill lighter than `surface`, so they read as system chrome rather than as part of the app.

**Recommendation:** two patterns, not five. Push navigation (Settings, reader) gets a bare leading chevron; modal presentation (Add Article, filter panel, control sheets) gets a bare trailing ✕. Drop the circles.

### 3.11 🟠 The Share Extension doesn't wear the theme `[seen]`

Side by side, the Share Extension's background is a neutral off-white while the app is warm cream, and its success checkmark is a brighter, more saturated green than `ArticleStatus.read`'s `#5AAF7A`. It reads as a different app.

That matters more than a normal consistency nit, because for anyone who found Verso through the share sheet, **the extension is the first surface they ever see** — and "it looks and feels like paper" is the product's whole first impression. Both fixes are small: read `ThemeManager` in the extension, and use `semanticColors.success`.

Its layout also floats: both extension screens centre their content vertically in a full-height sheet, leaving large empty regions above and below, where the app's own sheets anchor content to the top.

### 3.12 🟡 `Divider().background(colors.border)` does not colour the divider `[code]` `[verify]`

`SettingsView` uses this pattern ~10 times. `Divider()` draws a hairline in the **system separator colour** and fills its own 1pt frame; `.background()` paints behind it and is covered.

**Softened after the visual pass** `[seen]`: the Settings dividers are clearly visible and carry the screen's structure well — better than `border`'s 1.25:1 would predict, which is itself the evidence that they aren't using `border`. So this isn't a visual problem today; it's a correctness one. The dividers are almost certainly iOS grey rather than a theme token, which means they won't shift with the theme and the `border` token is doing nothing here. Check by switching to Sepia and seeing whether the lines warm up.

Your own codebase has the correct pattern in `ReadingChrome`: `Rectangle().frame(height: 1).foregroundColor(colors.border)`.

Worth noting the silver lining: if you "fix" all of these to actually use `border`, the Settings screen loses most of its structure, because `border` at 1.25:1 is too faint to divide anything. Which means the real fix is to **raise `border` toward 3:1** first, then apply it properly.

---

## 4. Onboarding

`[code]` only. **The 20-shot set contains no onboarding screens** — it starts at the article list — so this is the one area that got no visual pass. Treat every claim here as a source-level prediction, and note that the two predictions the visual pass *did* test elsewhere both turned out wrong.

### 4.1 🔴 Seven full-screen steps before the first article

`OnboardingFlowView` runs: Welcome → Theme picker → Folder picker → Analytics consent → Tour 1 → Tour 2 → Tour 3.

Exactly **one** of those is functionally required (the folder). For an app whose entire pitch is "less friction than Pocket," a seven-screen gate is the loudest possible contradiction of the positioning, and it's the first thing a new user experiences.

Worse, the page-dot row renders all seven dots on screen one, so the very first thing Welcome communicates is *"six more of these to go."*

Specific problems inside it:

- **Skip only exists on the tour** (screens 5–7). Theme and analytics cannot be skipped, only answered.
- **No back navigation affordance.** `advance()` is forward-only; the `TabView` allows a backward swipe but nothing signals it, and the dots aren't tappable. A user who mis-taps the theme picker has no visible way back.
- **The theme picker runs before any content exists.** You're asking someone to choose a reading theme when they have nothing to read and no basis for the choice — and it's the same picker that lives in Settings and in the reading toolbar, where it's actually contextual.
- **The tour explains features for an empty library.** "Share to save" means nothing until there's something to share.

**Recommendation.** Cut to two required screens: Welcome and Folder. Move theme to first-article-open (a one-time inline "tap to change theme" pointer at the reading toolbar costs nothing and lands when the choice is meaningful). Keep analytics consent but make it a sheet on first launch of the list, not a gate. Convert the tour into an empty-state that teaches by pointing at the real UI — which also fixes §5.2.

If cutting screens is too big a change this close to release, the minimum viable version is: make Skip global (visible from screen 1), and drop the dots to the number of screens actually remaining.

### 4.2 🔴 Theme-picker card labels fail contrast in half of all states `[computed]`

`ThemePreviewCard` colours its label with **the card's own theme's** `accent` (selected) or `textSecondary` (unselected), painted on the **currently active theme's** background. 8 of the 16 combinations fail 4.5:1 at 13pt:

| Current theme | Card | Selected label | Unselected label |
|---|---|---|---|
| Paper | Night | **1.99** ❌ | **3.06** ❌ |
| Paper | Ink | **2.39** ❌ | **3.30** ❌ |
| Sepia | Night | **1.85** ❌ | **2.85** ❌ |
| Sepia | Ink | **2.23** ❌ | **3.08** ❌ |
| Night | Paper | **3.15** ❌ | **3.12** ❌ |
| Night | Sepia | **2.87** ❌ | **2.84** ❌ |
| Ink | Paper | **3.34** ❌ | **3.31** ❌ |
| Ink | Sepia | **3.05** ❌ | **3.02** ❌ |

Worst case: the Night card's label at **1.85:1** while the user is on Sepia.

**Fix:** the label sits outside the card, on the app's background, so it must use the *current* theme's colours — `colors.textSecondary` / `colors.accent`, which is what `ThemeSelector` in Settings already does. The card's *interior* preview correctly uses that theme's own colours and should stay as-is. This is a direct consequence of §3.3.

### 4.3 🟠 Disabled Continue with no explanation `[code]`

`OnboardingFolderPickerView` disables Continue until a folder is chosen and dims it with `.opacity(0.5)`. Two problems:

- **Nothing says why.** The user sees a dead button and must infer the dependency.
- **The dimming destroys the label.** White at 50% over a 50% accent fill: **1.55:1** in Paper, 1.62 in Sepia, 2.77 in Night, 3.06 in Ink. The disabled button's text is effectively unreadable rather than merely de-emphasised.

**Fix:** keep the button enabled and, on tap without a folder, surface the reason inline; or add a `.disabled` case to `VersoButtonStyle` that keeps the label legible (a muted fill with `textSecondary` text, not a global opacity multiplier). `VersoButtonStyle` has no disabled variant at all right now, which is why every caller improvises.

### 4.4 🟡 Two glyphs break the icon language

`OnboardingFolderPickerView` uses `Text("☁")` for its illustration and `Text("›")` for the row chevron — raw Unicode characters, while every other onboarding screen uses `Image(systemName:)`. They won't match SF Symbols' optical weight or baseline, and `☁` may render as colour emoji on some configurations, in which case `.foregroundColor` silently does nothing.

`QuickTourView` uses `Image(systemName: "chevron.right")` for the same job, four files away.

**Fix:** `Image(systemName: "icloud")` and `Image(systemName: "chevron.right")`.

### 4.5 🟡 Consent screen weights the answer

Accept is `.primary` (filled), Decline is `.secondary` (outlined). Visual weight is nudging the choice. Given Quebec's Law 25 and GDPR both leaning toward equal-prominence consent, and given the privacy-first story is a genuine differentiator for this app, two `.secondary` buttons would be both safer and more on-brand. Not legal advice — worth a look from someone who does that.

### 4.6 🟢 Skip button stays in the accessibility tree on the last step

`.opacity(isLastStep ? 0 : 1)` plus `.disabled(isLastStep)` — invisible but potentially still traversable by VoiceOver. Use a conditional (`if !isLastStep`) instead.

---

## 5. Article list

### 5.1 🟠 Filters are invisible once applied, and there's no way to clear them `[seen]`

Filtering moved into a slide-over `FilterPanel` (tags + date). Once the panel closes, the **only** signal that filters are active is a small count badge on the header icon — the same badge that fails contrast in dark themes (§3.1).

If the filters produce nothing, the user gets the `.searchMiss` empty state — an icon, a headline, a subheadline, and **no mention of the filters causing it and no way to clear them.** They have to remember the panel exists, open it, and deselect each tag individually, then reset the date preset separately: **`FilterPanel` has no "Clear all".**

This is the same concern that produced the earlier "keep chips visible on empty states" decision, resurfacing in a new shape after the chips were removed. The old chip bar had a real virtue — filter state was always on screen.

**Fix, in priority order:** (1) add "Clear all" to the panel header, enabled when `activeFilterCount > 0`; (2) add a "Clear filters" button to the `.searchMiss` empty state; (3) consider a single dismissible summary row under the header when filters are active ("2 tags · Past month ✕"), which restores the chip bar's visibility without its width problems.

`[seen]` confirms the panel header is just "Filters" and an ✕ — no clear action. Two more things the screenshot surfaced: the panel covers **~80% of the screen width** on a 393pt device, leaving a scrim strip too narrow to read as "tap here to dismiss"; and with zero tags in the library the tag section still renders a "Search tags…" field above a lone "All tags" row, searching nothing. Hide the field when the tag list is empty.

### 5.2 🟠 The empty state has no call to action, and its copy points out of the app `[seen]`

`EmptyState` is icon + headline + subheadline in all three variants. Seen on SE 2026-09-03: "No articles yet" / *"Share an article from Safari to get started."* The single instruction on the screen sends the user **out of the app**, while the `+` button that does the same job sits ~40pt above it, unmentioned.
 The `.empty` variant is what a brand-new user sees immediately after a seven-screen onboarding, and it offers them **nothing to tap** — despite `AddArticleView` existing one icon away.

The empty state is the highest-leverage screen in the app for activation and it's currently decorative. Add a primary "Add your first article" button to `.empty`, and a "Clear filters" secondary to `.searchMiss` (§5.1).

### 5.3 🟠 Cards show the date added; read time is hidden until you commit

`ArticleCard` shows title / source / **date added**. `ArticleHeader` — inside the article, after you've opened it — shows date **and** read time.

That's backwards. Read time is decision-support information: its entire value is in helping someone choose what to read from a queue. `ReadingEstimate.swift` already exists and the reader already calls it. The date added is the less useful of the two on a card, and it currently occupies a full line.

**Fix:** `theatlantic.com · 12 min read` on one line; drop or de-emphasise the date. Also note `accessibility-specs.md` §5.1 specifies the row's VoiceOver label as *"[title], [source], [estimated read time]"* — the spec agrees, and the implementation doesn't deliver it in either channel.

### 5.4 🟡 Section counts exist for VoiceOver but not on screen `[seen]`

`sectionHeader` passes `L10n.Filter.unreadAccessibilityLabel(count:)` to VoiceOver but renders only the bare title. So a VoiceOver user hears "Unread, 12 articles" and a sighted user sees "Unread".

Nice a11y work — but the count is useful to everyone, and the old chip bar showed it ("Unread 6"). Render it.

### 5.5 🟡 Card containers sit at the bottom of the perceptible range

`surface` on `background` is **1.08–1.11:1** across all four themes, and `ArticleCard` has no border.

**Softened after the visual pass** `[seen]`: the cards read clearly as distinct surfaces in Paper — large flat areas flatter low contrast, and the 12pt radius plus generous padding do most of the work. This is not a problem today. It's worth knowing only as a fragility: at 1.08:1 there's no margin for a display filter, direct sunlight, or a future tweak to either token.

### 5.6 🟠 Bulk select: the destructive action isn't marked destructive, and nothing says how many `[seen]`

Two problems in the same bar:

**Delete isn't red.** `Button(role: .destructive)` combined with `.buttonStyle(.plain)` drops the role's colour — in the screenshot "Delete" renders in plain `textPrimary` black while "Mark read" sits in accent. So the irreversible action is the *less* prominent of the two. The reader's overflow menu gets this right (`[seen]`: its Delete is red with a trash icon), which makes the bulk one — deleting *several* articles at once — the inconsistent and more dangerous case. Use `semanticColors.error`.

**There is no selection count anywhere.** One article is selected and the header still reads "Verso". iOS convention is to replace the title with "1 Selected", and it matters most immediately before a bulk delete. The confirmation dialog does show the count, but that's after the fact.

### 5.7 🟡 Entering select mode re-truncates every title `[seen]`

The checkbox is inserted *outside* the card, in an `HStack` that pushes `ArticleCard` right and narrows it. Every row's title reflows: "…accused of meddling in another Brazilian electi…" becomes "…accused of meddling in anoth…". A whole screen of text visibly jumps and re-clips on mode entry.

**Fix:** reserve the checkbox column at all times (hidden but space-occupying), or overlay the checkbox on the card rather than beside it, so the content width never changes.

### 5.8 🟡 Add Article: no escape while saving, and a 1.5s success window `[code]` `[seen]`

`showsDismissToolbarButton` returns `false` for both `.saving` and `.success`.

The success case is fine in practice — `successContent` auto-dismisses after 1.5s (my first pass called this a trap; it isn't). But 1.5s is a hardcoded, uninterruptible window, and it's too short for VoiceOver to finish speaking "Article saved! It will appear in your library shortly" before the sheet disappears.

**`.saving` is the real one:** if a parse hangs, the user has no close button and no cancel — only a swipe-down they have to guess at. Keep the ✕ visible during `.saving`, and let it cancel.

Also `[seen]`: the disabled Save button is §4.3's washed-out label in the flesh — white at 50% over a 50% accent fill, **1.55:1** in Paper. It reads as barely-there text rather than a disabled control.

### 5.9 🟡 Settings is two taps deep behind "…" `[seen]`

The overflow menu holds exactly two items: "Select" and "Settings". Settings is where font family, font size, theme, folder, import and language all live — the app's entire configuration surface — and it's hidden behind an unlabelled ellipsis, given equal billing with bulk-select, a rarer action.

With four header slots already spent, there's no free room, so this is a trade rather than an oversight. But "Select" is the better candidate for the overflow, and a gear is more discoverable than "…". Worth reconsidering before the icon set calcifies.

### 5.10 🟡 Collapsible and non-collapsible section headers look identical `[seen]`

"Unread" and "Archived" render the same way; only Archived carries a chevron at the far trailing edge, and only Archived is tappable. Two controls that look alike and behave differently, with the sole cue 300pt away from where the eye starts.

Related: the gap between the last card of one section and the next section's header is barely larger than the gap between two cards in the same section, so group boundaries read weakly.

### 5.12 🔴 The Continue Reading caption reads "0 read" `[seen]` → FAB-330

Cards in that section show `0 read`, `20 read`, `3 read` — where the number is a **percentage**. `ArticleCard` feeds `Int((progressFraction * 100).rounded())` into `L10n.Home.sectionContinueReadingProgressCaption(count:)` and the string carries no percent marker, so it parses as a count of something. "0 read" on an article the section claims you're in the middle of is worse than unclear; it contradicts the section it sits in.

Needs fixing in all three locales, and the VoiceOver value too. Worth settling against FAB-278 first — that issue proposes replacing percentage with time-remaining, and this string shouldn't be translated three times before that decision.

### 5.13 🟠 Articles at 0% fill Continue Reading `[seen]` → FAB-331

Four of five cards in the section show 0%. `ArticleReaderView`'s `.task` calls `advanceStatus(to: .reading)` unconditionally on open, and `continueReadingArticles` filters on `statusEnum == .reading` with no progress floor — so opening an article and immediately backing out files it under "things you started", permanently.

Either promote to `.reading` only past a scroll floor, or filter the section on `scrollPosition > 0`. The first is truer to the model; the second is a one-line change.

### 5.11 🟡 Two smaller things

- **Filter panel is a fixed `width: 320`** `[seen]`. That's ~80% of a 393pt screen and ~85% of the 375pt iPhone SE, leaving a dismiss strip of roughly 55pt — too narrow to read as "tap outside to close". Use a fraction with a maximum.
- **Date presets and tags look identical.** Both render as checkmark rows, but dates are single-select and tags are multi-select. Same affordance, different semantics. Radio-style marks for the date group, or a visual grouping change.

---

## 6. Reading view

**This screen is the reason the app is worth shipping.** The critique below is polish on something that already works.

### 6.1 🟠 Immersive mode gains you nothing at the top

The scroll content's top padding is `.padding(.top, 44 + safeAreaTop + 24)` — a constant, with no dependence on `isChromeVisible`. The `44` is reserving room for a top bar that has just faded to `opacity: 0`, so entering immersive mode leaves roughly 90pt of empty space where the bar used to be and the text does not move up at all.

The bottom behaves correctly, because the bottom bar is a `safeAreaInset` whose frame collapses to `height: 0` when hidden — so the content genuinely reclaims that space. Only the top is asymmetric.

The whole point of the mode is more text. Right now it's half-delivering, and it's the half at eye level.

**Probably refuted `[seen]`.** Immersive-mode captures from 2026-09-03, in Paper and in Night, show the article title starting roughly 65–70pt higher than in the chrome-visible shots — the content does reclaim the bar's space. I cannot reconcile that with the source: line 114 really is a constant. The original observation came from the stale August set, where the two shots may never have been comparable.

**Settle it with one controlled test:** open an article, don't scroll, capture with chrome visible; tap once into immersive, don't scroll, capture again. If the H1 moves up, close FAB-317.

**Fix, only if the test confirms it:** animate the top padding alongside `isChromeVisible`, matching the 0.3s fade.

### 6.2 🟠 The line-spacing control uses text-alignment icons `[seen]`

```swift
["text.alignleft", "text.justify", "text.justify.leading", "text.justify.trailing"]
```

Four **alignment** symbols standing in for four **line-spacing** levels (Compact / Normal / Relaxed / Airy). A user reading these icons will reasonably expect them to left-align, justify, and so on — and they'd have no way to discover otherwise, because the buttons have no labels and no VoiceOver strings.

Two of the four (`text.justify.leading`, `text.justify.trailing`) are also visually near-identical at 18pt, so even as arbitrary markers they don't differentiate.

**Fix:** use symbols that encode vertical rhythm — `arrow.up.and.down.text.horizontal`, or the `lineweight`/`text.line.*` family — or, better for a four-step scale, drop icons and use text labels or a segmented control with the actual names. Either way they need accessibility labels.

### 6.3 🟠 The font-size control contradicts the spec, and Settings contradicts the reader

`accessibility-specs.md` §4.2 defines a named six-step scale — XS 14 / S 16 / M 18 / L 20 / XL 22 / XXL 26 — with per-step line-height multipliers, and `Typography.Reading.BodySize` implements exactly that enum.

Neither font control uses it:

| Control | Step | Range | Steps | Display |
|---|---|---|---|---|
| Reader sheet | ±1 | 14–26 | 13 | raw number `18` |
| Settings | ±2 | 14–26 | 7 | `18pt` |

Three consequences. **The named scale is dead code** — `BodySize` and its `lineHeightMultiplier` are bypassed, so the line-height-varies-by-size behaviour the spec designed doesn't happen. **The two controls disagree** on what a step is, for the same stored value. **Both expose the point size** as a number, which is an implementation detail; XS→XXL was the better idea and it's already written.

### 6.4 🟠 The top bar repeats the title that's directly below it `[seen]`

`ReadingTopBar` shows the article title, truncated to one line, directly above the H1 rendering the same title in full. The spec anticipated this — §5.2 says hide the bar title from VoiceOver while the article is visible — but the visual redundancy is the same problem, and it's spending the most valuable strip of the screen on it.

`[seen]` makes it worse than it reads in source: the bar shows "Echoes of cold war as US accused of…" — a *truncated* copy — sitting directly above the same title set in full, four lines, 28pt bold. The eye reads the same sentence twice, and the first reading is the broken one.

Most reading apps show the title in the bar only once the H1 has scrolled away. You already track scroll offset precisely; the condition is cheap. Bumped from 🟡 to 🟠 on the strength of seeing it.

### 6.5 🟡 Fixed sheet detents

`.presentationDetents([.height(218)])` and `.height(168)`. Content scales with Dynamic Type; the sheet doesn't. See §8.

### 6.6 🟡 The reading bar dropped two controls the spec specified

Spec §2.1 lists the bar as font −/+, spacing, **margins**, theme, mark-read. Shipped: font/spacing (one button), TTS, theme, plus a progress bar. Margins and mark-read are gone — mark-read to the overflow menu, margins entirely.

Dropping margins looked defensible at 393pt. **Measured on iPhone SE** `[seen]` — 375×667pt, the narrowest supported device — the default 18pt Georgia gives **~32–38 characters per line**, already under the comfortable 45–75 band with no user control. (Earlier drafts said 320pt; that was the SE 1st gen, no longer supported.) See §6.14.

Also: the 40pt padding is a literal, not a token — `VersoSpacing` has 32 and 48.

### 6.7 🔴 Image captions are printed twice `[seen]` `[code]`

In the test article the photo caption appears as a caption under the image *and again* as a full body paragraph in 18pt New York, with the photo credit appended:

> *Chico Rubens Paiva, 38, an activist whose grandfather investigated US meddling in Brazilian politics in the 1960s* — as caption, then again as body, ending "…in the 1960s. Photograph: João Laet/The Guardian"

The reader's best screen stutters and repeats itself immediately after its only image.

**You already have the guard, and it's one comparison too strict.** `HTMLToMarkdownConverter.collapseImageCaptionEcho` drops the echo when the image's alt text and the following paragraph match — but it requires `fingerprint(alt) == fingerprint(next)`, exact equality after punctuation normalisation. The Guardian appends " Photograph: <credit>" to the echoed paragraph, so equality fails and the echo survives.

**Fix:** match on prefix rather than equality — drop the next block when it *starts with* the alt text and the remainder is short (or matches a credit pattern like `Photograph:` / `Photo:` / `Credit:`). Worth adding the Guardian case to `HTMLToMarkdownConverterTests`, since this is a publisher-shaped bug that will recur.

### 6.8 🟠 The sheet close button collides with the last control `[seen]`

In **both** reading-control sheets the ✕ sits at top-trailing over the content, and in both it lands on top of the right-most control:

- font sheet — the ✕ overlaps the large "A" (increase size)
- theme sheet — the ✕ overlaps the Ink swatch's top-right corner

Both are accent-coloured, ~8pt apart, and one of them dismisses the sheet. Increase-font is a repeat-tap control; it's the worst possible neighbour for a close button.

Compounding it, each sheet has a drag handle **and** an ✕ — two dismiss affordances, one centred, one trailing. Pick one: given the fixed detent and small height, the grabber alone is the iOS-idiomatic answer, and removing the ✕ resolves the collision for free.

### 6.9 🟠 The font-size control doesn't look like a control `[seen]`

The row renders as `Font size … A  18  A` — a small A, the value, a large A. No `+`/`−`, no borders, no background, no separation. The two A's read as size *labels* flanking a value, not as buttons. Combined with their ~14×17pt and ~20×24pt hit areas (§3.4), this is the least discoverable control in the app, sitting in its most-used sheet.

Apple's own reader uses the same two-A idea but gives each a filled, bordered container that reads unambiguously as a button. Do that, at 44×44, and it fixes discoverability and §3.4 in one change.

### 6.10 🟡 The two chrome rows don't share an alignment logic `[seen]`

With TTS active, the transport row puts three controls hard-left and "1×" hard-right with a void between, while the bar directly beneath it centres the progress indicator between two edge-anchored icons. Two stacked rows, two different distribution rules, ~1pt apart. The transport glyphs are also 16–18pt against the main bar's 20pt, so the secondary row reads as slightly-off rather than deliberately lighter.

### 6.11 ✅ System menus break the theme — **withdrawn**

The second pass flagged the overflow menus as a theme break: system material, near-white and cool, inside a warm cream app, and predicted something much worse over the dark themes.

**The Ink pass shows the opposite.** The reader's overflow menu renders in the *dark* system material and sits correctly in the theme. `ContentView`'s `.preferredColorScheme(currentTheme.isDark ? .dark : .light)` is what drives it, so every piece of system-drawn chrome — menus, keyboard, alerts, selection handles, the Settings toggle — follows the theme automatically.

No action. Recorded because it is the clearest demonstration of what that modifier buys, and therefore the second reason not to delete it while fixing the theme-switch bug (FAB-304).

### 6.13 🔴 Publisher chrome and title suffixes reach the reader `[seen]` → FAB-332

Two defects on one CNN article, both in the first inch of the screen:

* The body opens with **"Facebook Tweet Email Link Threads Link Copied!"** — a social share bar rendered as the first paragraph — followed by the dateline as its own paragraph. FAB-294's `isNoiseLine` screen doesn't catch it.
* The title keeps its publisher suffix: **"God save the drag kings of England | CNN"**, in the H1, the top bar and the article card. Any site that appends " | Publisher" to `<title>` carries it everywhere.

Same family as §6.7's duplicate captions — three publisher-shaped parsing gaps, all deserving fixture tests. Together they are the strongest argument in this document, because they degrade the one screen the product is actually built around.

### 6.14 🟠 The reading measure collapses with OpenDyslexic and at the top of the size scale `[seen]` → FAB-333

At 18pt, OpenDyslexic reflows the body to roughly **25–30 characters per line** — four or five words. Georgia at the maximum in-app size (26pt) gives roughly **28–32**. Both are far below the 45–75 range that makes long-form reading comfortable, on the app's core screen.

The column is `.frame(maxWidth: 680)` with a hardcoded `.padding(.horizontal, 40)`, so ~313pt on a standard iPhone regardless of family or size, and there's no margin control — §6.6 notes the spec called for one and it was never built. OpenDyslexic is the sharper case: it's much wider than Georgia at the same nominal size, so `BodySize` (§6.3) should arguably be per-family rather than absolute.

Note this is the *in-app* scale, not system Dynamic Type — §8.1 is still untested and stacks on top of this.

### 6.12 🟢 Two small ones

- **The hint pill lands on top of the article text** `[seen]`. "Tap anywhere to reveal controls" is positioned 80pt from the bottom, which puts a black lozenge in the middle of the reading column — across a body line in Paper, across a section heading in Night. In Paper its hardcoded `Color.black.opacity(0.7)` on cream is the foreign object §3.9 describes. It's also a bare `Text` with `.onTapGesture` — no `Button`, no accessibility traits, tap target under 44pt.
- **The article H1 doesn't optically align its opening quote** `[seen]`. On a title beginning with a curly quote — "'A crisis of authenticity': the truth about food influencers" — the first line sits visibly indented against lines two and three, because the quote mark's sidebearing isn't hung into the margin. A small thing, but this screen earns that kind of polish elsewhere.
- **`ArticleHeader` hardcodes 15pt/13pt** where `VersoTypography.UI.listSubtitle`/`.caption` are the same values.

---

## 7. Settings

### 7.1 🟠 Selection is signalled by an 8pt dot `[seen]`

`SettingsRow.fontRow` and `.languageRow` mark the selected item with `Circle().frame(width: 8, height: 8)` at the far trailing edge.

An 8pt dot is a very quiet mark for the most important state on the screen, and the comparison inside the same file is unflattering: `defaultRow`'s passive disclosure chevron is 14pt semibold. **The inert affordance is drawn more strongly than the active selection.** The dot also sits at the far trailing edge of a 78pt-tall row, so it has little to visually bind to.

iOS's convention here is a `checkmark` in the accent colour, and `FilterPanel.tagRow` already uses exactly that, in this same app. Use it.

### 7.2 🟠 Night and Ink are indistinguishable in the theme selector `[seen]`

`ThemeChip` renders a 32pt rectangle of the theme's `background` and nothing else. Those four backgrounds pair off almost exactly: Paper vs Sepia is **1.07:1**, Night vs Ink is **1.06:1**. At those ratios the swatches are two creams and two blacks, and the only thing separating each pair is an **11pt** label.

So the swatch communicates "two light, two dark" and the actual choice is made from tiny text. Meanwhile the onboarding card — which shows a miniature page with `textPrimary` and `textSecondary` bars on it — differentiates all four immediately, because the difference between these themes is a *relationship* between background and text, not a background colour.

`[seen]` in both the Settings selector and the reader's theme sheet: Night and Ink are two identical black rectangles, and the 11pt labels are visibly the smallest text anywhere in the app. Paper and Sepia fare better than the arithmetic suggests, because near-white against cream is a difference the eye reads well at that size — but the dark pair is genuinely undifferentiated.

**Fix:** unify on the onboarding treatment at chip scale (§3.3) — a miniature page with `textPrimary`/`textSecondary` bars on it separates all four instantly, because what distinguishes these themes is the text-on-background relationship, not the background. Raise the label from 11pt to `VersoTypography.UI.caption` (13pt).

### 7.3 🟠 OpenDyslexic has no Bold face — corrected from a wrong prediction

**I got this wrong first time.** The source-only pass predicted OpenDyslexic was silently falling back to the system font, because `SettingsView` requests `"OpenDyslexic-Regular"` while `DesignSystemPreview` requests `"OpenDyslexic"`. `[seen]`: it renders correctly in Settings — the wide tracking and weighted bottoms are unmistakable. The `"OpenDyslexic-Regular"` name works. (`DesignSystemPreview`'s different string is still worth reconciling, but it's a DEBUG surface, not shipping behaviour.)

**What is real, and now confirmed rather than predicted:** `[seen]` in the Settings font list, "Georgia" renders as a heavy bold serif while **"OpenDyslexic" renders at regular weight** — the row title asks for `.weight(.semibold)` and gets nothing, because SwiftUI does not synthesise bold for custom fonts.

**Only `OpenDyslexic-Regular.ttf` is bundled** (`Resources/Fonts/`, `project.yml`, `Info.plist`). Spec §4.5 explicitly maps Semibold/Bold to `OpenDyslexic-Bold`. Without it, **every heading in every article read in OpenDyslexic renders at body weight** — h1 through h4 all ask for `.bold`/`.semibold`. A dyslexic reader gets an article with no visible heading hierarchy, which is the opposite of what the feature is for.

**Also confirmed** `[seen]`: the OpenDyslexic preview row truncates — "The quick brown fox jumps over…" — while all three other fonts show the full sentence. OpenDyslexic is much wider, and `fontRow`'s `.lineLimit(1)` clips it. That's §3.5's truncation problem biting at *default* text size, before Dynamic Type is involved at all.

**Fix:** bundle `OpenDyslexic-Bold.ttf` (same OFL licence, already in the repo's LICENSE file) and map the weight, per spec §4.5. Then drop the `lineLimit(1)` on the preview or shorten the pangram.

### 7.4 🟠 The analytics toggle has no VoiceOver label

```swift
Toggle("", isOn: $analyticsOptIn).labelsHidden()
```

The visible label is a separate `Text` beside it, so the toggle itself announces as an unnamed switch. Add `.accessibilityLabel(L10n.Settings.analyticsRowLabel)`.

### 7.5 🟡 Two heading levels, one visual style `[seen]`

`sectionHeader` ("READING") and `sectionLabel` ("Font", "Theme") are both 13pt `textSecondary`, distinguished only by capitalisation — two different levels of a real nesting hierarchy rendered in one style. Give the section header more weight, more space above, or both.

### 7.6 🟡 Smaller things

- **The folder row shows `lastPathComponent` alone** — for a folder called `Reading`, the row reads "Articles folder · Reading", which parses as a settings *value* rather than a folder name. A folder glyph, or the parent directory alongside it, would disambiguate.
- **The font-size stepper stays tappable at its limits** — the guard is inside the closure, so at 26pt the `+` still accepts taps and does nothing. Use `.disabled()` so it's inert and announces correctly.
- **Font size lives in Settings, line spacing only in the reader**, font family only in Settings, theme in both plus onboarding. The split isn't wrong, but it isn't legible either.

---

## 8. Needs verification before acting

Four passes have now covered every theme, every screen in scope, onboarding, immersive mode, a large-text pass and iPhone SE. Two things remain, and one of them no screenshot can answer.

1. **The immersive-mode Back button (§3.8).** An interaction, not an appearance — no capture settles it. Open an article, tap into immersive, tap the top-left corner. Ten seconds, and it's either a 🔴 or a non-issue. → FAB-307
2. **Whether §6.1 is real.** Immersive captures on three devices all suggest the content *does* reclaim the bar's space, contradicting the source. One controlled before/after at scroll 0 settles it; close FAB-317 if the H1 moves up.
3. **A second large-text pass, after FAB-309 lands.** The current one only shows the app ignoring the setting, so it says nothing yet about whether layouts survive once text actually scales. FAB-309's audit checklist only becomes meaningful then.

Two earlier concerns are now withdrawn rather than pending: `Divider().background()` is effectively confirmed as a no-op (in Ink, `border` at 1.16:1 would be invisible, yet the dividers are clearly visible), and the Settings theme-chip row does **not** overflow on the narrowest supported device — 4 × 80pt + 32pt fits 375pt with room to spare. Earlier drafts referenced a 320pt screen; that was the SE 1st gen, which iOS no longer supports.

## 9. What works well

Worth saying, because the list above is long and the app is better than it makes it sound.

- **The reading view's typographic decisions.** A ~313pt measure, 1.75 line height, the New York/serif default, 40pt gutters, and a title/attribution/body rhythm that's actually specified rather than defaulted. Everything about it reads as chosen.
- **The four themes are properly designed**, not a light/dark toggle with two extras. Paper and Sepia are genuinely different papers; Night and Ink are genuinely different darks. The `textPrimary`/`textSecondary`/`accent` relationships hold across all four.
- **`VersoHighlightColor`'s doc comment** is the best piece of design documentation in the repo: it states the decision, the alternatives rejected, the reasoning, and the computed ratios in all four themes. If every non-obvious token had that, §3.9 wouldn't exist.
- **`accessibility-specs.md` itself.** Most projects this size have nothing like it. The failures above are drift from a good spec, which is a far better problem than the absence of one.
- **The copy.** "No personal info or article content, ever." · "This link is already in your library as …" · the duplicate-save prompt offering *Update existing* / *Save as copy* / *Cancel* as a clean three-tier choice. It's calm, specific, and never cute — which is exactly right for this product. The one wobble is "Article saved!" with an exclamation mark it doesn't need.
- **The reader's overflow menu** — six actions, well-grouped, sensible icons, Delete correctly separated and red.
- **The sectioned list (Continue Reading / Unread / Read / Archived)** with Read and Archived collapsed by default is the right model for a reading queue, and better than the flat chip-filtered list it replaced.
- **Real accessibility labels on the list**, including pluralised counts, in the places that got attention.
- **The onboarding theme cards** — showing a miniature page with type rather than a colour chip is the correct idea, and it should propagate to the other two pickers rather than the other way around.
- **`FolderPickerPrompt`'s CTA** already solves §3.1 correctly. The right answer is in the codebase; it just hasn't spread.

---

## 10. Priority

**Fix before submitting the binary**

1. **§3.5** Rebuild `VersoTypography` on text styles so the app respects the system text size at all. It currently doesn't, anywhere, and the app's own spec calls this mandatory. Largest item here, and everything in the layout audit depends on it landing first. → FAB-309
2. **§3.1** White-on-accent → `theme.background`. Affects every primary CTA, the add button, the filter badge, in both dark themes. Four small edits, using a pattern you already wrote in `FolderPickerPrompt`.
3. **§6.7 + §6.13** Reader content quality, as one job: the duplicate image caption, CNN's share bar in the body, and the " | Publisher" title suffix. Three publisher-shaped parsing gaps that all disfigure the app's best screen. The caption guard already exists and needs one equality check loosened to a prefix match. → FAB-315, FAB-332
4. **§4.2** Theme-card labels → current theme's colours. One edit, kills eight contrast failures.
5. **§3.8** `.allowsHitTesting` on hidden chrome — pending the ten-second check.
6. **§6.8 + §6.9 + §3.4** The reader's font sheet, as one job: remove the ✕ (the grabber is enough, and it resolves the collision), give the two A's real button containers at 44×44. Most-used control in the most-used screen, currently neither discoverable nor tappable, and named explicitly in your own spec.
7. **§5.6** Make bulk Delete red and put a selection count in the header. An unmarked destructive action on a multi-select is the one place a mis-tap is expensive. → FAB-320
8. **§5.12** Fix the "0 read" caption. A one-word copy bug that makes the list's most prominent section contradict itself. → FAB-330
9. **§3.6** Localize the seven reading-chrome accessibility strings. Mechanical. → FAB-308

**Fix before 1.0 if the timeline allows**

8. **§5.1 + §5.2** "Clear all" in the filter panel, and CTAs in both empty states. Highest activation impact of anything here.
9. **§7.3** Bundle `OpenDyslexic-Bold.ttf`. Without it, articles read in the accessibility font have no visible heading hierarchy.
10. **§3.5** The `lineLimit(1)` set and the fixed frames — *after* the Dynamic Type pass (§8.1), so you fix what actually breaks rather than what might.
11. **§5.3** Read time on the card instead of date added.
12. **§6.1** Animate the reader's top padding with the chrome, so immersive mode gains space at the top as well as the bottom.
13. **§3.11** Give the Share Extension the theme. It's the first surface many users will ever see.
14. **§3.10** Two close/back patterns instead of five.

**Post-launch**

15. **§3.3 + §7.2** One `ThemeSwatch` component, onboarding's treatment, swatches read from `ThemeColors`. Fixes the Night/Ink ambiguity as a side effect.
16. **§3.2** A contrast script in CI, replacing the hand-maintained tables. Then correct §3.3 of the spec, which currently overstates its coverage.
17. **§4.1** The seven-screen onboarding. The biggest single improvement available to this app, and the one least suited to a pre-release change.
18. **§6.2** Line-spacing icons that mean line spacing.
19. **§6.3** Reconnect the font controls to `BodySize` and its per-step line heights.
20. **§5.7 + §5.9 + §5.10** Select-mode layout shift, Settings' discoverability, and collapsible headers that look collapsible.
21. **§3.9** Decide, and document, whether status badges are theme-independent.
