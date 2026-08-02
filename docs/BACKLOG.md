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

**26 open issues** across iOS, Web, Design, and Infra.

## iOS

### Phase 2 — Experience

- [ ] 🔵 **FAB-54** · [PHASE 3] Implement highlighting  `Backlog` `Low`
  Allow users to select text in the reading view and highlight it. Store highlights in the article's .md file as custom frontmatter or inline Markdown annotations.

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
  - [x] App Store Connect app record created (public listing name "Version Reader" — "Verso" was taken; in-app branding/docs stay Verso)
  - [x] `xcodebuild archive` succeeds end to end for the `Verso` scheme with a Distribution identity

  ## Store & compliance

  - [ ] App Store Connect metadata — subtitle, description, keywords, support URL (app record + listing name already done, see above)
  - [ ] Screenshots for required device classes
  - [ ] Privacy nutrition labels (App Store Connect questionnaire) — `PrivacyInfo.xcprivacy` manifest already done, see above
  - [ ] Age rating questionnaire

  ## Release process

  - [ ] TestFlight build for smoke testing
  - [ ] App Review notes (Share Extension, iCloud folder access, etc.)
  - [ ] Final binary submission

  ## Product docs

  * PRD §10 Phase 2: no in-app data export — articles remain user-owned Markdown in iCloud Drive (v1.7, 2026-05-10).

  ## Depends on

  Close or hand off after core Phase 2 issues are done.


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


### Phase 1 — Foundation

- [ ] ⚪ **FAB-163** · Shipped: Duplicate article detection (share extension + in-app)  `In Review` `No priority`
  Implemented duplicate detection when saving an article whose canonical source URL already exists in the library (YAML `url:` in root + `Archive/` .md files).

  **Share extension:** After parse, resolves library folder via app-group bookmark; if duplicate, prompts **Update existing** / **Save as copy** / **Cancel** (cancel completes without pending JSON). Pending payload carries `DuplicateSaveResolution` for ingester.

  **Main app:** `MarkdownWriter.replaceArticle` preserves `added`, `status`, `scroll_position`, `tags`; `PendingArticleIngester` updates Core Data by file path on replace. Analytics `article.saved` includes `duplicate_resolution`: `none` | `update` | `copy`.

  **In-app Add Article:** Same duplicate UI and write paths for parity.

  **Docs:** `docs/copy/UI_COPY.md` (share.duplicate.\*), `docs/ANALYTICS_STRATEGY.md`.

- [ ] 🟡 **FAB-164** · Fix GoodLinks JSON backup import (native export format)  `In Review` `Medium`
  ## Root cause

  GoodLinks exports a **top-level JSON array** of bookmarks with `addedAt` as a numeric Unix timestamp (`url`, `title`, `tags`, etc.). Verso only matched a **dictionary** with `items` and ISO strings `created_at` / `read_at`, so real backups failed `canParse` → unsupported format or bad decode.

  ## Acceptance criteria

  - [x] Import succeeds for minimal native-array fixture (same shape as public GoodLinks-Export.json converters).
  - [x] Legacy `{ "items": [...] }` + ISO dates path still works if present.
  - [x] GoodLinks array is not misclassified as Matter JSON (detector order / heuristics).

  ## Implementation

  Parser update in `Verso/Sources/Services/Import/GoodLinksParser.swift`. Regression tests added to `Verso/VersoTests/GoodLinksParserTests.swift` (2026-06-12).

  **⚠️ Needs real-file smoke test before closing:**
  - Run import with an actual GoodLinks JSON export (native top-level array format)
  - Verify articles appear in the library with correct titles, dates, and tags


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


- [ ] 🟢 **FAB-283** · Wire `OnboardingThemePickerView.swift` hardcoded strings to `L10n.*`  `Backlog` `Low`
  Found during the FAB-282 final sweep. `OnboardingThemePickerView.swift` has three hardcoded user-facing strings: `Text("Choose your theme")`, `Text("You can always change this later in Settings.")`, and `Button("Continue")`. Existing L10n keys differ slightly (`onboarding.theme.headline` = "Choose your reading theme", `onboarding.theme.subheadline` = "You can change this any time from settings."), so wiring them would change visible copy.

  **Fix:** follow the FAB-281 pattern — add interim keys matching the shipped copy, wire the view, file a copy-reconciliation decision. `L10n.Onboarding.themeContinue` ("Continue") can be wired directly — it matches.

