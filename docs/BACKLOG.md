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

**22 open issues** across iOS, Web, Design, and Infra.

## Current sequencing (iPhone-only work, agreed with Fabio 2026-08-24)

Excludes the iPad epic (FAB-131, FAB-152–162) and the Phase 3 expansion backlog, which are deferred past this release.

- **Phase A — ship this release.** FAB-163 and FAB-164 done (see [DONE.md](DONE.md)). FAB-150's Store & compliance checklist is done — Fabio reviewed and entered all ASC metadata 2026-08-25 (see [APP_STORE_LISTING.md](APP_STORE_LISTING.md)). Remaining: the final binary submission itself.
- **Phase B — localization (FAB-275).** Steps 1–8 done (see [DONE.md](DONE.md)). FAB-284 (language picker, iOS + Web) also done 2026-08-28 — nothing open in this phase.
- **Phase C — post-launch polish.** FAB-54 (highlighting) done 2026-09-01 (see [DONE.md](DONE.md)); its follow-up FAB-303 (highlighting v2 — cross-block selection, formatting-aware spans, headings/lists/quotes) is being shipped incrementally — Step 1 of 5 done 2026-09-01, Steps 2–5 remain (see FAB-303's own checklist below). FAB-277 (RSVP mode), FAB-278 (VoiceOver progress announcement) still need a UX decision from Fabio before implementation starts.

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

- [ ] 🟡 **FAB-303** · [Phase 3] Highlighting v2: cross-block selection, formatting-aware spans, headings/lists/quotes  `In Progress` `Medium`
  Lifts the five scope limits [FAB-54](DONE.md) shipped with on 2026-09-01: no selecting across paragraphs, a graceful decline whenever the selection crosses bold/italic/code/a link, no highlighting of headings, list items, blockquotes or table cells, and a first-occurrence splice that can target the wrong duplicate paragraph. Scope, formatting behavior and remove behavior agreed with Fabio 2026-09-01. **Parent issue — implemented incrementally, one step at a time, rather than as one PR** (this is a near-rewrite of reading-view text rendering; too large and too risky to land and verify in a single shot). Steps below get checked off as they ship; use `Refs #303` (not `Closes`) in each step's PR body so this stays open until Step 5 lands.

  - [x] **Step 1 — source line ranges on every block node.** Shipped 2026-09-01 (`feat/fab-303-step1-source-line-ranges`). Scoped to exactly the five block types Step 4 below names as the future cross-block "text region" (paragraph, heading, unordered/ordered list item, blockquote) — `codeBlock`/`image`/`horizontalRule`/`table` don't get a `BlockSource`, since nothing consumes it for those. `contentOffset` is UTF-16-based (matching this file's existing `NSRange` conventions) and computed generically as line length minus already-extracted content length, not hardcoded per syntax. The stated immediate payoff shipped too: `ArticleReaderView.applyHighlightChange` now splices by exact line index instead of `parsedContent.range(of: oldRawText)`, retiring the duplicate-paragraph-text edge case outright rather than leaving it for later.
  - [x] **Step 2 — per-run source offsets.** Shipped 2026-09-01 (`feat/fab-303-step2-per-run-offsets`). One correction to this step's own write-up below, found while implementing: deleting `literalRange(of:in:)`/`highlightRoundTrips` is only safe for a selection that stays inside a *single* tagged inline run — slicing raw text between two exact offsets when the selection crosses into a differently-formatted run would split that run's delimiters (e.g. `**`) and corrupt the file. So this step restricts the new offset-based `ArticleHighlighter.addHighlight(atRawOffsetRange:in:)` to the same-run case (the common one — an ordinary sentence with no internal formatting is almost always one run) and keeps declining a cross-run selection, same visible behavior as before, just detected by comparing tagged runs instead of a failed text search. Making the cross-run case itself work correctly is still Step 3's job, not moved up.
  - [ ] Step 3 — formatting-aware wrapping
  - [ ] Step 4 — text regions (cross-block selection)
  - [ ] Step 5 — cross-block write and remove

  ## The constraint everything else follows from

  Highlights are `==text==` markers in the article's own `.md` body, so every change here has to stay valid for Obsidian and any other Markdown reader. What that permits:

  * `## The ==quiet== revolution` — valid ✅
  * `- a ==highlighted== list item` — valid ✅
  * `> a ==quoted== bit` — valid ✅
  * `==**bold text** and more==` — valid; `==` behaves like emphasis and nests ✅
  * A fenced code block or inline `` `code` `` — `==` is **literal** inside both and would corrupt the code ❌ stays excluded
  * A link's `(url)`, an image path, YAML frontmatter — never touched ❌
  * **One `==…==` pair can never span a blank line.** A blank line closes the inline context, so a highlight covering three paragraphs must be written as three separate pairs, one per block. This is not a workaround — it is what an Obsidian user does by hand.

  ## Decisions (Fabio, 2026-09-01)

  * **Scope B** — block types *and* cross-block selection, via merged text views. Table cells out of scope.
  * **Snap outward** on formatting boundaries — a selection ending inside `**bold text**` highlights the whole run rather than splitting it. The highlight can come out slightly larger than the selection; the `.md` stays clean.
  * **Remove Highlight clears the whole visual highlight** — every contiguous marker pair it's made of, across blocks. The user sees one highlight, so one action clears it.

  ## Step 1 — Source line ranges on every block node ✅ Done 2026-09-01

  No user-visible change; everything below depends on it. `MarkdownParser.parse` already walks lines by index, so recording each node's `(startLine, endLine)` is nearly free. Replaced `.paragraph`'s ad-hoc `rawText` with a uniform `MarkdownNode.BlockSource` carried by paragraph, heading, both list-item cases, and blockquote: source line range (`ClosedRange<Int>`), raw source text, and a `contentOffset` — where the block's content begins inside its raw line (0 for a paragraph, `level + 1` for a heading, 2 for `- `/`> `, digit-count-dependent for an ordered item). `contentOffset` is what will keep a marker from ever landing in front of a block's own syntax, once Step 2/3 actually consume it — it isn't read by anything yet.

  Shipped payoff, not just plumbing: `ArticleReaderView.applyHighlightChange` now replaces exact line indices instead of doing `parsedContent.range(of: oldRawText)`, which retires the duplicate-paragraph edge case outright. (This step's own PR isn't in `docs/DONE.md` — FAB-303 is a parent issue and stays open here, same convention as FAB-150, until Step 5 lands.)

  ## Step 2 — Per-run source offsets (the real fix for the formatting limit) ✅ Done 2026-09-01

  Previously `ArticleHighlighter` took the *rendered* selected text and re-found it in the raw source with a whitespace-tolerant regex. That search is why a selection crossing bold declined: rendered `bold text` and source `**bold text**` don't literally match. Fixing it by adding more matching rules would have been treating the symptom.

  Instead, `parseInlines` now returns each `InlineNode` with the source range it came from (`sourceRange: Range<Int>`, UTF-16, content only — delimiters excluded), and `HighlightableParagraphText.buildAttributedString` tags each run with a `.versoSourceOffset` attribute (`contentOffset + sourceRange.lowerBound`, using Step 1's `BlockSource.contentOffset`). A selection's `NSRange` now converts to an exact raw offset — run content start + offset within run — with no searching at all, for a selection that stays inside one tagged run. This deleted `literalRange(of:in:)`, the `highlightRoundTrips` re-parse guard, and the whitespace-tolerance hack, and replaced the old text-search-based `addHighlight(selecting:in:)` with offset-based `addHighlight(atRawOffsetRange:in:)`. Paragraph's `contentOffset` (hardcoded `0` in Step 1) also became the real leading-whitespace-trim length, needed now that per-character precision matters — see the checklist correction above for the one place this step's original scope needed narrowing (same-run only; cross-run is Step 3).

  ## Step 3 — Formatting-aware wrapping

  With exact offsets, marker placement becomes a decision rather than a search:

  * Boundary inside a plain-text run → wrap exactly there.
  * Boundary strictly inside a bold/italic/bold-italic/link run → **snap outward** to that run's edge. Never split an emphasis run; never place a marker inside a link's `(url)`.
  * Selection lying **entirely** inside one inline-code run → nothing safe to wrap, keep declining (with feedback, see Copy below). A selection that merely *contains* a code run is fine: ``==a `x` b==``.
  * Selection overlapping or directly adjacent to an existing highlight → strip those markers and emit **one merged pair**. Guarantees the parser can never be handed `==a ==b== c==`.
  * `InlineNode.highlight` becomes recursive — `.highlight([InlineNode])` instead of `.highlight(String)` — so `==**bold** x==` renders as bold inside the wash. Obsidian already renders it that way; Verso currently shows literal asterisks, which will start mattering the moment snap-outward exists.

  ## Step 4 — Text regions: one text view per run of consecutive text blocks

  This is the cross-paragraph fix and the bulk of the work. iOS cannot extend a native selection across two views, and today every paragraph is its own `UITextView`. So: group consecutive `.paragraph` / `.heading` / `.unorderedListItem` / `.orderedListItem` / `.blockquote` nodes into a **text region**, and render each region as a single `HighlightableParagraphText`. `.image`, `.codeBlock`, `.table` and `.horizontalRule` end a region and keep rendering exactly as they do now. Selection then flows across every block inside a region, which in practice is most articles end to end.

  What moves out of SwiftUI layout and into TextKit attributes:

  * Inter-block spacing → `NSParagraphStyle.paragraphSpacingBefore` per block, reusing the existing numbers from `topSpacing` (24 before a heading, 16 default, 6 between sibling list items).
  * Bullets and numbers → a literal `•\u{2003}` / `3.\u{2003}` prefix plus `headIndent` / `firstLineHeadIndent`, tagged non-highlightable so a marker can never land in the bullet.
  * Heading fonts → `VersoTypography.Reading` mapped to `UIFont`; the custom-font fallback in `withSymbolicTraits` already handles families with no bold face.
  * TTS paragraph wash (`highlightedParagraphIndex`) → a background-colour attribute over that block's range, instead of a `.background()` on the view.
  * **Blockquote's 3pt accent bar is the one real visual risk.** In TextKit it needs either a text-layout-fragment draw override or a downgrade to indent-only. Decide during implementation against a side-by-side with the current build — do not assume.

  Also needs re-verification, not assumption: `sizeThatFits` is doing much more work now that a region is many blocks tall, and Dynamic Type reflow within a region has never been exercised.

  ## Step 5 — Cross-block write and remove

  * **Write:** a selection spanning blocks becomes one `==…==` pair per block — tail of the first, whole middle blocks, head of the last. Any block in the range that can't take markers (code block, table, rule) is skipped rather than aborting the whole action.
  * **Remove:** `removeHighlight(at:in:)` goes from index-based to range-based. Collect every `.highlight` run the selection touches, walk outward while neighbouring runs are contiguous (only whitespace or a block boundary between them), unwrap them all.

  ## Out of scope (deliberate)

  * **Table cells.** Each cell would need its own text view inside the horizontal `ScrollView`/`Grid`, and cross-cell selection still wouldn't work. Rare in saved articles — file separately if it comes up in practice.
  * **Selection across an image, code block or table.** Those break a region by design. Highlighting "around" a code block yields two highlights, one per side. Correct, and it matches the file format.
  * **One text view for the entire article.** Rejected: images would become `NSTextAttachment`s (async load, resize on rotation and Dynamic Type), tables essentially cannot be represented, and scroll-position saving plus TTS would both need rework — large risk for a small gain over per-region.
  * **Multiple highlight colors, cross-article Highlights view.** Still out — those need a real data model, not inline markers.

  ## Copy

  Existing `reading.highlight.add` / `reading.highlight.remove` keys carry over. One new key only if the inline-code decline (Step 3) gets a brief message instead of today's silent error haptic — decide with Fabio during implementation.

  ## Verification

  * `ArticleHighlighterTests` — offset mapping, snap-outward at each run type, merge of overlapping and adjacent highlights, inline-code decline, per-block splitting across 2/3/N blocks, remove-whole-contiguous-run.
  * `MarkdownParserTests` — source line ranges, `contentOffset` per block type, recursive `.highlight` content, nested formatting inside a highlight.
  * Round-trip: parse → highlight → write → re-read → parse yields the same node tree. Plus a fixture asserting no case ever produces a literal `==` in the rendered output.
  * **On device (Fabio) — where the risk actually lives.** Side-by-side against the current build on all 4 themes: block spacing, bullet and number indentation, the blockquote bar, heading sizes, Dynamic Type at the largest sizes, selection handles across a whole region, TTS wash landing on the right block, and **VoiceOver** — a merged region is one accessibility element by default, so it needs explicit per-block accessibility elements or paragraph-by-paragraph navigation regresses.


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



