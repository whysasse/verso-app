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

**28 open issues** across iOS, Web, Design, and Infra (recounted 2026-09-08, +FAB-338 opened same day, -FAB-319 closed 2026-09-14 — the inline "which ones are done" enumeration this line used to carry had drifted out of sync with actual closures several times over, so it's dropped in favor of just the count; DONE.md is the actual record of what's closed). 30 were opened 2026-09-01/03 from [DESIGN_CRITIQUE_2026-09-01.md](DESIGN_CRITIQUE_2026-09-01.md): FAB-306–329 (critique findings) and FAB-331–333 (found in the 2026-09-03 Ink + onboarding screenshot pass). **FAB-334** is the 1.1 native-shell epic agreed 2026-09-03 — read it before picking up any chrome issue, since it absorbs several.

## Working mode — back to normal (Fabio back at his Mac, 2026-09-08)

2026-09-05–07 ran under a deferred-verification mode: Fabio was away from his Mac/device, so issues were planned, implemented, and verified with `xcodebuild` only, each merged straight to `main` without the usual per-PR manual check, and everything queued in **[PENDING_TESTS.md](PENDING_TESTS.md)** for one on-device batch pass once he was back. That pass happened 2026-09-08 — the whole queued batch confirmed good, plus 3 small findings (**FAB-337**) fixed on the spot. See PENDING_TESTS.md's Done section for the record. Normal per-PR verification resumes from here.

## Current sequencing (iPhone-only work, agreed with Fabio 2026-08-24)

Excludes the iPad epic (FAB-131, FAB-152–162) and the Phase 3 expansion backlog, which are deferred past this release.

- **Phase A — ship this release.** FAB-163 and FAB-164 done (see [DONE.md](DONE.md)). FAB-150's Store & compliance checklist is done — Fabio reviewed and entered all ASC metadata 2026-08-25 (see [APP_STORE_LISTING.md](APP_STORE_LISTING.md)). Remaining: the final binary submission itself — **now waits behind FAB-334** (Fabio, 2026-09-12: do the native shell before launching, not after — see FAB-334's Decision #2 correction below). MARKETING_VERSION stays `1.0`; the first submission ships with the shell already in it.
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
  16. ~~**FAB-319**~~ — **done**, see [DONE.md](DONE.md). The empty-state CTA shipped 2026-09-05; the filter panel's "Clear all" and summary row shipped 2026-09-14 as part of FAB-334 phase 5, which rehomed filters around `.searchable` anyway.
  17. ~~**FAB-316**~~ — **done**, see [DONE.md](DONE.md). Was never actually in this numbered list despite being marked "not absorbed — do in 1.0" further down (line ~266) — a real gap, caught 2026-09-08 confirming release readiness, not a duplicate of anything above. Top bar's title `Text` now only shows once the H1 scrolls out of view (visually and to VoiceOver), closing accessibility-specs.md §5.2's matching requirement as the same fix.

  *Post-launch polish — Backlog-status, fine to defer:*

  FAB-313 (VoiceOver label for the analytics toggle — **no longer folds into FAB-329**: closed 2026-09-05 without touching this, see below) → ~~FAB-323~~ (done, see [DONE.md](DONE.md)) → ~~FAB-325~~ (done, see [DONE.md](DONE.md): status badges + swipe tints, border contrast, divider correctness) → ~~FAB-329~~ (done, see [DONE.md](DONE.md): folder-row icon fixed; selection dot and heading levels absorbed by FAB-334; stepper and dividers already fixed elsewhere) → ~~FAB-324~~ (done, see [DONE.md](DONE.md): one `ThemeSwatch` component replaces the three; the Settings frame's Dynamic Type problem stays FAB-334 scope) → ~~FAB-326~~ (**moved to FAB-334** — system navigation supplies one back button, which is the entire fix) → ~~FAB-321~~ (done, see [DONE.md](DONE.md): read time replaces date on cards, VoiceOver row label wired up) → ~~FAB-317~~ (done, see [DONE.md](DONE.md): top padding now collapses with `isChromeVisible`, resolving the contradiction against the 2026-09-03 screenshots) → ~~FAB-318~~ (done, see [DONE.md](DONE.md): TTS transport row alignment + immersive hint pill; margins control stays FAB-333 scope) → ~~FAB-322~~ (done, see [DONE.md](DONE.md): section counts + spacing, radio-style date presets, no-source card fallback, VoiceOver-aware success-sheet timing; select-mode layout shift stays FAB-334 scope, Settings-icon placement left as-is per Fabio's call) → ~~FAB-328~~ (done, see [DONE.md](DONE.md): real SF Symbols, disabled-Continue hint, "Allow" CTA + equal-weight consent buttons, stale doc note; its last bullet closed as a side effect of FAB-327's fix, below) → ~~FAB-327~~ (done, minimum-fix scope, see [DONE.md](DONE.md): global Skip, not tour-only, + a page-dot row that shrinks as you advance, rather than cutting screens. The full restructure was renumbered FAB-348 2026-09-12 and shipped the same day as FAB-334 phase 2, see [DONE.md](DONE.md)) → ~~FAB-314~~ (done, see [DONE.md](DONE.md), deliberately last so it encodes the corrected passing state: `scripts/check_contrast.py` now enforces contrast in CI instead of the hand-maintained, overclaiming table; 2 genuine failures it found are FAB-336) → ~~FAB-336~~ (done, see [DONE.md](DONE.md): `error` darkened ~10%; `placeholder`'s icon moved onto `textSecondary` instead of a token-value fix, since the token's only remaining live use is an intentionally-recessive skeleton loader. Checker now passes with zero known failures) → ~~FAB-337~~ (done, see [DONE.md](DONE.md): found during Fabio's first real on-device pass through this whole chain, 2026-09-08 — font/theme sheet background not reaching under the home indicator, theme swatches sitting edge-to-edge, and generate.py silently dropping FAB-330's `%` escape on regeneration). This chain is now fully worked through — **and confirmed on-device by Fabio, 2026-09-08** (see [PENDING_TESTS.md](PENDING_TESTS.md)'s Done section).
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

