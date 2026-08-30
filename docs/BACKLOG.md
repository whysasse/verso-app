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

## Current sequencing (iPhone-only work, agreed with Fabio 2026-08-24)

Excludes the iPad epic (FAB-131, FAB-152–162) and the Phase 3 expansion backlog, which are deferred past this release.

- **Phase A — ship this release.** FAB-163 and FAB-164 done (see [DONE.md](DONE.md)). FAB-150's Store & compliance checklist is done — Fabio reviewed and entered all ASC metadata 2026-08-25 (see [APP_STORE_LISTING.md](APP_STORE_LISTING.md)). Remaining: the final binary submission itself.
- **Phase B — localization (FAB-275).** Steps 1–8 done (see [DONE.md](DONE.md)). FAB-284 (language picker, iOS + Web) also done 2026-08-28 — nothing open in this phase.
- **Phase C — post-launch polish.** FAB-54 (highlighting), FAB-277 (RSVP mode), FAB-278 (VoiceOver progress announcement) — all need a UX decision from Fabio before implementation starts.

## iOS

### Bugs — import & rendering (reported by Fabio 2026-08-30)

Four bugs found while reading a Medium article saved through the Share Extension, plus one hand-placed `.md` file. **FAB-294 and FAB-295 share a root cause** (`SwiftSoupParser.collectLines` is the only converter the Share Extension uses, and it handles neither `<img>` nor page chrome) — do FAB-294 first, FAB-295 lands on top of it cheaply.

