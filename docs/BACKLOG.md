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

**25 open issues** across iOS, Web, Design, and Infra.

## iOS

### Phase 2 — Experience

- [ ] 🔵 **FAB-54** · [PHASE 3] Implement highlighting  `Backlog` `Low`
  Allow users to select text in the reading view and highlight it. Store highlights in the article's .md file as custom frontmatter or inline Markdown annotations.

- [ ] 🟡 **FAB-135** · Detect clipboard URL when tapping the add article button  `In Review` `Medium`
  When the user taps the "+" button to manually add an article, the app should check if a URL is present in the clipboard and pre-fill the URL field with it if so.

  This speeds up the manual-add flow significantly since users often copy a URL before switching to Verso.

  **Implementation complete** (2026-06-12). Uses `detectPatterns(for: [.probableWebURL])` to avoid the iOS system banner.

  **⚠️ Needs device testing before closing:**
  - Copy a URL in Safari → switch to Verso → tap + → field pre-fills, no system banner shown
  - No URL in clipboard → field stays empty
  - Non-URL text in clipboard → field stays empty
  - Field already has content → no overwrite

- [ ] 🟡 **FAB-150** · [Phase 2] App Store release checklist  `Backlog` `Medium`
  Parent checklist for shipping Verso to the App Store after Phase 2 feature work ([FAB-51](https://linear.app/fabiosasseron/issue/FAB-51/phase-2-implement-scroll-position-saving) → [FAB-52](https://linear.app/fabiosasseron/issue/FAB-52/phase-2-implement-tagging-system) → [FAB-50](https://linear.app/fabiosasseron/issue/FAB-50/phase-2-implement-full-text-body-search) → [FAB-53](https://linear.app/fabiosasseron/issue/FAB-53/phase-2-implement-bulk-actions)).

  ## Store & compliance

  - [ ] App Store Connect metadata (name, subtitle, description, keywords, support URL)
  - [ ] Screenshots for required device classes
  - [ ] Privacy nutrition labels / manifest aligned with app behavior (file-first, optional TelemetryDeck if enabled)
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

- [ ] 🟠 **FAB-275** · Localization: EN-CA, FR-CA, PT-BR (epic)  `Backlog` `High`
  Ship Verso in **EN-CA, FR-CA, and PT-BR** across iOS and Web.

  Strategy and all decisions are documented in `docs/LOCALIZATION.md`; English base copy lives in `docs/copy/UI_COPY.md`.

  > **Note:** This workspace hit Linear's free issue limit, so only steps 1–2 became standalone issues ([whysasse/verso-app#315](https://linear.app/fabiosasseron/issue/FAB-276/l10n-1-finalize-localization-strategy-and-decisions-doc) = step 1). Steps 2–8 are tracked as the checklist below until quota allows splitting them out. Order is by dependency.

  **Key decisions (**`docs/LOCALIZATION.md`**):** `en-CA` aliases `en` (no separate bundle); plurals via CLDR (FR treats 0 as singular, PT-BR treats 0 as plural); theme *labels* translated but enum keys kept; per-locale font preview; no RTL.

  ---

  ### Ordered backlog

  - [ ] **1 · Strategy & decisions doc** → [whysasse/verso-app#315](https://linear.app/fabiosasseron/issue/FAB-276/l10n-1-finalize-localization-strategy-and-decisions-doc). Ratify `docs/LOCALIZATION.md`; link from `HANDOFF.md`. *(foundation — blocks 3)*
  - [ ] **2 · Locale-aware formatting** (dates, reading-time, TTS voice). Independent — can run early/parallel. iOS + Web. Replace hard-coded `MMM d, yyyy`; centralize `WPM = 220`; TTS voice follows article content language. *Done: no date/number/reading-time/TTS string locked to one locale; checked in all 3 locales.*
  - [ ] **3 · Shared, platform-neutral string source.** *Blocked by 1.* Extend `UI_COPY.md` keys with `en` / `fr-CA` / `pt-BR` (table columns or a generated `strings.json`); same key namespace feeds iOS + Web. Add invariant list + plural categories. *Done: one keyed source both platforms consume.*
  - [ ] **4 · iOS i18n infrastructure.** *Blocked by 3.* Adopt **String Catalog (**`.xcstrings`**)**; wire keys; encode plural variations natively. *Done: app builds localized; pseudolocale switch works.*
  - [ ] **5 · Web i18n infrastructure.** *Blocked by 3.* Adopt **next-intl**; `messages/<locale>.json` keyed identically to iOS; ICU plurals; locale routing/detection. *Done: web renders per-locale strings.*
  - [ ] **6 · Pseudolocalization + layout flex QA.** *Blocked by 4 & 5.* Run +30% accented pseudolocale; fix truncation. Highest risk: **filter chips** (En cours / Non lus), buttons, share-sheet save states. Update `COMPONENT_SPECS.md`. *Done: no truncation/overflow in pseudolocale on either platform.*
  - [ ] **7 · FR-CA & PT-BR translation + linguistic/diacritic QA.** *Blocked by 6.* Québec French + Brazilian Portuguese. Verify plurals (esp. the 0-case), accents, and that **OpenDyslexic** renders ç ã õ â ê é à ü at all six reading sizes. *Done: both locales fully translated and QA'd.*
  - [ ] **8 · App Store metadata + Québec/Bill 96.** *Blocked by 7.* Localize store listing (name, subtitle, description, keywords, screenshots) for fr-CA + pt-BR; confirm Québec French-language compliance posture for distribution. *Done: localized listings ready; compliance confirmed.*

- [ ] 🟠 **FAB-276** · L10n 1 · Finalize localization strategy & decisions doc  `Backlog` `High`
  **Foundation — blocks the string/infra work.**

  `docs/LOCALIZATION.md` exists (v1.0) with the locked decisions. This issue is to review/ratify it and fill any gaps before implementation:

  * Confirm locale set: `en` base, `en-CA` aliases `en`, `fr-CA` + `pt-BR` full. No RTL.
  * Confirm CLDR plural categories (FR: 0 = singular; PT-BR: 0 = plural).
  * Lock the invariant-terms list and the `[Your Name]` iCloud exception.
  * Confirm theme-label translations and per-locale font-preview strings.
  * Confirm `WPM = 220` and locale-aware date policy.

  **Done when:** `docs/LOCALIZATION.md` is signed off and linked from `docs/HANDOFF.md`.