### Design critique 2026-09-01 — article list

  Also seen: the panel is a fixed `width: 320` — ~80% of a 393pt screen and **~85% of the 375pt iPhone SE**, leaving a dismiss strip of roughly 55pt, too narrow to read as "tap outside to close". Use a fraction with a maximum rather than a fixed width. And with zero tags in the library it still renders a "Search tags…" field above a lone "All tags" row, searching nothing — hide it when the tag list is empty.

- [ ] 🟠 **FAB-320** · Bulk select: destructive action isn't marked, and nothing shows a count  `Todo` `High`
  ## Scope

  Critique §5.6.

  **Delete isn't red.** `Button(role: .destructive)` combined with `.buttonStyle(.plain)` drops the role's colour, so "Delete" renders in plain `textPrimary` while "Mark read" sits in accent — the irreversible action is the *less* prominent of the two. The reader's overflow menu gets this right (red, with a trash icon), which makes the bulk case — deleting *several* articles at once — both the inconsistent one and the more dangerous one. Use `semanticColors.error`.

  **No selection count.** With one article selected the header still reads "Verso". iOS convention is "1 Selected", and it matters most immediately before a bulk delete. The confirmation dialog does show a count, but that is after the fact.

  ## Resolution (decided 2026-09-08, ships in FAB-334 phase 6)

  Both halves are fixed by adopting system **chrome** only — the selection model does not change:

  * **Red delete** — drop `.buttonStyle(.plain)` from the bulk-action buttons. `Button(role: .destructive)` is
    already there; `.plain` is the only thing suppressing the role's colour. That is the entire fix.
  * **Count** — "N Selected" as the navigation title, with Cancel/Done as toolbar items, once phase 4 has
    given the list a real toolbar.

  Deliberately **not** adopting `EditMode`'s multi-select: `List(selection:)`'s single-value binding drives
  `NavigationSplitView`'s sidebar→detail collapse, and a `List` takes one selection binding. Swapping it for a
  `Set` changes the `List`'s generic type, breaking view identity and resetting scroll position and section
  collapse on every entry to select mode — worst exactly when the user has scrolled far to find what they want
  to delete. Accepted losses: no free Select All, no drag-to-select. Neither was asked for.


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