- [ ] 🟡 **FAB-293** · Markdown tables are not rendered in the reading view  `Todo` `Medium`

  **Symptom.** A `.md` file dropped straight into the library folder that contains a GFM table renders as one run-on paragraph, e.g. `| Col A | Col B | |---|---| | 1 | 2 |`, instead of a table.

  **Root cause.** `Verso/Sources/Components/Reading/MarkdownBodyView.swift` — the `MarkdownNode` enum has no table case and `MarkdownParser.parse` has no table branch. Pipe rows fall through every branch to the paragraph accumulator (`paragraphBuffer.append(line)`), and `flushParagraph()` joins them with spaces. The delimiter row `|---|---|` is not caught by the horizontal-rule branch either, because that branch requires `line.hasPrefix("---")` and the line starts with `|`.

  **Fix.**
  1. Add `case table(headers: [[InlineNode]], rows: [[[InlineNode]]], alignments: [TableAlignment])` to `MarkdownNode`, plus a small `enum TableAlignment { case leading, center, trailing }`.
  2. In `MarkdownParser.parse`, before the paragraph accumulator: when the current line is a pipe row **and** the next line matches a delimiter row (`^\s*\|?\s*:?-{1,}:?\s*(\|\s*:?-{1,}:?\s*)*\|?\s*$`), consume the header, the delimiter and every following consecutive pipe row into one `.table` node. Parse the delimiter row for per-column alignment (`:---` leading, `:---:` center, `---:` trailing). A pipe line *without* a following delimiter row must keep its current behaviour (plain paragraph) — this is the loop's guard against false positives. The current `for line in lines` loop needs to become an index-based `while` loop so it can look ahead and consume multiple lines.
  3. Split cells on unescaped `|` only (`\|` inside a cell is a literal pipe), trim each cell, drop the leading/trailing empty cell produced by outer pipes, and run each cell through the existing `parseInlines`. Pad short rows / truncate long rows to the header's column count so ragged tables don't crash.
  4. Render in `MarkdownBodyView.blockView` with a SwiftUI `Grid` (iOS 16+, the project's floor): header row in `bodyFont.bold()`, `colors.textPrimary`; a 1pt `colors.border` rule under the header; ~8pt cell padding; column alignment from `TableAlignment`. Wrap the `Grid` in a horizontal `ScrollView` so wide tables scroll instead of squeezing the reading column. Add the same `.padding(.top, 16)` treatment other blocks get via `topSpacing(for:)`.
  5. Extend `MarkdownNode.plainText` for the new case (join cells with a space) so search indexing and `ArticlePlainText` keep working.

  **Also fix in the same PR:** `SwiftSoupParser.collectLines` (`Verso/Shared/SwiftSoupParser.swift`) has no `table`/`thead`/`tbody`/`tr`/`td`/`th` case, so a table on an imported web page is flattened into loose text lines. Add cases that emit GFM pipe syntax. (Cheap, and without it the renderer fix is only half a feature.)

  **Acceptance.**
  - A `.md` with a 3-column table, including one with alignment colons and one with an escaped `\|` in a cell, renders as a real table.
  - A paragraph that merely contains a `|` character still renders as a paragraph.
  - A table wider than the screen scrolls horizontally; the surrounding article text does not.
  - Dynamic Type at XXL doesn't clip cells (they wrap).
  - New unit tests in `Verso/VersoTests/` covering `MarkdownParser.parse` for: a basic table, alignment row, ragged rows, a pipe line with no delimiter row (must stay a paragraph). Add a `#Preview` sample containing a table to `MarkdownBodyView.swift`.

- [ ] 🟠 **FAB-294** · Share Extension imports page chrome as body text  `Todo` `High`

  **Symptom.** A Medium article imported via the Share Extension contains navigation and UI junk in the body: the tag list (`Member-only story`, `Featured`, `Self Improvement`, `Psychology`, `Self Love`, `Mental Health`, `Books`), `4 min read ·`, and a block of stray toolbar text (`–`, `1`, `Listen`, `Share`, `Press enter or click to view image in full size`). See Fabio's screenshot (red rectangles) attached to the 2026-08-30 report.

  **Root cause.** `ShareViewModel.performSave` (`Verso/ShareExtension/Sources/ShareViewModel.swift:~70`) calls `SwiftSoupParser.parse` directly and nothing else. It never touches `ArticleParserService` or `HTMLToMarkdownConverter`, so the cleanup that already exists for the in-app path never runs on shared articles. Two concrete gaps in `SwiftSoupParser` (`Verso/Shared/SwiftSoupParser.swift`):
  - `collectLines` appends **every** bare `TextNode` it walks past as its own output line, and its `default:` branch recurses into `button`, `span`, `a`, `figcaption` wrappers. Medium's `<article>` element contains its own header toolbar, so all of it lands in the body in DOM order.
  - The `doc.select(...).remove()` noise list only covers `script, style, nav, header, footer, aside` and three ARIA roles. It does not remove `button`, `form`, `noscript`, `svg`, `[role=button]`, `[aria-hidden=true]`, or Medium's tag-list and toolbar containers.

  **Decision — do not move the Share Extension onto `ReadabilityParser`.** It would give better extraction, but it spins up a `WKWebView` and evaluates Readability.js, and share extensions run under a hard memory ceiling (~120 MB) with an aggressive watchdog; a jetsam kill there looks to the user like a silent failed save. Keep SwiftSoup (pure parsing, low memory) in the extension and make it cleaner. Revisit only if extraction quality is still unacceptable after this fix.

  **Fix.**
  1. Widen the removal selector in `extractContentMarkdown` to also drop: `button, form, noscript, svg, iframe, figure figcaption > button, [role=button], [aria-hidden=true], [data-testid*=audio], [data-testid*=headerClap], [data-testid*=headerSocial]`.
  2. Stop emitting orphan text. In `collectLines`, only append a bare `TextNode` when its parent is an inline-ish element inside a block that is already being emitted — simplest correct version: drop the top-level `TextNode` branch entirely and let `p`, `li`, `h1`–`h6`, `blockquote`, `td`, `th` be the only text-emitting cases. Verify against `SampleArticles/` that no real body text is lost.
  3. Add a shared noise filter for label-only lines and apply it to the SwiftSoup output. Extend the existing `fullscreenLineFingerprints` set in `HTMLToMarkdownConverter` (`Verso/Sources/Services/ReadabilityParser.swift`) with: `press enter or click to view image in full size`, `member-only story`, `listen`, `share`, `follow`, `sign up`, `sign in`, `featured`. Drop single-line blocks that are only a number, only punctuation (`–`, `·`, `—`), or match `^\d+\s*min read\s*·?$`.
  4. Run the extension's output through `HTMLToMarkdownConverter.sanitizeMarkdownBody(_:articleTitle:)` before writing the pending JSON — it already does title-echo removal and duplicate-block collapse, and the in-app path gets it for free. `HTMLToMarkdownConverter` currently lives in `Sources/Services/ReadabilityParser.swift` (main-app target only); **move the `HTMLToMarkdownConverter` enum into its own file under `Verso/Shared/` and add it to the ShareExtension target in `Verso/project.yml`,** then regenerate with XcodeGen. Leave `ReadabilityParser` itself in the main target — it needs WebKit.

  **Acceptance.**
  - Re-import the Medium article from the report; none of the strings in the red rectangles appear in the saved `.md`.
  - Body text, headings, blockquotes and the author's own em-dashes survive intact.
  - Re-import 2–3 files from `SampleArticles/` (and one Guardian or Substack article) and diff before/after to confirm no real content was stripped.
  - Unit tests in `Verso/VersoTests/` feeding saved HTML fixtures through `SwiftSoupParser.parse` and asserting the noise strings are absent and known body sentences are present. Commit the Medium fixture HTML under the test resources.

- [ ] 🟠 **FAB-295** · Imported articles have no images  `Todo` `High` — *do after FAB-294*

  **Symptom.** Articles saved through the Share Extension contain no images at all; the reading view shows text only.

  **Root cause.** Not the download or the renderer — both already work. `SwiftSoupParser.collectLines` has no `img` / `picture` / `figure` case, so `<img>` elements hit the `default:` branch, which recurses into children; `<img>` is void, so nothing is emitted. The markdown therefore contains no `![](…)` at all, which means `ArticleMarkdownImageLocalizer.localizeMarkdownRemoteImages` (called from `MarkdownWriter.write` / `.replaceArticle`) finds zero matches and returns early. The in-app Readability path does this correctly via `HTMLToMarkdownConverter.insertMarkdownImages` — the extension just never runs it. `MarkdownBodyView.AsyncImageBlock` already resolves relative `./{stem}.media/…` paths against `baseDirectoryURL`, so rendering needs no change.

  **Fix.**
  1. Add `case "img"`, `case "picture"` and `case "figure"` to `collectLines` in `Verso/Shared/SwiftSoupParser.swift`, emitting `![alt](url)` on its own line surrounded by blanks. Reuse the URL-resolution logic already written for the Readability path rather than reimplementing it: once FAB-294 has moved `HTMLToMarkdownConverter` into `Verso/Shared/`, expose `resolvedHTTPImageURL(forImgTag:baseURL:)`, `firstHTTPURL(inSrcset:baseURL:)` and `canonicalImageURLString(_:baseURL:)` as `internal` and call them. This matters because Medium/Guardian lazy-load: the real URL lives in `srcset` or `data-src`, not `src`. For `<figure>`, emit the `<img>` line and use `<figcaption>` text as the alt/caption. Skip `data:` URIs, tracking pixels, and images smaller than ~100×100 when `width`/`height` attributes are present (avatars and 1px beacons).
  2. **Rename downloaded files after the article**, per Fabio's request. In `Verso/Sources/Services/ArticleMarkdownImageLocalizer.swift` the media directory is already `{articleStem}.media/`, but individual files are `UUID().uuidString + ext`. Change to a stable, ordered, filesystem-safe name: `{articleStem}-01.jpg`, `-02.png`, … numbering in document order, zero-padded to 2. Truncate `{articleStem}` to ~80 chars (the article stem can already be 100+ chars and the full path has limits). On a name collision inside the media dir, append `-b`, `-c`. Keep the existing dedupe (`remoteToFilename`) so the same remote URL downloads once and both references point at the same file.
  3. Verify `ICloudFileWatcher` / the library scan ignore `*.media` directories so the sidecar folders never surface as articles. Fix if they don't.
  4. Confirm the media folder is deleted alongside the article when an article is deleted, and moved with it on archive (`Archive/`). Add it if missing — orphaned media folders in the user's iCloud Drive are a visible, user-owned-files problem.

  **Acceptance.**
  - Re-import the Medium article: the hero image and any inline images appear in the reading view.
  - On disk: `2026-08-30 Article <title>.md` sits beside `2026-08-30 Article <title>.media/` containing `…-01.jpg`, `…-02.jpg`, and the markdown links them as `./<stem>.media/<stem>-01.jpg`.
  - A Guardian article (`<picture>` + `srcset`) and a Substack article both bring their images across.
  - Offline / 404 image: the article still saves, the failed image degrades to the placeholder, no crash.
  - The `.media` folder does not appear as an article in the list.
  - Unit tests for the naming scheme and for `collectLines` emitting image markdown from `src`, `srcset` and `data-src` fixtures.

- [ ] 🟡 **FAB-296** · Duplicate articles appear in the list despite the duplicate check  `Todo` `Medium`

  **Symptom.** The article list shows the same article twice.

  **Context.** Duplicate detection already exists — `ArticleDuplicateFinder.findDuplicate(of:libraryFolder:)`, wired into both `ShareViewModel.performSave` and `AddArticleView`, with a prompt offering *update existing* / *save a copy* (`DuplicateSaveResolution`). So this is a set of holes in an existing feature, not a missing feature. **Reproduce and identify which hole this is before writing code** — do not fix all four blindly.

  **Candidate causes, in likelihood order.**
  1. **URL normalization too weak.** `VersoArticleURL.canonicalKey` (`Verso/Shared/VersoArticleURL.swift`) only lowercases scheme/host, strips the fragment and one trailing slash. It keeps the query string, so Medium's share URLs (`?source=friends_link`, `?sk=…`) and any `utm_*` parameters produce a different key for the same article. This is almost certainly what happened here.
  2. **The check is skipped silently.** `performSave` wraps the whole duplicate check in `if let libraryURL = LibraryBookmarkResolver.resolveLibraryFolderURL()`. When the bookmark is missing or fails to resolve, the extension saves without checking and says nothing. `LibraryBookmarkResolver` also computes `isStale` and then ignores it.
  3. **Scan scope too narrow.** `ArticleDuplicateFinder.scanDirectory` passes `.skipsSubdirectoryDescendants` and only looks at the library root and `Archive/`. Any article in another subfolder is invisible to the check.
  4. **No backstop at ingest.** `PendingArticleIngester.writeToDisk` / `upsertCoreData` (`Verso/Sources/Services/PendingArticleIngester.swift`) trust `pending.duplicateResolution`; when it is `nil` they always create a new file and a new `Article` row, with no re-check — even though the app, unlike the extension, always has folder access.

  **Fix.**
  1. Harden `VersoArticleURL.canonicalKey`: strip a known tracking-parameter set (`utm_*`, `source`, `sk`, `gi`, `ref`, `ref_src`, `fbclid`, `gclid`, `mc_cid`, `mc_eid`, `_branch_match_id`), sort the surviving query items by name, drop an empty query entirely, strip a leading `www.`, and normalize `http` → `https` for comparison purposes only (never rewrite the stored `url:` frontmatter — that is the user's record of where the article came from). Also consider `<link rel="canonical">` from the fetched HTML as a second key when present; if you add it, store it as a separate `canonical_url:` frontmatter field rather than overwriting `url:`.
  2. Add the missing backstop in `PendingArticleIngester`: when `pending.duplicateResolution == nil`, run `ArticleDuplicateFinder.findDuplicate` against the resolved library folder before writing. On a hit, do **not** silently overwrite — write the article, then surface an in-app prompt (same two options as the extension: *Update existing* / *Keep both*) so the user decides, matching the behaviour Fabio asked for. If a prompt at ingest time is too disruptive, the acceptable fallback is: keep both, and mark the newer one so the list can show a "possible duplicate" affordance. **Ask Fabio which he prefers before implementing this step** — it's a UX decision, not a technical one.
  3. Drop `.skipsSubdirectoryDescendants` from `scanDirectory` and walk the library recursively, skipping hidden dirs and `*.media` folders. Guard performance: the scan reads only the frontmatter of each file (it already does), so a few thousand files is fine, but add an early `break` once a match is found (already the case) and measure on a large library.
  4. Make the skipped-check case visible: when `LibraryBookmarkResolver.resolveLibraryFolderURL()` returns nil in the extension, log it and show the user that the library folder isn't reachable rather than saving silently. Honour `isStale` by refreshing the bookmark when possible.
  5. Add a defensive uniqueness check in `upsertCoreData` before inserting: if an `Article` row already exists with the same `filePath`, update it instead of inserting. This catches double-ingest of the same pending JSON.

  **Acceptance.**
  - Sharing the same Medium article twice — once as a clean URL, once with `?source=friends_link&sk=…` — triggers the duplicate prompt both times.
  - Choosing *Update existing* leaves exactly one row in the list and one file on disk, with `added`, `status`, `scroll_position` and `tags` preserved (`MarkdownWriter.replaceArticle` already does this — verify it still holds).
  - Choosing *Keep both* produces two clearly distinguishable entries.
  - An article living in a library subfolder is found by the check.
  - Unit tests for `VersoArticleURL.canonicalKey` covering: tracking params, query ordering, `www.`, `http` vs `https`, trailing slash, fragment. Plus a `ArticleDuplicateFinder` test over a temp directory tree with a nested subfolder.

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



