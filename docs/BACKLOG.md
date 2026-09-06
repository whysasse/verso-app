# Verso — Backlog & Issue Tracker

**Issue tracker of record** (Linear retired 2026-06-12). Active issues only — see [DONE.md](DONE.md) for completed work.

## Status Vocabulary

- **Todo** — Not started; ready to begin work
- **In Progress** — Actively being worked on
- **Backlog** — Defined but not prioritized for immediate work
- **In Review** — Awaiting feedback or approval

## Priority

🔴 Urgent · 🟠 High · 🟡 Medium · 🔵 Low · ⚪ None

## Numbering

Issues continue the FAB-xx sequence from Linear (migration 2026-06-12). New issues receive the next available FAB-xx number in sequence.

**39 open issues** across iOS, Web, Design, and Infra. 30 were opened 2026-09-01/03 from [DESIGN_CRITIQUE_2026-09-01.md](DESIGN_CRITIQUE_2026-09-01.md): FAB-306–329 (critique findings) and FAB-331–333 (found in the 2026-09-03 Ink + onboarding screenshot pass; FAB-304, FAB-305, FAB-306, FAB-307, FAB-308, FAB-309, FAB-311, FAB-312, FAB-323, FAB-325, FAB-330 and FAB-331 done, see DONE.md). **FAB-334** is the 1.1 native-shell epic agreed 2026-09-03 — read it before picking up any chrome issue, since it absorbs several.

## Working mode — Fabio away from his Mac/device (starting 2026-09-05)

Fabio is on the go and can't run a real build or open the Simulator to confirm each change as it ships. Work continues as normal otherwise — issues get planned, implemented, and verified with `xcodebuild` (compiles, no new warnings), and each gets its own PR — but the manual on-device verification step that normally happens per-PR is deferred instead of blocking. PRs stay **open, unmerged**, and every one of them (plus what to actually check in each) is tracked in **[PENDING_TESTS.md](PENDING_TESTS.md)** so it can all be run through in one batch once Fabio is back at his Mac. Nothing gets merged to `main` off this deferred verification — merging still waits for an explicit go-ahead per PR, same as always.

## Current sequencing (iPhone-only work, agreed with Fabio 2026-08-24)

Excludes the iPad epic (FAB-131, FAB-152–162) and the Phase 3 expansion backlog, which are deferred past this release.