### Phase E — native iOS shell (1.1)

- [ ] 🟠 **FAB-334** · [Epic] Native iOS shell: replace custom chrome with system components (Liquid Glass)  `Todo` `High`
  ## Goal

  Make Verso look and behave like a native iOS app — Liquid Glass chrome, a bottom-anchored search field, system navigation, system list and form styling — **without touching the reading view**, which stays exactly as it is.

  Decided with Fabio 2026-09-03: **native shell, custom reading room.** The article list, settings, search, navigation and toolbars adopt system components; the reading surface keeps its bespoke typography, its four themes and its custom chrome. This is how Reeder and Matter are built, and it puts the paper identity where it earns its keep instead of fighting the platform everywhere else.

  ## Progress (2026-09-14)

  Folded into 1.0, built before launch rather than as a 1.1 fast-follow (see Decision #2 correction below). Phases done so far, per [plans/FAB-334-1.1-native-shell-plan.md](plans/FAB-334-1.1-native-shell-plan.md): **phase 0** (material spike, verdict: proceed, tinted glass), **phase 1** (deployment target → iOS 26.0), **phase 2** (onboarding cut, FAB-348), **phase 3** (Settings → `Form` — its theme picker shipped a regression, fixed same day, see [DONE.md](DONE.md)), **phase 4** (navigation shell, merged 2026-09-14 — the plan's own R3 regression check, push Settings → background → cross the theme boundary → return, was never explicitly confirmed as run; flagged, not assumed), **phase 5** (search and filters — `.searchable` replaces `SearchBar`, `FilterPanel` → a real `.sheet`, **FAB-319 now fully done**, see [DONE.md](DONE.md)). FAB-326 partially absorbed by phase 4, not closed — see the plan doc's phase 4 section for exactly which rows remain. Phases 6–7 next.

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

  **Not absorbed — do these in 1.0 as already sequenced.** Everything in the content and reading layers survives untouched: FAB-315 + FAB-332 (parser), FAB-330, FAB-331, FAB-312, FAB-308, FAB-307, FAB-333, FAB-316, FAB-317, FAB-321, FAB-323, FAB-306, FAB-348, FAB-328.

  **FAB-309 is the one to split, not defer.** Its two halves behave differently:

  * *Rebuilding `VersoTypography.UI` on text styles* is cheap, mechanical, and **survives this epic** — system components need correct text styles anyway, and `Typography.Reading` is untouched by the shell either way. Keep it in 1.0.
  * *The layout audit* (`lineLimit(1)` sweeps, fixed frames, sheet detents on custom components) is largely throwaway, because most of those components are deleted here. Defer the parts that touch chrome; keep the parts that touch the reading view and onboarding.

  The counter-argument, which is real: shipping 1.0 ignoring the system text size means a reading app that ignores it for however long 1.1 takes, and enlarged-text readers are close to this app's core audience. That is the reason the token half stays in 1.0 rather than waiting.

  ## Explicitly out of scope

  The reading view. Beyond the design decision, there is a hard technical reason: the body is not SwiftUI. `HighlightableRegionText` wraps a custom `HighlightableUITextView` per contiguous region, needed for FAB-54/FAB-303 highlighting, and it overrides `draw(_:)` — as FAB-304's second cause made vivid. Nothing about Liquid Glass adoption should go near it.

  Also out of scope: the Share Extension (FAB-323 handles its theming separately) and the iPad epic (FAB-131, FAB-152–162), which stays deferred.

  ## Decisions — all four closed 2026-09-08

  Implementation plan: **[plans/FAB-334-1.1-native-shell-plan.md](plans/FAB-334-1.1-native-shell-plan.md)** — read that
  to execute; read this ticket for the reasoning behind it. The plan also re-measured this epic's
  counts (several had drifted) and names four architectural risks found in a 2026-09-08 audit that
  aren't described here — chiefly that `EditMode` collides with the `List(selection:)` binding
  `NavigationSplitView` uses for its sidebar→detail collapse.

  | # | Decision | Answer (Fabio, 2026-09-08) |
  |---|---|---|
  | 1 | Deployment target | **iOS 26.0**, as provisionally decided. iOS 27 ships ~2026-09-14; iOS 26 was already at 79% of all iPhones / 86% of last-4-years devices in June 2026, so the floor is cheap. Build against the newest SDK, deploy to 26. ~~Still **not** on `main` — first commit on the 1.1 branch.~~ **Superseded 2026-09-12** — see Decision #2 correction below: this lands on `main` directly, one phase-sized branch/PR at a time, same as any other issue. |
  | 2 | When 1.1 opens | ~~**After 1.0's final binary submission lands.** `main` stays at iOS 16 until then, so a Review rejection or hotfix has a clean base.~~ **Superseded 2026-09-12 (Fabio): folded into 1.0, built before launch.** Nothing has shipped yet, so there's no clean 1.0 base left to protect — Fabio chose to do the shell first instead of as a post-launch fast-follow. `main` raises straight to iOS 26 as FAB-334's phase 1; `MARKETING_VERSION` stays `1.0` (there's no real "1.1" to distinguish); FAB-150's final binary submission now waits behind FAB-334 finishing, not the reverse. See [plans/FAB-334-1.1-native-shell-plan.md](plans/FAB-334-1.1-native-shell-plan.md) §1 for the same correction on the execution side. |
  | 3 | Themes outside the reader | **Collapse to light/dark**, driven by `VersoTheme.isDark`. Paper/Sepia/Night/Ink survive in the reading view only. |
  | 4 | Onboarding | **FAB-348 cuts 7 screens to 2 first, on current chrome; the shell then reskins only the 2 survivors.** Confirms FAB-348's 2026-09-06 draft resolution #1. **Done 2026-09-12** — see [DONE.md](DONE.md); the shell's own reskin of the 2 survivors is still ahead, as this epic's own phase 2/3. |
  | 5 | Bulk select vs `EditMode` (raised by the 2026-09-08 audit, not in the original four) | **Keep `selectedArticleIds` and the `.constant(nil)` trick; adopt only `EditMode`'s chrome.** `List(selection:)`'s single-value binding is what drives `NavigationSplitView`'s sidebar→detail collapse — a `List` takes one selection binding, so real multi-select would mean swapping its generic type and losing scroll position and section state on every entry to select mode. FAB-320 needs red-Delete and a count, both of which come free from the chrome alone. See the plan's R1 for the keep/change table. |

  Decision 4 also settles FAB-348's third draft resolution differently than proposed: its
  "tour → empty-state teaching hints" is **cut**, superseded by the welcome article (FAB-338 below).
  With an article seeded at folder-pick time the library is never empty on first run, so the hints
  would never fire.

  ### Original reasoning (2026-09-03, retained)

  1. **Deployment target — DECIDED 2026-09-03: raise to iOS 26.0.** Currently **iOS 16.0** (`Verso/project.yml`). The `glassEffect` family is iOS 26-only, so a real Liquid Glass shell needs either `if #available(iOS 26, *)` branches throughout or a raised floor. Verso has no installed base — nobody is on an old build because there is no old build — so this is the cheapest moment in the app's life to raise it, and it only gets more expensive after 1.0 ships.

     ⚠️ **Do not make this change on `main` yet.** 1.0 is one step from final binary submission (FAB-150) and is expected to ship at iOS 16. Raising the floor on `main` changes what 1.0 ships as and would cut its addressable devices for no benefit, since 1.0 uses no iOS 26 API. Land it as the first commit on the 1.1 branch instead (phase 1 below). If 1.0 slips far enough that it would ship after the shell work anyway, revisit — but that should be a deliberate call, not a side effect.

     Worth confirming current iOS 26 adoption before the branch opens; it shipped a year ago, so the cost is probably modest, but the number should be looked up rather than assumed.
  2. **What happens to the four themes in the shell.** The decision above implies the shell follows light/dark (driven by `VersoTheme.isDark`, which `ContentView.preferredColorScheme` already plumbs) while Paper/Sepia/Night/Ink survive in the reader. Confirm that is acceptable before building — it is a visible reduction outside the reading view.
  3. **Whether onboarding is rebuilt here or in FAB-348 — draft resolution proposed 2026-09-06, not yet confirmed by Fabio: neither, sequentially.** FAB-348 cuts seven screens to two first (on current chrome), then this epic reskins only the two survivors. See FAB-348's own "Draft resolutions" section for the reasoning; this line stays open until Fabio signs off there. **The cut is done** (2026-09-12, see DONE.md) — this epic's reskin of the 2 survivors remains.
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