- [ ] 🟢 **FAB-284** · Language picker (iOS + Web)  `Backlog` `Low`
  Both platforms currently resolve their locale automatically (iOS: device system language; Web, once step 5 lands: browser language via a cookie) with no in-app override. Add an explicit picker so a user can choose `en` / `fr-CA` / `pt-BR` regardless of device/browser language.

  **iOS:** likely lives in Settings, alongside the existing theme picker. **Web:** `LocaleProvider` (see `docs/plans/FAB-275-step5-web-i18n-infra.md`, step 3) is deliberately shaped the same way as `ThemeProvider` so adding a `setLocale` + a switcher (mirroring the existing `ThemeSwitcher`) is a small diff, not a rewrite, once this is picked up.

  Filed as a deliberate follow-up — both platforms localize correctly via auto-detection without this. Where it lives in the UI is a UX call for Fabio, not a technical one.

- [ ] 🟠 **FAB-275** · Localization: EN-CA, FR-CA, PT-BR (epic)  `Backlog` `High`
  Ship Verso in **EN-CA, FR-CA, and PT-BR** across iOS and Web.

  Strategy and all decisions are documented in `docs/LOCALIZATION.md`; English base copy lives in `docs/copy/UI_COPY.md`.

  > **Note:** This workspace hit Linear's free issue limit, so only steps 1–2 became standalone issues ([whysasse/verso-app#315](https://linear.app/fabiosasseron/issue/FAB-276/l10n-1-finalize-localization-strategy-and-decisions-doc) = step 1). Steps 2–8 are tracked as the checklist below until quota allows splitting them out. Order is by dependency.

  **Key decisions (**`docs/LOCALIZATION.md`**):** `en-CA` aliases `en` (no separate bundle); plurals via CLDR (FR treats 0 as singular, PT-BR treats 0 as plural); theme *labels* translated but enum keys kept; per-locale font preview; no RTL.

  ---

  ### Ordered backlog

  - [x] **1 · Strategy & decisions doc** → [whysasse/verso-app#315](https://linear.app/fabiosasseron/issue/FAB-276/l10n-1-finalize-localization-strategy-and-decisions-doc). Ratify `docs/LOCALIZATION.md`; link from `HANDOFF.md`. *(foundation — blocks 3)* — **Done 2026-06-17**, see [DONE.md](DONE.md).
  - [ ] **2 · Locale-aware formatting** (dates, reading-time, TTS voice). Independent — can run early/parallel. iOS + Web. Replace hard-coded `MMM d, yyyy`; centralize `WPM = 220`; TTS voice follows article content language. *Done: no date/number/reading-time/TTS string locked to one locale; checked in all 3 locales.* — **iOS: done** (`WPM = 220` centralized in `ReadingEstimate.swift`; TTS voice follows content language in `TTSService.swift`; `ArticleHeader.swift` date style corrected `.long` → `.medium` 2026-06-17 to match spec). **Remaining:** Web has no date/reading-time UI yet (screens not built); full "checked in all 3 locales" verification blocked on step 7 translations.
  - [x] **3 · Shared, platform-neutral string source.** *Blocked by 1.* Extend `UI_COPY.md` keys with `en` / `fr-CA` / `pt-BR` (table columns or a generated `strings.json`); same key namespace feeds iOS + Web. Add invariant list + plural categories. *Done: one keyed source both platforms consume.* — **Done 2026-06-21.** `docs/copy/UI_COPY.md` has full `en`/`fr-CA`/`pt-BR` columns for all ~262 keys; `docs/copy/codegen/generate.py` generates `Localizable.xcstrings` + `L10n.swift` from it (verified zero drift on regeneration). Web still needs to consume this source — that's step 5.
  - [x] **4 · iOS i18n infrastructure.** *Blocked by 3.* Adopt **String Catalog (**`.xcstrings`**)**; wire keys; encode plural variations natively. *Done: app builds localized; pseudolocale switch works.* — **Done 2026-06-21.** `Localizable.xcstrings` + `L10n.swift` generated and registered in `project.yml` for the `Verso` and `ShareExtension` targets (see [FAB-282](DONE.md)); ~20 views wired to `L10n.*` accessors; CLDR plural variants encoded for the 7 true-plural keys. **Remaining:** pseudolocale switch itself isn't built yet — that's step 6's job, not re-litigated here.
  - [x] **5 · Web i18n infrastructure.** *Blocked by 3.* Adopt **next-intl**; `messages/<locale>.json` keyed identically to iOS; ICU plurals; locale routing/detection. *Done: web renders per-locale strings.* — **Done 2026-06-21.** `next-intl` installed (cookie-based locale, no `[locale]` routing — see `docs/plans/FAB-275-step5-web-i18n-infra.md` for why); `LocaleProvider` mirrors `ThemeProvider`; `generate.py` now also emits `verso-web/messages/{en,fr-CA,pt-BR}.json` (284 keys originally; 274 after Phase A cleanup of retired interim keys); all Web components (`FilterChipBar`, `EmptyState`, `SearchBar`, `LoadingState`, `ArticleCard`, `page.tsx`, `article/[id]/page.tsx`) wired to `useTranslations`, zero hardcoded UI strings remain. **Per Fabio's call:** rather than wiring interim keys around the mismatch, Web's copy was rewritten to match the iOS-authored `UI_COPY.md` wherever an equivalent existed (search placeholder, loading label, empty states, theme/font names); ~22 new `web.*`-namespaced and empty-state keys were added for genuine Web-only surfaces (font-family picker, unsupported-browser screen, reader error states) with no iOS equivalent. Also fixed two spots where Web hardcoded `en-CA` for dates regardless of active UI locale (`ArticleCard.tsx`, `article/[id]/page.tsx`) — now locale-aware via `Intl.DateTimeFormat`. `npm run build` succeeds (verified in a clean copy outside the sandbox's FUSE-mounted folder, which has a known EPERM quirk on `.next`/`.git` cleanup — non-blocking, doesn't affect compiled output); all 192 namespace-resolved `t()` call sites checked programmatically across all 3 locales, zero missing keys. **Remaining for step 6:** `home.empty.noArticles.subheadline` ("Share an article from Safari to get started.") now also surfaces on Web's all-filter empty state even though Web has no Safari share-extension workflow — flagged here, not yet resolved; worth a look whenever step 6/7 touches empty states again.
  - [x] **6 · Pseudolocalization + layout flex QA.** *Blocked by 4 & 5.* Run +30% accented pseudolocale; fix truncation. Highest risk: **filter chips** (En cours / Non lus), buttons, share-sheet save states. Update `COMPONENT_SPECS.md`. *Done: no truncation/overflow in pseudolocale on either platform.* — **Done 2026-06-21.** See DONE.md.

        **Phase A prep (2026-06-21):** codegen now correctly handles `filter.archived.accessibilityLabel` in TRUE_PLURAL_KEYS (was missing, producing "Archived, 1 articles"); `OnboardingThemePickerView` wired to `L10n.*` (FAB-283); `QuickTourView` rebuilt as 3-step carousel with Skip (FAB-281); Obsidian tip added to `OnboardingFolderPickerView` (FAB-280); `AboutView` rebuilt per spec + new `AcknowledgementsView` (FAB-279); font-size abbreviation labels translated per locale; `settings.fontSize.valueLabel` key added for "pt" suffix; 10 retired interim keys cleaned up. All changes verified via Web build. See DONE.md for completed issues.*
  - [ ] **7 · FR-CA & PT-BR translation + linguistic/diacritic QA.** *Blocked by 6.* Québec French + Brazilian Portuguese. Verify plurals (esp. the 0-case), accents, and that **OpenDyslexic** renders ç ã õ â ê é à ü at all six reading sizes. *Done: both locales fully translated and QA'd.*
  - [ ] **8 · App Store metadata + Québec/Bill 96.** *Blocked by 7.* Localize store listing (name, subtitle, description, keywords, screenshots) for fr-CA + pt-BR; confirm Québec French-language compliance posture for distribution. *Done: localized listings ready; compliance confirmed.*