- **Phase A — ship this release.** FAB-163 and FAB-164 done (see [DONE.md](DONE.md)). FAB-150's Store & compliance checklist is done — Fabio reviewed and entered all ASC metadata 2026-08-25 (see [APP_STORE_LISTING.md](APP_STORE_LISTING.md)). Remaining: the final binary submission itself.
- **Phase B — localization (FAB-275).** Steps 1–8 done (see [DONE.md](DONE.md)). FAB-284 (language picker, iOS + Web) also done 2026-08-28 — nothing open in this phase.
- **Phase D — design critique remediation (new, 2026-09-01/03).** FAB-304 (backgrounding corrupts app state, four independent causes), FAB-305 (white-on-accent contrast), FAB-306 (onboarding theme-picker label contrast) and FAB-307 (immersive chrome hit-testing + VoiceOver) are done — see [DONE.md](DONE.md) for the full history. FAB-307–333 come from [DESIGN_CRITIQUE_2026-09-01.md](DESIGN_CRITIQUE_2026-09-01.md); its §10 ranks them. Screenshot coverage as of 2026-09-03: Paper, Sepia, Ink and Night all seen, onboarding seen, immersive seen, one large-text pass done. Still unseen: iPhone SE (Fabio to capture). The immersive-mode Back-button repro that no screenshot could answer is now confirmed and fixed as FAB-307.

  **Amended 2026-09-03, after the native-shell decision.** Fabio chose to **ship 1.0 on the current UI and do the native iOS shell as 1.1** ([FAB-334](#)). That changes what belongs in this list: several items below are defects in custom chrome that FAB-334 deletes outright, so fixing them now is work thrown away. Items **13 (FAB-310)**, **15 (FAB-320)** and **16 (FAB-319)** move to FAB-334, as do the chrome halves of FAB-329, FAB-326, FAB-325 and FAB-324 in the post-launch list. Item **11 (FAB-309)** splits: the `VersoTypography.UI` token rebuild stays in 1.0 (cheap, mechanical, and it survives the shell — and a reading app that ignores the system text size shouldn't ship that way for however long 1.1 takes), while its layout audit of chrome components moves to FAB-334. Item **8 (FAB-311)**'s ✕/grabber collision is absorbed too, but its `BodySize` reconnection is reading-view work and stays. **Read FAB-334 before starting any item marked below.**

  **Original sequencing, agreed with Fabio 2026-09-03** (supersedes the single-line "Pre-submission set" this replaced — that line put FAB-309 before FAB-311, which contradicted FAB-309's own "Related" note that FAB-311's `BodySize` work should land first; this ordering follows the note).

  *Pre-submission — fix or ship before the final binary submission (FAB-150):*

  1. ~~**FAB-304**~~ — **done**, see [DONE.md](DONE.md): theme-switch blank screen (cause 1, shipped PR #360) turned out to have three further independent causes (reader content blanking after the app switcher; backgrounding losing folder access and corrupting Core Data's article cache; a stale-scan race reverting in-progress status changes) — all fixed and device-confirmed.
  2. ~~**FAB-315 + FAB-332**~~ — **done**, see [DONE.md](DONE.md): duplicate image captions + publisher title/chrome parsing, one PR, shared converter and test suite.
  3. ~~**FAB-330**~~ — **done**, see [DONE.md](DONE.md): the string already had a `%` in all three locales, just unescaped in the compiled catalog, so it was silently dropped at render time — a one-line escaping fix, not a content fix. FAB-278's percent→time-remaining redesign remains deferred, untouched by this fix.
  4. ~~**FAB-331**~~ — **done**, see [DONE.md](DONE.md): took the filter default (`scrollPosition > 0`), not the promote-to-`.reading` floor — lower risk, no data-model change. Revisit the floor post-launch if the filter proves insufficient.
  5. ~~**FAB-305**~~ — **done**, see [DONE.md](DONE.md): white-on-accent contrast fixed (`VersoButtonStyle.primary`, the `+` add-article glyph, the filter badge), plus the real `VersoButtonStyle` disabled variant FAB-328 later depends on.
  6. ~~**FAB-306**~~ — **done**, see [DONE.md](DONE.md): onboarding theme-picker label contrast fixed (the picker used the active theme's colours for the label — the pattern FAB-324 later carried into the shared `ThemeSwatch` component that replaced this and the other two theme pickers).
  7. ~~**FAB-312**~~ — **done**, see [DONE.md](DONE.md): bundled `OpenDyslexic-Bold.ttf` from the same upstream project as the existing Regular face, so `.custom(fontFamily,size:).weight(.bold)` now resolves to a real bold face instead of falling back to system.
  8. ~~**FAB-311**~~ — **done**, see [DONE.md](DONE.md): ✕ removed (drag handle + swipe-to-dismiss already sufficient), font-size buttons got real bordered 44×44 containers, line-spacing icons replaced with a labelled Compact/Normal/Relaxed/Airy control (pre-existing, unused copy strings), and both the reader's and Settings' font-size steppers now step through `BodySize`'s 6 named sizes instead of disagreeing (±1 vs ±2) on what a step is.
  9. ~~**FAB-307**~~ — **done**, see [DONE.md](DONE.md): `.allowsHitTesting(isVisible)` added to both chrome bars, plus VoiceOver wiring (chrome pinned visible, live `voiceOverStatusDidChangeNotification`, the `hasShownImmersiveHint` flag built and gated).
  10. ~~**FAB-308**~~ — **done**, see [DONE.md](DONE.md): the 4 hardcoded label/hint pairs in `ReadingChrome.swift` now go through `L10n` (the back button reuses an existing, already-translated, previously-unused key that also happens to match the accessibility spec's wording), plus the `SearchBar.placeholder` drive-by.
  11. ~~**FAB-309**~~ — **done**, see [DONE.md](DONE.md): `VersoTypography.UI`'s six tokens rebuilt on real text styles, plus the reading-view hardcodes (`ArticleHeader`, `ReadingTopBar` title, `EmptyState`) routed through them. The layout audit of chrome components (`SettingsRow`, `ThemeSwatch`'s fixed Settings-row frame, the list header, reader sheet detents) moves to FAB-334 as already decided in the amendment above, which deletes those components.
  12. ~~**FAB-333**~~ — **done**, see [DONE.md](DONE.md): reading measure collapse w/ OpenDyslexic & max size, stacks on top of #11. All 3 fix options now shipped — the padding-taper (2026-09-05), OpenDyslexic's per-family size step-down, and a new Margins control in the reader's font sheet (both 2026-09-06).
  13. ~~**FAB-310**~~ — **moved to FAB-334.** System controls are 44×44pt by default; the remaining offenders are all custom chrome the shell replaces. (The font stepper is still covered by #8.)
  14. ~~*(pulled out of FAB-322)* **"Add Article: no escape while saving"**~~ — **done 2026-09-05**: the ✕ now shows and cancels during `.saving`, so a hung parse no longer traps the user. See [DONE.md](DONE.md)'s FAB-322 entry for the one known gap (Readability.js's `WKWebView` isn't itself interruptible mid-flight).
  15. ~~**FAB-320**~~ — **moved to FAB-334.** System `EditMode` supplies both the red destructive action and the "N Selected" title.
  16. **FAB-319** — **split.** The empty-state CTA **done 2026-09-05** — see the struck bullet under FAB-319 for detail. The filter panel's "Clear all" and summary row move to FAB-334, which rehomes filters around `.searchable` anyway; FAB-319 stays open in BACKLOG for that remainder.

  *Post-launch polish — Backlog-status, fine to defer:*

  FAB-313 (VoiceOver label for the analytics toggle — **no longer folds into FAB-329**: closed 2026-09-05 without touching this, see below) → ~~FAB-323~~ (done, see [DONE.md](DONE.md)) → ~~FAB-325~~ (done, see [DONE.md](DONE.md): status badges + swipe tints, border contrast, divider correctness) → ~~FAB-329~~ (done, see [DONE.md](DONE.md): folder-row icon fixed; selection dot and heading levels absorbed by FAB-334; stepper and dividers already fixed elsewhere) → ~~FAB-324~~ (done, see [DONE.md](DONE.md): one `ThemeSwatch` component replaces the three; the Settings frame's Dynamic Type problem stays FAB-334 scope) → ~~FAB-326~~ (**moved to FAB-334** — system navigation supplies one back button, which is the entire fix) → ~~FAB-321~~ (done, see [DONE.md](DONE.md): read time replaces date on cards, VoiceOver row label wired up) → ~~FAB-317~~ (done, see [DONE.md](DONE.md): top padding now collapses with `isChromeVisible`, resolving the contradiction against the 2026-09-03 screenshots) → ~~FAB-318~~ (done, see [DONE.md](DONE.md): TTS transport row alignment + immersive hint pill; margins control stays FAB-333 scope) → ~~FAB-322~~ (done, see [DONE.md](DONE.md): section counts + spacing, radio-style date presets, no-source card fallback, VoiceOver-aware success-sheet timing; select-mode layout shift stays FAB-334 scope, Settings-icon placement left as-is per Fabio's call) → ~~FAB-328~~ (done, see [DONE.md](DONE.md): real SF Symbols, disabled-Continue hint, "Allow" CTA + equal-weight consent buttons, stale doc note; its last bullet closed as a side effect of FAB-327's fix, below) → ~~FAB-327~~ (done, minimum-fix scope, see [DONE.md](DONE.md): global Skip, not tour-only, + a page-dot row that shrinks as you advance, rather than cutting screens. The full restructure stays open in BACKLOG for a post-launch revisit) → ~~FAB-314~~ (done, see [DONE.md](DONE.md), deliberately last so it encodes the corrected passing state: `scripts/check_contrast.py` now enforces contrast in CI instead of the hand-maintained, overclaiming table; 2 genuine failures it found are FAB-336). This chain is now fully worked through.
- **Phase C — post-launch polish.** FAB-54 (highlighting) done 2026-09-01, and its follow-up FAB-303 (highlighting v2 — cross-block selection, formatting-aware spans, headings/lists/quotes) done 2026-09-02 — all 5 original steps plus all 3 named follow-ups (headings/lists/blockquotes joining selectable regions; merging with an existing highlight, same-block only; blockquote's colored accent bar) have shipped — see [DONE.md](DONE.md). FAB-277 (RSVP mode), FAB-278 (VoiceOver progress announcement) still need a UX decision from Fabio before implementation starts.

## iOS

### Phase 2 — Experience

- [ ] 🟡 **FAB-150** · [Phase 2] App Store release checklist  `Backlog` `Medium`
  Parent checklist for shipping Verso to the App Store after Phase 2 feature work ([FAB-51](https://linear.app/fabiosasseron/issue/FAB-51/phase-2-implement-scroll-position-saving) → [FAB-52](https://linear.app/fabiosasseron/issue/FAB-52/phase-2-implement-tagging-system) → [FAB-50](https://linear.app/fabiosasseron/issue/FAB-50/phase-2-implement-full-text-body-search) → [FAB-53](https://linear.app/fabiosasseron/issue/FAB-53/phase-2-implement-bulk-actions)).

  ## Signing & privacy (step 1 — done 2026-08-02, see [FAB-150-step1-signing-and-privacy.md](plans/FAB-150-step1-signing-and-privacy.md))

  - [x] Code signing: DEVELOPMENT_TEAM plumbed through all three targets, Distribution identity resolves automatically (no more hardcoded `Apple Development`)
  - [x] Register App ID `com.fabiosasseron.verso` + App Groups capability
  - [x] Register App ID `com.fabiosasseron.verso.ShareExtension` + App Groups capability
  - [x] Register App Group `group.com.fabiosasseron.verso`
  - [x] Remove inert iCloud ubiquity container declaration (`NSUbiquitousContainers`)
  - [x] `PrivacyInfo.xcprivacy` manifests for app + Share Extension, audited against actual API/data usage
  - [x] Single-source app/extension version numbers (`MARKETING_VERSION` / `CURRENT_PROJECT_VERSION`)
  - [x] App Store Connect app record created (public listing name `Verso Reader` as of 2026-08-25, renamed from the placeholder "Version Reader"; "Verso" alone was taken. In-app branding/docs stay "Verso")
  - [x] `xcodebuild archive` succeeds end to end for the `Verso` scheme with a Distribution identity

  ## Store & compliance

  - [x] App Store Connect metadata — subtitle (option 2), description, keywords, support URL — reviewed by Fabio and entered into ASC 2026-08-25
  - [x] Screenshots for required device classes — uploaded successfully 2026-08-25. The 2026-08-24 batch (1320×2868, 6.9") was correct; the earlier rejection was Fabio uploading into the wrong ASC slot (6.5" tab), not a dimension problem. See APP_STORE_LISTING.md.
  - [x] Privacy nutrition labels (App Store Connect questionnaire) — entered into ASC 2026-08-25
  - [x] Age rating questionnaire — completed in ASC 2026-08-25

  Copy/answers for all items above: [APP_STORE_LISTING.md](APP_STORE_LISTING.md) — reviewed by Fabio and pasted into ASC 2026-08-25.

  **Device targeting (2026-08-24):** `TARGETED_DEVICE_FAMILY` restricted to iPhone-only (`"1"`) across the `Verso`, `ShareExtension`, and `VersoTests` targets in `Verso/project.yml` — was universal (`"1,2"`, or unset defaulting to universal on the main target), which meant the app could install on iPad today despite FAB-131's iPad UI work being deferred. `ci.yml`'s fast smoke-check job destination changed from `platform=macOS,variant=Designed for iPad` (needs iPad idiom support to resolve) to `generic/platform=iOS`. **Verified 2026-08-25** — Claude Code confirmed both `ci.yml` jobs (Build Debug macOS, Build Release iOS device) passed green on PRs #326–#328, all merged after this change; no longer a risk.

  ## Release process

  - [x] TestFlight build for smoke testing — `release.yml` shipped successfully via GitHub Actions on 2026-08-23 (run `32651214255`, then a second run verifying the FAB-285–288 fixes and the pipeline optimization pass); the CI release path is proven, not just planned.
  - [x] App Review notes (Share Extension, iCloud folder access, etc.) — pasted into ASC 2026-08-25
  - [ ] Final binary submission
  - [ ] **QA note:** Fabio develops locally against the iOS 27 SDK (Xcode 27 beta); the CI release pipeline (step 3) builds against the iOS 26 SDK. Different SDKs can change system-provided behavior (control appearance, default animations, layout metrics), so a local Debug build isn't a reliable stand-in for what ships. Treat the **TestFlight build itself as the QA artifact** — install and check it on a real device before promoting, don't sign off from local builds. This gap closes on its own once Xcode 27 reaches GA and local/CI converge.

  ## Product docs

  * PRD §10 Phase 2: no in-app data export — articles remain user-owned Markdown in iCloud Drive (v1.7, 2026-05-10).

  ## Depends on

  Close or hand off after core Phase 2 issues are done.

### Bugs — found during FAB-311 PR review (Fabio, 2026-09-05)

- [ ] 🔵 **FAB-335** · Verify the theme sheet's stray dark rectangle is actually gone  `Todo` `Low`
  While reviewing FAB-311's font sheet, Fabio flagged a strip of uncolored space below the controls that didn't fill the drawer's rounded surface — caused by `ReadingControls`' fixed `presentationDetents` height not matching its content's natural height, leaving the leftover space uncovered by `colors.surface`. Fixed in `ReadingControls.body` (the container shared by both sheet variants) by expanding it to `maxHeight: .infinity` with a trailing `Spacer` pushing content to the top, so the surface color reaches every edge regardless of height.

  Fabio only screenshotted the **font** sheet (`.presentationDetents([.height(218)])`), but the fix lives in the shared container both variants render through, so the **theme** sheet (`.presentationDetents([.height(168)])`) should already be fixed too — same code path, different fixed height. Flagging as its own item rather than assuming: confirm on a real device/simulator that the theme sheet's drawer is also fully colored edge-to-edge with no gap. If it isn't, the shared fix didn't fully cover `themeControls`' shorter content and needs a follow-up.

### Design critique 2026-09-01 — contrast & accessibility

Source: [DESIGN_CRITIQUE_2026-09-01.md](DESIGN_CRITIQUE_2026-09-01.md). Section references below point into it. All contrast ratios are computed (WCAG 2.1 relative luminance), not eyeballed.

- [ ] 🟠 **FAB-310** · Touch targets below 44×44, against our own spec  `Todo` `High`
  ## Scope

  Critique §3.4. [accessibility-specs.md](accessibility-specs.md) §2.1 calls 44×44pt mandatory and names the font stepper explicitly.

  | Control | Actual | Where |
  |---|---|---|
  | Reader font size `A` − / `A` + | ~**14×17** / ~**20×24** — bare `Text("A")`, no frame | `ReadingControls.fontControls` |
  | Settings font size − / + | **32×32** | `SettingsView.readingSection` |
  | Reader line-spacing buttons | 44×**36** | `ReadingControls.fontControls` |
  | Onboarding "Skip" | ~**36×22** — bare text, no padding | `QuickTourView.skipButton` |
  | Search-bar clear `✕` | default symbol size, no frame | `SearchBar` |

  Spec §2.2 also requires 8pt of dead space between adjacent targets; the list header packs four 44pt buttons at `HStack(spacing: 2)`.

  The reader font stepper is handled in **FAB-311** along with the rest of that sheet's problems; the others belong here.

- [ ] 🟠 **FAB-313** · The analytics toggle has no VoiceOver label  `Todo` `High`
  ## Scope

  Critique §7.4. `SettingsView.privacySection` uses `Toggle("", isOn: $analyticsOptIn).labelsHidden()` with the visible label as a separate `Text`, so the switch announces with no name. Add `.accessibilityLabel(L10n.Settings.analyticsRowLabel)`.

  Small enough to fold into another Settings issue if convenient.

- [ ] 🔵 **FAB-336** · Fix the 2 contrast failures `scripts/check_contrast.py` surfaces  `Backlog` `Low`
  ## Scope

  Found by FAB-314's new CI check (see [DONE.md](DONE.md)), which replaced the hand-maintained tables in [accessibility-specs.md](accessibility-specs.md) §3.3. Both are real, live, currently-failing pairs — computed from `Colors.swift`'s actual hex values, not estimated:

  | Pair | Where | Ratio | Required |
  |---|---|---|---|
  | `placeholder` on `surface`, all 4 themes | `SearchBar`'s clear (`xmark.circle.fill`) icon | Paper 1.36:1 · Sepia 1.41:1 · Night 1.16:1 · Ink 1.12:1 | 3:1 non-text |
  | `error` on `surface`, Paper + Sepia | `VersoTextField`'s inline error caption, 13pt | Paper 4.46:1 · Sepia 4.07:1 | 4.5:1 (Night/Ink already pass) |

  Not touched by FAB-314 itself since picking new hex values is a design call. Low priority: the icon is only visible while actively typing in a search field with text entered, and the error caption only appears on a validation failure — neither is a first-run or common-path screen.

  ## Fix

  Darken/adjust `placeholder` and `error` (Paper/Sepia only for the latter) to clear their thresholds, preserving hue the way `textSecondary`'s v1.1 fix did (`accessibility-specs.md` §9). Re-run `scripts/check_contrast.py` — once both clear, its `KNOWN_FAILURES` entries for them should be deleted (the script prints a note when a tracked failure starts passing) and this issue moves to DONE.

### Design critique 2026-09-01 — reading view

- [ ] 🟠 **FAB-316** · The reader's top bar repeats the title directly below it  `Todo` `High`
  ## Scope

  Critique §6.4. The bar shows a one-line *truncated* copy of the article title, sitting directly above the same title set in full at 28pt bold. The eye reads the same sentence twice and the first reading is the broken one — in the most valuable strip of the screen.

  [accessibility-specs.md](accessibility-specs.md) §5.2 already decided the bar title should be `accessibilityHidden` while the article is visible; the visual redundancy is the same problem in the other channel.

  ## Fix

  Show the bar title only once the H1 has scrolled out of view. Scroll offset is already tracked precisely, so the condition is cheap.

### Design critique 2026-09-01 — article list

- [ ] 🟠 **FAB-319** · Filters are invisible once applied, and there's no way to clear them  `In Progress` `High`
  ## Scope

  Critique §5.1, §5.2. Once `FilterPanel` closes, the only signal that filters are active is a small count badge on the header icon — the same badge whose dark-theme contrast FAB-305 already fixed. If the filters match nothing, the user gets the `.searchMiss` empty state with no mention of the filters causing it and no way to clear them: **`FilterPanel` has no "Clear all"**, so tags must be deselected one by one and the date preset reset separately.

  This is the same concern behind the earlier "keep chips visible on empty states" decision, resurfacing after the chips were removed. The old chip bar had a real virtue — filter state was always on screen.

  Separately, **`EmptyState` has no call to action in any variant**. The `.empty` variant is what a brand-new user sees straight after a seven-screen onboarding, and it offers nothing to tap despite `AddArticleView` being one icon away. It is the highest-leverage screen in the app for activation and it is currently decorative.

  **Seen 2026-09-03 on iPhone SE, and the copy makes it worse.** The empty state reads "No articles yet" / *"Share an article from Safari to get started."* — so the one instruction on the screen sends the user **out of the app**, while the `+` button that does the same job sits about 40pt above the message, unmentioned. Content occupies the top third and roughly 500pt below it is empty. Fix the copy and the CTA together: an "Add your first article" button wired to `showAddArticle`, with the share-sheet route as the secondary line rather than the only one.

  ## Fix

  1. "Clear all" in the panel header, enabled when `activeFilterCount > 0` — **moved to FAB-334**, which rehomes `FilterPanel` around `.searchable` anyway.
  2. ~~"Add your first article" in `.empty`; "Clear filters" in `.searchMiss`~~ — **done 2026-09-05.** `EmptyState` takes an optional `onAction` closure and a per-variant CTA title, rendered as a real button between the headline and the (now secondary) subtext. `.empty` flips `showAddArticle`; `.searchMiss` clears search text, date preset, and tags. The `.empty` subheadline was reworded from "Share an article from Safari to get started." to "Or share one from Safari." now that it's the secondary route, not the only one.
  3. Consider a dismissible summary row under the header when filters are active ("2 tags · Past month ✕") — restores the chip bar's visibility without its width problems. **Moved to FAB-334** along with #1 — same rehoming.

  Also seen: the panel is a fixed `width: 320` — ~80% of a 393pt screen and **~85% of the 375pt iPhone SE**, leaving a dismiss strip of roughly 55pt, too narrow to read as "tap outside to close". Use a fraction with a maximum rather than a fixed width. And with zero tags in the library it still renders a "Search tags…" field above a lone "All tags" row, searching nothing — hide it when the tag list is empty.

- [ ] 🟠 **FAB-320** · Bulk select: destructive action isn't marked, and nothing shows a count  `Todo` `High`
  ## Scope

  Critique §5.6.

  **Delete isn't red.** `Button(role: .destructive)` combined with `.buttonStyle(.plain)` drops the role's colour, so "Delete" renders in plain `textPrimary` while "Mark read" sits in accent — the irreversible action is the *less* prominent of the two. The reader's overflow menu gets this right (red, with a trash icon), which makes the bulk case — deleting *several* articles at once — both the inconsistent one and the more dangerous one. Use `semanticColors.error`.

  **No selection count.** With one article selected the header still reads "Verso". iOS convention is "1 Selected", and it matters most immediately before a bulk delete. The confirmation dialog does show a count, but that is after the fact.


### Design critique 2026-09-01 — design system consistency

- [ ] 🟡 **FAB-326** · Five different ways to close or go back  `Backlog` `Medium`
  ## Scope

  Critique §3.10. Across the surfaces that have a dismiss control:

  | Surface | Treatment |
  |---|---|
  | Settings | chevron in a filled near-white circle, top-leading, title centred |
  | Add Article | ✕ in a filled near-white circle, top-leading, title centred |
  | Reader top bar | bare chevron, no circle, top-leading, title centred |
  | Filter panel | bare ✕, top-trailing, title leading |
  | Reader control sheets | bare ✕, top-trailing, floating over content |

  Leading vs trailing, circled vs bare, ✕ vs chevron — every axis varies, along no rule a user could learn. The circled variants also use a fill lighter than `surface`, so they read as system chrome rather than as part of the app.

  ## Fix

  Two patterns: push navigation gets a bare leading chevron; modal presentation gets a bare trailing ✕. Drop the circles. Overlaps with FAB-311, which removes the control sheets' ✕ entirely.

### Design critique 2026-09-01 — onboarding & settings

- [ ] 🟡 **FAB-327** · Onboarding is seven screens before the first article (full restructure)  `Backlog` `Medium`
  ## Scope

  Critique §4.1. `OnboardingFlowView` runs Welcome → Theme → Folder → Analytics consent → Tour 1 → Tour 2 → Tour 3. Exactly **one** is functionally required. For an app whose pitch is "less friction than Pocket", a seven-screen gate is the loudest possible contradiction of the positioning, and the page-dot row shows all seven on screen one — so the first thing Welcome communicates is "six more to go".

  **The minimum-fix half of this ticket is done** — see [DONE.md](DONE.md): Skip is now global from screen 1 (not tour-only), and the dot row shrinks as you advance instead of always showing 7. What's below is the larger option Fabio didn't choose for that pass; still open in case it's worth revisiting post-launch.

  * ~~**Skip only exists on the tour** (screens 5–7); theme and analytics can only be answered.~~ **Done**, see DONE.md.
  * **No back affordance.** `advance()` is forward-only; the `TabView` allows a backward swipe but nothing signals it and the dots aren't tappable.
  * **The theme picker runs before any content exists** — asking for a reading-theme choice with nothing to read, using a picker that also lives in Settings and the reading toolbar where it *is* contextual.
  * **The tour explains features for an empty library.** "Share to save" means nothing until there's something to share.

  ## Fix

  Cut to two required screens: Welcome and Folder. Move theme to first-article-open (a one-time inline pointer at the reading toolbar). Keep analytics consent but as a sheet on first list launch, not a gate. Convert the tour into an empty state that teaches by pointing at real UI — which also feeds FAB-319.

  ## Seen 2026-09-03 (Ink)

  The onboarding screens were captured on 2026-09-03, so this is no longer a source-only prediction. Everything above holds. Two additions from seeing it:

  * **The composition has large vertical voids.** Every screen is `Spacer()` / content / `Spacer()` / CTA, so the content floats in the middle with 180–250pt of nothing above and below it, and reads as three unrelated elements rather than one screen. The tour's `TourStep(...).frame(height: 200)` widens the gap further, leaving the headline stranded far above its own icon.
  * **The page-dot row nearly touches the Continue button** — `.padding(.bottom, VersoSpacing.md)` puts it about 16pt under a 50pt button, so it reads as attached to the CTA rather than as screen furniture.

  The dots did confirm the count: the theme picker is dot 2 of 7, and tour step 1 is dot 5 of 7.

### Phase E — native iOS shell (1.1)

- [ ] 🟠 **FAB-334** · [Epic] Native iOS shell: replace custom chrome with system components (Liquid Glass)  `Todo` `High`
  ## Goal

  Make Verso look and behave like a native iOS app — Liquid Glass chrome, a bottom-anchored search field, system navigation, system list and form styling — **without touching the reading view**, which stays exactly as it is.

  Decided with Fabio 2026-09-03: **native shell, custom reading room.** The article list, settings, search, navigation and toolbars adopt system components; the reading surface keeps its bespoke typography, its four themes and its custom chrome. This is how Reeder and Matter are built, and it puts the paper identity where it earns its keep instead of fighting the platform everywhere else.

  ## Why this is an epic and not a skin

  Liquid Glass is not something you apply. Build against the iOS 26 SDK (CI already pins Xcode 26.6) and system components adopt it automatically on iOS 26+, falling back below. The problem is that Verso has almost no system components for it to apply to:

  | System affordance | Uses in Verso today |
  |---|---|
  | `.searchable` | **0** — hand-built `SearchBar` |
  | `.toolbar` | **1**, and it is `.toolbar(.hidden)` |
  | `List` | 1 (the article list). Settings is a hand-built `ScrollView` of `HStack`s |
  | `.buttonStyle(.plain)` | **43** — every button opts out of system styling |

  Plus `VersoNavigationBar`, a custom `headerRow` standing in for a navigation bar, and `VersoButtonStyle`. So the work is deleting roughly a thousand lines of re-implemented chrome and letting the system draw it.

  ## Why it changes Phase D's sequencing

  Most of the chrome issues in Phase D are defects in those re-implementations. Adopt the system component and the defect stops existing — fixing them first is work thrown away.

  **Absorbed by this epic (the custom component is deleted, so its bugs go with it):**

  | Issue | What the system gives you instead |
  |---|---|
  | FAB-310 | System controls are 44×44pt by default |
  | FAB-320 | System `EditMode` gives a red destructive action and an "N Selected" title |
  | FAB-322's select-mode layout shift | `EditMode` owns the checkbox column; content width stops changing |
  | FAB-326 | One system back button instead of five dismiss treatments |
  | FAB-329 (partly) | An inset-grouped `Form` gives checkmarks, real section headers, value+chevron rows |
  | FAB-325's divider half | System `List` draws its own separators |
  | FAB-319's filter panel | A system menu / sheet; `.searchable` supplies the bottom search field |
  | FAB-311's ✕ collision | A system sheet with a grabber and no competing close button |

  **Not absorbed — do these in 1.0 as already sequenced.** Everything in the content and reading layers survives untouched: FAB-315 + FAB-332 (parser), FAB-330, FAB-331, FAB-312, FAB-308, FAB-307, FAB-333, FAB-316, FAB-317, FAB-321, FAB-323, FAB-306, FAB-327, FAB-328.

  **FAB-309 is the one to split, not defer.** Its two halves behave differently:

  * *Rebuilding `VersoTypography.UI` on text styles* is cheap, mechanical, and **survives this epic** — system components need correct text styles anyway, and `Typography.Reading` is untouched by the shell either way. Keep it in 1.0.
  * *The layout audit* (`lineLimit(1)` sweeps, fixed frames, sheet detents on custom components) is largely throwaway, because most of those components are deleted here. Defer the parts that touch chrome; keep the parts that touch the reading view and onboarding.

  The counter-argument, which is real: shipping 1.0 ignoring the system text size means a reading app that ignores it for however long 1.1 takes, and enlarged-text readers are close to this app's core audience. That is the reason the token half stays in 1.0 rather than waiting.

  ## Explicitly out of scope

  The reading view. Beyond the design decision, there is a hard technical reason: the body is not SwiftUI. `HighlightableRegionText` wraps a custom `HighlightableUITextView` per contiguous region, needed for FAB-54/FAB-303 highlighting, and it overrides `draw(_:)` — as FAB-304's second cause made vivid. Nothing about Liquid Glass adoption should go near it.

  Also out of scope: the Share Extension (FAB-323 handles its theming separately) and the iPad epic (FAB-131, FAB-152–162), which stays deferred.

  ## Open decisions — needed before implementation starts

  1. **Deployment target — DECIDED 2026-09-03: raise to iOS 26.0.** Currently **iOS 16.0** (`Verso/project.yml`). The `glassEffect` family is iOS 26-only, so a real Liquid Glass shell needs either `if #available(iOS 26, *)` branches throughout or a raised floor. Verso has no installed base — nobody is on an old build because there is no old build — so this is the cheapest moment in the app's life to raise it, and it only gets more expensive after 1.0 ships.

     ⚠️ **Do not make this change on `main` yet.** 1.0 is one step from final binary submission (FAB-150) and is expected to ship at iOS 16. Raising the floor on `main` changes what 1.0 ships as and would cut its addressable devices for no benefit, since 1.0 uses no iOS 26 API. Land it as the first commit on the 1.1 branch instead (phase 1 below). If 1.0 slips far enough that it would ship after the shell work anyway, revisit — but that should be a deliberate call, not a side effect.

     Worth confirming current iOS 26 adoption before the branch opens; it shipped a year ago, so the cost is probably modest, but the number should be looked up rather than assumed.
  2. **What happens to the four themes in the shell.** The decision above implies the shell follows light/dark (driven by `VersoTheme.isDark`, which `ContentView.preferredColorScheme` already plumbs) while Paper/Sepia/Night/Ink survive in the reader. Confirm that is acceptable before building — it is a visible reduction outside the reading view.
  3. **Whether onboarding is rebuilt here or in FAB-327.** FAB-327 already proposes cutting seven screens to two. Doing both at once is more coherent than restyling seven screens and then deleting five of them.
  4. **`.searchable` placement and scope.** Today search is a custom expanding header field over title + body + site + URL. The system field changes both the interaction and where filters live (FAB-319).

  ## Direction approved 2026-09-03

  Fabio reviewed a side-by-side prototype (article list + reading view, all four themes, current chrome vs. glass) and approved the direction. The open worry going in — that translucent chrome would grey out the warm Paper and Sepia grounds — did not materialise in the mock.

  **Caveat to carry forward:** that prototype was HTML, `backdrop-filter: blur(26px) saturate(190%)` over a theme-derived veil. It is a colour-and-legibility approximation, not Liquid Glass. It has no specular edge, no rim refraction, and no scroll or tilt response — and those are exactly the properties that could still misbehave over a warm ground. **The direction is approved; the material is not yet verified.**

  Before committing to phases 3–6 below, spend a throwaway SwiftUI spike on the 1.1 branch: one screen, real `glassEffect`, all four themes, on device. If the real material dulls Paper and Sepia in a way the mock didn't predict, the fallback is opaque chrome in the light themes and glass in the dark ones — worth knowing before the shell is half-rebuilt, not after.

  ## Suggested phasing

  Each phase should build, run and be shippable on its own — no long-lived branch.

  1. **Foundations.** Decide and raise the deployment target. `VersoTypography.UI` is already rebuilt on text styles — that part of FAB-309 shipped in 1.0, so this phase starts from there rather than doing it. No visual redesign yet.
  2. **Settings.** The lowest-risk screen and the biggest immediate win: hand-built `ScrollView` → `Form` with inset-grouped sections. Absorbs most of FAB-329, FAB-325's dividers, part of FAB-310.
  3. **Navigation shell.** Remove `.toolbar(.hidden, for: .navigationBar)`, retire `VersoNavigationBar` and the custom `headerRow`, adopt real navigation bars and toolbars. Absorbs FAB-326. Highest-risk phase — this is the code FAB-304's cause 1 lived in, and `VersoMainSplitView`'s selection-driven collapse is load-bearing.
  4. **Search and filters.** `.searchable` with the iOS 26 bottom field; rehome the filter panel. Absorbs FAB-319.
  5. **List.** System `List` styling, `EditMode` for bulk select. Absorbs FAB-320 and FAB-322's layout shift.
  6. **Sweep.** Retire `VersoButtonStyle` where a system style fits; audit the 43 `.buttonStyle(.plain)` sites; re-run the large-text and SE passes.

  ## Verify

  Re-run the full screenshot matrix afterwards — all four themes, onboarding, immersive, large Dynamic Type, iPhone SE — as in `docs/printscreens/design-review-2026-09-03/`. The critique's §8 list is the checklist. Pay particular attention to translucent chrome over the warm Paper background: Liquid Glass samples what is behind it, and these materials were not tuned against cream.

  ## References

  * [DESIGN_CRITIQUE_2026-09-01.md](DESIGN_CRITIQUE_2026-09-01.md) — §3.4, §3.5, §5.1, §5.6, §7.1, §7.5 are the findings this absorbs
  * [navigation-patterns.md](navigation-patterns.md), [DESIGN_SYSTEM_FOUNDATIONS.md](DESIGN_SYSTEM_FOUNDATIONS.md)
  * [SwiftUI search enhancements in iOS/iPadOS 26](https://nilcoalescing.com/blog/SwiftUISearchEnhancementsIniOSAndiPadOS26/) · [Adapting search to Liquid Glass](https://www.createwithswift.com/adapting-search-to-the-liquid-glass-design-system/)

### Phase 3 — Expansion

- [ ] 🔵 **FAB-131** · [Phase 4] iPad Support  `Backlog` `Low`
  ## Overview

  Broad epic to bring Verso to iPad. The file-first, SwiftUI architecture has no blockers — this is purely UI and navigation adaptation work.

  ## Work Areas

  ### 1\. Adaptive Layout

  * Two-column layout on iPad using `NavigationSplitView` (article list + reading view side-by-side)
  * Responsive single-column fallback for compact size classes (Split View / Slide Over)
  * Landscape and portrait orientation support

  ### 2\. Reading Experience Optimizations

  * Max-width content column for comfortable reading on large screens
  * Typography and spacing adjustments for iPad reading distance
  * Larger tap targets where appropriate

  ### 3\. Keyboard & Trackpad Support

  * Full keyboard navigation (arrow keys, space to scroll, shortcuts for status changes)
  * Pointer hover states on interactive elements
  * Context menus on article list items

  ### 4\. Multitasking & System Integration

  * Stage Manager compatibility
  * Split View / Slide Over layout correctness
  * Share Extension correctness in multitasking contexts

  ### 5\. QA & Polish

  * Testing across 11-inch and 13-inch iPad sizes
  * Orientation and multitasking configuration testing
  * Visual regression pass vs. iPhone experience

  ## Notes

  Sub-tasks will be broken out when this phase begins. No architectural changes to data layer or sync are expected.


### Phase 4 — XcodeGen: iPad orientations + multitasking-related plist flags

- [ ] 🟡 **FAB-154** · Phase 4 — XcodeGen: iPad orientations + multitasking-related plist flags  `Backlog` `Medium`
  ## Scope

  * Add landscape (and any missing orientations) under `UISupportedInterfaceOrientations_iPad` in [`Verso/project.yml`](<Verso/project.yml>) / Info.plist.
  * Re-evaluate `UIRequiresFullScreen` for iPad multitasking (Split View / Stage Manager) per product decision.

  ## Depends on

  Design sign-off: [FAB-153](https://linear.app/fabiosasseron/issue/FAB-153/phase-4-approve-ipad-mockups-design-sign-off)


### Phase 4 — Hybrid NavigationSplitView root (regular vs compact)

- [ ] 🟠 **FAB-155** · Phase 4 — Hybrid NavigationSplitView root (regular vs compact)  `Backlog` `High`
  ## Scope

  Refactor post-onboarding root ([`ContentView.swift`](<Verso/Sources/App/ContentView.swift>)) to **hybrid** navigation:

  * **Regular** horizontal width: `NavigationSplitView` — sidebar = article list; detail = reader + stack.
  * **Compact** (portrait iPad narrow, Slide Over, iPhone): single-column `NavigationStack` behavior matching current app.

  ## References

  * [docs/navigation-patterns.md](<docs/navigation-patterns.md>)
  * Figma: iPad Phase 4 mockups page

  ## Depends on

  [FAB-153](https://linear.app/fabiosasseron/issue/FAB-153/phase-4-approve-ipad-mockups-design-sign-off)


### Phase 4 — Article list adaptive layout (iPad / compact)

- [ ] 🟡 **FAB-156** · Phase 4 — Article list adaptive layout (iPad / compact)  `Backlog` `Medium`
  ## Scope

  Adapt [`ArticleListView`](<Verso/Sources/Screens/ArticleList/ArticleListView.swift>) for split sidebar and compact: padding, toolbar, search/filters, optional wide layout per Figma [FAB-152](https://linear.app/fabiosasseron/issue/FAB-152/phase-4-figma-ipad-mockups-paper-portrait-landscape-new-page).

  ## Blocked by

  [FAB-155](https://linear.app/fabiosasseron/issue/FAB-155/phase-4-hybrid-navigationsplitview-root-regular-vs-compact)


### Phase 4 — Reading view: split behavior + 680pt column

- [ ] 🟠 **FAB-157** · Phase 4 — Reading view: split behavior + 680pt column  `Backlog` `High`
  ## Scope

  [`ArticleReaderView`](<Verso/Sources/Screens/ArticleReader/ArticleReaderView.swift>): max content width **680pt** on iPad; correct behavior when shown in split detail vs full-screen stack.

  ## Blocked by

  [FAB-155](https://linear.app/fabiosasseron/issue/FAB-155/phase-4-hybrid-navigationsplitview-root-regular-vs-compact)


### Phase 4 — Settings and modals on iPad

- [ ] 🟡 **FAB-158** · Phase 4 — Settings and modals on iPad  `Backlog` `Medium`
  ## Scope

  Sheet width, form readability, pushed settings flows in split context ([`SettingsView`](<Verso/Sources/Screens/Settings/SettingsView.swift>) and children).

  ## Blocked by

  [FAB-155](https://linear.app/fabiosasseron/issue/FAB-155/phase-4-hybrid-navigationsplitview-root-regular-vs-compact)


### Phase 4 — Onboarding and launch on iPad

- [ ] 🟡 **FAB-159** · Phase 4 — Onboarding and launch on iPad  `Backlog` `Medium`
  ## Scope

  [`LaunchView`](<Verso/Sources/Screens/Launch/LaunchView.swift>), [`OnboardingFlowView`](<Verso/Sources/Screens/Onboarding/OnboardingFlowView.swift>) and steps: layout for large screens and both orientations.

  ## Blocked by

  [FAB-155](https://linear.app/fabiosasseron/issue/FAB-155/phase-4-hybrid-navigationsplitview-root-regular-vs-compact)


### Phase 4 — Add article + tags sheet on iPad

- [ ] 🔵 **FAB-160** · Phase 4 — Add article + tags sheet on iPad  `Backlog` `Low`
  ## Scope

  [`AddArticleView`](<Verso/Sources/Screens/ArticleList/AddArticleView.swift>), [`ArticleTagsEditorSheet`](<Verso/Sources/Screens/ArticleReader/ArticleTagsEditorSheet.swift>): width, detents, keyboard.

  ## Blocked by

  [FAB-155](https://linear.app/fabiosasseron/issue/FAB-155/phase-4-hybrid-navigationsplitview-root-regular-vs-compact)


### Phase 4 — Share extension adaptive UI

- [ ] 🟡 **FAB-161** · Phase 4 — Share extension adaptive UI  `Backlog` `Medium`
  ## Scope

  Share extension target: adaptive layout for iPad orientations and widths after plist updates ([FAB-154](https://linear.app/fabiosasseron/issue/FAB-154/phase-4-xcodegen-ipad-orientations-multitasking-related-plist-flags)) and navigation patterns ([FAB-155](https://linear.app/fabiosasseron/issue/FAB-155/phase-4-hybrid-navigationsplitview-root-regular-vs-compact)).

  ## Blocked by

  [FAB-154](https://linear.app/fabiosasseron/issue/FAB-154/phase-4-xcodegen-ipad-orientations-multitasking-related-plist-flags), [FAB-155](https://linear.app/fabiosasseron/issue/FAB-155/phase-4-hybrid-navigationsplitview-root-regular-vs-compact)


### Phase 4 — QA: a11y, Dynamic Type, orientation on iPad

- [ ] 🟡 **FAB-162** · Phase 4 — QA: a11y, Dynamic Type, orientation on iPad  `Backlog` `Medium`
  ## Scope

  Regression pass: VoiceOver order in split layout, touch targets, Dynamic Type, orientation changes, Reduce Motion per [`docs/accessibility-specs.md`](<docs/accessibility-specs.md>).

  ## Blocked by

  [FAB-156](https://linear.app/fabiosasseron/issue/FAB-156/phase-4-article-list-adaptive-layout-ipad-compact), [FAB-157](https://linear.app/fabiosasseron/issue/FAB-157/phase-4-reading-view-split-behavior-680pt-column), [FAB-158](https://linear.app/fabiosasseron/issue/FAB-158/phase-4-settings-and-modals-on-ipad), [FAB-159](https://linear.app/fabiosasseron/issue/FAB-159/phase-4-onboarding-and-launch-on-ipad), [FAB-160](https://linear.app/fabiosasseron/issue/FAB-160/phase-4-add-article-tags-sheet-on-ipad), [FAB-161](https://linear.app/fabiosasseron/issue/FAB-161/phase-4-share-extension-adaptive-ui) (share extension)


## Web

### Phase 1 — Foundation

- [x] 🟡 **FAB-165** · [WEB] Phase 1: Scaffold Next.js app + port design system tokens  `Completed` `Medium`
  Initialize verso-web/ as a Next.js 15+ project with TypeScript strict mode, Tailwind CSS, and port design system tokens from iOS.

  ## Completed Tasks

  * [x] Created verso-web/ directory at repo root
  * [x] Initialized Next.js 16.2.6 with TypeScript v5
  * [x] Configured TypeScript with strict mode (`strict: true`, `isolatedModules`, `noEmit`)
  * [x] Set up Tailwind CSS 4 with PostCSS integration
  * [x] Created app directory structure:
    - `app/` — Next.js App Router
    - `app/components/` — UI components (ArticleCard, SearchBar, FilterChipBar, MarkdownRenderer, etc.)
    - `app/providers/` — Context providers (ThemeProvider)
    - `hooks/` — Custom React hooks (useArticleLibrary)
    - `services/` — Utility services
    - `types/` — TypeScript definitions
    - `public/fonts/` — Custom fonts (OpenDyslexic)
  * [x] Ported design system tokens to `app/globals.css`:
    - Fixed tokens: spacing, corner radius, typography (UI + reading)
    - Theme tokens for all 4 themes (Paper, Sepia, Night, Ink)
    - Color roles: primary/secondary text, background, surface, accent, border, placeholder, error, warning, success
  * [x] Created root layout (`app/layout.tsx`) with ThemeProvider
  * [x] Created home page (`app/page.tsx`) with article listing, search, filtering, and theme switcher
  * [x] Configured package.json with core dependencies: `next`, `react`, `react-dom`, `react-markdown`, `gray-matter`, `idb`
  * [x] Added scripts: `npm run dev`, `npm run build`, `npm start`
  * [x] Verified dev server starts cleanly: `npm run dev` → http://localhost:3000 (startup time: 747ms)

  ## Verification

  - [x] TypeScript strict mode enabled and checked
  - [x] Tailwind CSS rendering correctly
  - [x] Design tokens applied across all 4 themes
  - [x] Dev server runs without errors
  - [x] All required directories created
  - [x] File System Access API integration ready

  ## Completion Date

  **2026-06-15** — Ready for Phase 2 implementation.

### Phase 3 — Expansion

- [ ] 🟡 **FAB-171** · [WEB] Phase 4: URL article ingestion (fetch + Readability + Markdown)  `Backlog` `Medium`
  Allow saving articles from URLs into the iCloud Drive folder, matching the iOS Share Extension capability.

  ## Tasks

  * `AddArticleModal` — URL input field + save button
  * Next.js API route `/api/parse` (server-side, avoids CORS):
    * Fetch HTML from URL
    * Parse with `@mozilla/readability` (same engine iOS uses)
    * Convert to Markdown with `turndown`
    * Return structured article data
  * Write `.md` file to FS handle with correct frontmatter
  * Duplicate detection — check existing articles by URL before writing
  * Set `export const maxDuration = 30` on the API route for slow sites

  ## Verification

  Enter a URL → article saved as `.md` in iCloud folder → file appears in iOS app after sync with correct frontmatter.

- [ ] 🔵 **FAB-172** · [WEB] Phase 4: Bulk import (Pocket, Instapaper, GoodLinks)  `Todo` `Low`
  Port the iOS import parsers to TypeScript for bulk importing articles from external services.

  ## Tasks

  * Import screen with file picker
  * Port parsers from `Verso/Sources/Services/`:
    * `PocketParser.swift` → Pocket CSV
    * `InstapaperParser.swift` → Instapaper CSV
    * `GoodLinksParser.swift` → GoodLinks JSON
  * Progress tracking with per-file status (parsing / writing / done / failed)
  * Duplicate detection before writing each file

  ## Verification

  Upload a Pocket CSV export → articles appear as `.md` files in the iCloud folder, viewable in iOS app.

- [ ] 🔵 **FAB-173** · [WEB] Phase 5: PWA manifest + service worker + offline support  `Todo` `Low`
  Make Verso Web an installable PWA that works offline for already-loaded articles.

  ## Tasks

  * PWA manifest (name, icons, display: standalone, theme colors per Verso Paper theme)
  * Service worker via `next-pwa` — cache app shell + article content
  * Offline fallback page with clear messaging
  * "Add to Dock" / install prompt on supported browsers
  * Settings page: theme default, font default, folder re-selection

  ## Verification

  Install app to macOS Dock → opens as standalone window → navigate and read cached articles → works fully offline.

- [ ] 🔵 **FAB-174** · [WEB] Phase 5: TTS, related articles, tags, keyboard shortcuts  `Todo` `Low`
  Polish and power-user features for the reading experience.

  ## Tasks

  * TTS via Web Speech API (`SpeechSynthesisUtterance`): play/pause button in reading controls, 3 speed presets (0.75×, 1×, 1.5×)
  * Related articles section at end of article — port Jaccard similarity algorithm from `RelatedArticlesService.swift` (threshold 4%, max 3 results)
  * Tag editor modal — add/remove tags, persisted to YAML frontmatter
  * Keyboard shortcuts:
    * `j` / `k` — next/previous article in list
    * `o` — open selected article
    * `r` — mark as read
    * `Esc` — back to list

  ## Verification

  TTS plays article aloud at 3 speeds. Related articles appear. Tags edited in web show in iOS. Keyboard shortcuts navigate the app.

- [ ] 🟡 **FAB-175** · [WEB] Docs: Update HANDOFF.md and PRD for web platform  `Todo` `Medium`
  Update the project documentation to reflect the new web platform.

  ## Tasks

  * `docs/HANDOFF.md`: Add "Web Platform" section describing `verso-web/`, File System Access API approach, browser requirements (Chrome/Edge 86+)
  * `docs/PRD_MinimalistReaderApp.md`: Remove "Web app" from "Out of Scope"; add web as Phase 2 platform with its own feature tier
  * `verso-web/README.md`: Setup instructions, browser requirements, iCloud Drive folder setup on macOS, Vercel deployment notes

  ## Verification

  A new contributor can read HANDOFF.md and understand how to set up and run both iOS and web versions.


## Design / UX

### Phase 4 — Figma iPad mockups (Paper, portrait + landscape, new page)

- [ ] 🟠 **FAB-152** · Phase 4 — Figma iPad mockups (Paper, portrait + landscape, new page)  `In Review` `High`
  ## Delivered

  New Figma page **iPad — Phase 4 mockups (Paper)** with portrait + landscape device frames for all major flows (launch, onboarding steps, home, add article, reading, tags sheet, settings + subflows, share extension), plus a **hybrid split-view reference** (list sidebar **320pt** + reader with **680pt max** body column — see hybrid frame `114:45`).

  **Open in Figma:** [https://www.figma.com/design/WCPHZNg1my8VSSMbLO5bvX/Reader-UI?node-id=113-45](<https://www.figma.com/design/WCPHZNg1my8VSSMbLO5bvX/Reader-UI?node-id=113-45>)

  ## Acceptance (for sign-off)

  - [X] **Structure / orientation / hybrid spec** — Verified 2026-05-11 (issue comment): all flows, portrait + landscape pairs, hybrid `NavigationSplitView` + 320pt list / 680pt reading column documented in Figma.
  - [ ] **Paper-only high-fidelity** — Open: most frames still use placeholder copy *Paper theme · placeholder for high-fidelity pass*; apply tokens from `docs/DESIGN_TOKENS.md` / `docs/COMPONENT_SPECS.md` in Figma.
  - [ ] **Stakeholder approval** — Record on [FAB-153](https://linear.app/fabiosasseron/issue/FAB-153/phase-4-approve-ipad-mockups-design-sign-off) after high-fidelity pass.

  ## References

  * Plan: Phase 4 iPad (hybrid NavigationSplitView)
  * [docs/navigation-patterns.md](<https://github.com/fabiosasseron/reader/blob/main/docs/navigation-patterns.md>)


### Phase 4 — Approve iPad mockups (design sign-off)

- [ ] 🟠 **FAB-153** · Phase 4 — Approve iPad mockups (design sign-off)  `In Review` `High`
  ## Purpose

  Gate **implementation** until iPad Paper mockups are reviewed and approved.

  ## When closing

  - [X] Reviewed page: [Reader UI — iPad Phase 4](<https://www.figma.com/design/WCPHZNg1my8VSSMbLO5bvX/Reader-UI?node-id=113-45>) — structure + hybrid `114:45` (2026-05-11 audit comment)
  - [X] Hybrid behavior (split landscape / stack portrait) matches product intent
  - [X] Reading column max width (680pt) confirmed (Figma + `ArticleReaderView`)
  - [X] Comment or reaction recorded for audit trail (2026-05-11)

  **Remaining before Done:** Final stakeholder approval after **Paper high-fidelity** replaces placeholders in Figma (see [whysasse/verso-app#190](https://linear.app/fabiosasseron/issue/FAB-152/phase-4-figma-ipad-mockups-paper-portrait-landscape-new-page) description + comment).

  ## Unblocks

  [whysasse/verso-app#190](https://linear.app/fabiosasseron/issue/FAB-152/phase-4-figma-ipad-mockups-paper-portrait-landscape-new-page) / [whysasse/verso-app#191](https://linear.app/fabiosasseron/issue/FAB-153/phase-4-approve-ipad-mockups-design-sign-off) sign-off → then XcodeGen + NavigationSplitView polish (see [whysasse/verso-app#194](https://linear.app/fabiosasseron/issue/FAB-156/phase-4-article-list-adaptive-layout-ipad-compact) and related).


## Infra / Docs

### Phase 1 — Foundation

- [ ] 🔵 **FAB-151** · [Docs] PRD v1.7 — Phase 2 roadmap (no in-app export; tagging in Phase 2)  `Backlog` `Low`
  Documentation alignment shipped in repo:

  * `docs/PRD_MinimalistReaderApp.md` v1.7 (2026-05-10)
  * §10 Phase 2: removed data export deliverable; added explicit file-first note; moved tagging into Phase 2 roadmap; §9 risk row aligned

  No app implementation — tracking only for changelog / cross-link with [FAB-150](https://linear.app/fabiosasseron/issue/FAB-150/phase-2-app-store-release-checklist).


## Other

### Uncategorized

- [ ] 🔵 **FAB-277** · [Phase 3] RSVP reading mode  `Backlog` `Low`
  Rapid Serial Visual Presentation — displays article words one at a time in the center of the screen, eliminating eye movement and increasing potential reading speed.

  ## Concept

  The reader taps a button in the reading view to enter RSVP mode. Words flash at a configurable WPM rate. The reader can pause, rewind a sentence, and exit back to the normal scroll position. A visual rhythm cue (e.g. a brief color flash on the focal letter) helps the eye lock on.

  ## Scope

  * **Trigger:** RSVP button in the reading view toolbar (alongside TTS)
  * **Speed presets:** 150, 250, 350, 500 WPM — adjustable in Settings
  * **Controls:** Play/Pause · Rewind sentence · Exit (returns to scroll position)
  * **Typography:** Single word centered, large size, using the current reading font + theme
  * **Chunking:** 1 word per flash (default); consider 2-word chunks for fluent readers
  * **Pause on punctuation:** Slightly longer pause after `.`, `,`, `!`, `?` for natural rhythm
  * **Reduce Motion:** Disable auto-play; show one word at a time with manual tap-to-advance
  * **Accessibility:** VoiceOver should announce current word and expose play/pause controls

  ## Open questions

  * Should WPM be a free slider or locked to presets?
  * Persist last-used WPM across sessions?
  * iOS only first, or Web simultaneously?

  ## Notes

  No new data model needed — tokenize the same `ArticlePlainText` already used for TTS. Can reuse `TTSService` word boundaries for pause timing.



- [ ] 🔵 **FAB-278** · Reading-progress VoiceOver value: percent → time remaining  `Backlog` `Low`
  `ScrollProgress.swift`'s accessibility value currently announces scroll percentage ("73 percent"). Found during the localization step-4 view-wiring pass: `UI_COPY.md` had documented this exact spot as "{N} minutes remaining" — including real CLDR plural handling in the codegen script — but no code ever consumed it, so the doc was stale and has been corrected to match shipped behavior (percent).

  Time-remaining is the more useful announcement for VoiceOver users (a raw percentage doesn't tell you how much reading is left), but it requires the progress bar to compute elapsed/remaining estimated time at the current scroll offset, which `ScrollProgress` doesn't currently have access to. Worth a deliberate UX call rather than a default.

  No app implementation yet — tracking only.