- [ ] 🟠 **FAB-338** · Welcome article: seed a real Markdown article on first run  `Todo` `High`
  ## Scope

  Agreed with Fabio 2026-09-08. **Ships in 1.1, after the native shell lands, before release** —
  phase 8 of [plans/FAB-334-1.1-native-shell-plan.md](plans/FAB-334-1.1-native-shell-plan.md).

  Write one real `.md` article into the user's chosen folder at folder-pick time, so a first-time user
  opens the app into the reading view with content rather than onto an empty list. It carries the
  instructions, feature descriptions and usage tips that FAB-348's deleted tour used to.

  **Why this shape.** Verso's pitch is *your articles are plain Markdown files you own* — a welcome
  article demonstrates that in the first ten seconds, since the user can open their iCloud folder and
  find the file. It teaches inside the real reading view against real content instead of illustrating
  controls on a carousel. And it doubles as a first-run QA artifact: with headings, lists, a blockquote,
  an image and a few hundred words it exercises `HighlightableRegionText`'s region splitting, scroll
  progress, and the reading-time estimate on launch.

  **Supersedes** FAB-348's proposed empty-state teaching hints (see FAB-334's decision block above).
  It does **not** supersede FAB-319's empty-state CTA — a user who skips folder selection never gets
  the article and still lands on the empty state.

  ## Constraints

  These are what make it acceptable rather than intrusive — the app is writing an unsolicited file
  into a folder belonging to an audience that notices:

  1. **Written once, at folder-pick time.** There is no folder during Welcome. Its own flag, not onboarding's.
  2. **Deleting it is permanent.** `ICloudFileWatcher`'s next rescan must not resurrect it. The flag has
     to survive the delete — the detail most likely to be got wrong.
  3. **Never overwrite, never intrude on an existing library.** Don't write if a file of that name
     exists, or if the folder already contains `.md` files — `SettingsView.hasMarkdownFiles(in:)`
     already implements that check; reuse it. Pointing Verso at an existing Obsidian vault must not add a file to it.
  4. **Honest frontmatter.** No fabricated `source:` or publisher. It is not a saved article and must not
     pretend to be one — a fake source URL would also make it sort oddly and corrupt the library's data model.
  5. **Three locales.** EN-CA, FR-CA, PT-BR. Real prose, not strings-file entries: budget genuine
     translation time, and keep it short enough that maintaining three copies stays cheap as the UI moves.

  ## Resolved

  **The article stays in the library** (Fabio, 2026-09-08) — no auto-archive once the user saves their
  first real article. Auto-archiving would be the app quietly touching the user's data a second time, and
  it contradicts the "these are just your files" pitch the article exists to demonstrate. The user
  archives or deletes it like any other article; per constraint 2, deleting it is permanent.

  ## Depends on

  FAB-334 phases 3–7 (the tips describe the shell's controls) and FAB-348 (which deletes the tour this replaces).
  Draft the prose during the shell work; finalise control names at the end.


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



