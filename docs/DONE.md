# Verso — Completed Issues

> Archive of all completed issues. See [BACKLOG.md](BACKLOG.md) for open work.

**190 completed issues.**

## iOS

### Bugs — import & rendering (reported by Fabio 2026-08-30)

- [x] 🟠 **FAB-294** · Share Extension imports page chrome as body text  `Done` `High`
  The Share Extension's `SwiftSoupParser` path leaked Medium-style page chrome (tag lists, toolbar labels like "Listen"/"Share", "N min read ·") into the saved article body: `collectLines` emitted every bare text node it walked past — including ones inside `<button>`/`<span>`/`<figcaption>` wrappers — and the extension never ran the cleanup pass (`HTMLToMarkdownConverter.sanitizeMarkdownBody`) the in-app Readability path already gets. Completed 2026-08-30.

  ## Fix

  * **`SwiftSoupParser.extractContentMarkdown`**: widened the DOM noise-removal selector to also drop `button, form, noscript, svg, iframe`, ARIA `[role=button]`/`[aria-hidden=true]`, and known Medium widget containers (`[data-testid*=audio/headerClap/headerSocial]`).
  * **`collectLines`**: removed the bare-`TextNode` branch that was the actual leak — `p`/`li`/`h1`–`h6`/`blockquote`/`pre`/`code` already emit text correctly via `element.text()`; anything else now only contributes structure via recursion, not orphaned text. Added minimal `td`/`th` cases so incidental table cell text (no GFM rendering yet — that's FAB-293) degrades to loose lines instead of disappearing outright.
  * **Moved `HTMLToMarkdownConverter`** out of `Sources/Services/ReadabilityParser.swift` (main-app-only) into `Verso/Shared/HTMLToMarkdownConverter.swift` so the Share Extension target can call it too — `Shared` was already a folder-based source for both targets in `project.yml`, so no target-membership change was needed, just `xcodegen generate`.
  * `extractContentMarkdown` now runs its output through `HTMLToMarkdownConverter.sanitizeMarkdownBody(_:articleTitle:)` before returning, giving the extension the same title-echo removal, duplicate-block collapse, and noise-line filtering the in-app path already had.
  * Extended `fullscreenLineFingerprints` with the reported labels (`listen`, `share`, `member-only story`, `featured`, `sign up`/`sign in`, `follow`, `press enter or click to view image in full size`) and added generic drop rules for digit-only lines, punctuation-only lines (`–`, `·`, `—`), and `^\d+\s*min read\s*·?$`.

  ## Verified

  New unit tests in `Verso/VersoTests/SwiftSoupParserTests.swift` (a synthetic Medium-like HTML fixture reproducing the reported junk) and `HTMLToMarkdownConverterNoiseTests` (the new drop rules in isolation) — 11 tests, all passing. `xcodegen generate` + `xcodebuild build` succeeded for both the `Verso` and `ShareExtension` schemes; full `VersoTests` suite (17 tests) passes. Real-device confirmation against the original reported Medium article is Fabio's part after this PR.

- [x] 🟠 **FAB-295** · Imported articles have no images  `Done` `High`
  Articles saved through the Share Extension had no images at all. Not a download or renderer bug — `SwiftSoupParser.collectLines` simply had no `img`/`picture`/`figure` case, so `<img>` elements (void, no children) emitted nothing, the markdown never contained a `![](…)` reference, and the existing localizer/renderer had nothing to act on. Completed 2026-08-30, on top of FAB-294's `HTMLToMarkdownConverter` move.

  ## Fix

  * **`SwiftSoupParser.collectLines`**: added `img`/`picture`/`figure` cases, threading a `baseURL` (the article's source URL) through `extractContentMarkdown` → `htmlToMarkdown` → `collectLines` for relative-path resolution.
    * `img`: resolves via SwiftSoup's own `element.outerHtml()` fed into `HTMLToMarkdownConverter.resolvedHTTPImageURL(forImgTag:baseURL:)` — reusing the exact tested src/srcset/lazy-load priority order rather than re-deriving it. Skips 1px trackers/avatars when `width`/`height` are both present and under 100.
    * `picture`: reuses `HTMLToMarkdownConverter.bestImageURLAndAlt(inHTMLFragment:baseURL:)` against the element's own inner HTML — the same "best of `<source srcset>` / `<img>`" logic already proven for Guardian's markup.
    * `figure`: prefers a nested `<picture>`, else a nested `<img>`; a non-empty `<figcaption>` becomes the caption/alt — but only after screening it with `HTMLToMarkdownConverter.isNoiseLine` first, so a lightbox label like "Press enter or click to view image in full size" sitting in a `<figcaption>` isn't promoted into a visible caption (caught by the new tests, not by manual review). Falls back to normal recursion when no image is found, so a figure wrapping something else (e.g. a code block) doesn't lose its content.
  * Exposed three more `HTMLToMarkdownConverter` members as `internal`: `resolvedHTTPImageURL(forImgTag:baseURL:)`, `bestImageURLAndAlt(inHTMLFragment:baseURL:)`, `markdownSafeAltText(_:)`, `isNoiseLine(_:)`.
  * **`ArticleMarkdownImageLocalizer`**: downloaded files now get stable, ordered names (`{stem}-01.jpg`, `-02.png`, …, zero-padded, per Fabio's request) instead of `UUID().uuidString`. The filename *prefix* truncates the stem to 80 chars (the `.media` directory name itself is untouched, so already-saved articles keep working); a same-name collision inside one article's media folder appends `-b`, `-c`, … (letters start at "b", matching `MarkdownWriter.uniqueFilename`'s existing "(2)", "(3)" convention where the plain name is the implicit first variant).
  * **`MarkdownWriter.delete`/`archive`**: both now carry the `{stem}.media` sidecar folder along — removed on delete, moved into `Archive/` on archive — so an article's downloaded images don't become orphaned files in the user's iCloud Drive. Best-effort (`try?`) so a media-cleanup hiccup never fails the primary operation, which had already succeeded.
  * Verified, no code change needed: `MarkdownReader.readAll` and `ArticleDuplicateFinder.scanDirectory` both filter on `fileURL.pathExtension == "md"`, so a `Foo.media` directory was already safe from appearing as an article.

  ## Verified

  New tests: `SwiftSoupParserImageTests` (bare `<img>`, lazy `data-src`, Guardian-style `<picture>`+`srcset`, figure+figcaption-as-alt, figcaption-noise-not-promoted, figure-fallback-on-non-image-content, tracking-pixel skip, no-dimensions-not-skipped, relative-URL resolution — 8 tests), `ArticleMarkdownImageLocalizerTests` (stem truncation, collision-letter naming — 7 tests), plus 4 new `MarkdownWriterTests` cases for delete/archive carrying or no-oping on the `.media` folder. 57 tests total in `VersoTests`, all passing. `xcodegen generate` + `xcodebuild build` succeeded for both the `Verso` and `ShareExtension` schemes. Not verified here: an actual live Share Extension import with real images (Medium/Guardian/Substack) — Fabio's part after the PR.

### Design critique 2026-09-01/03 — publisher-shaped parsing gaps

- [x] 🔴 **FAB-315** · Image captions are printed twice  `Done` `Urgent`
  An article's image caption rendered under the image *and again* as a full body paragraph, e.g. "…in the 1960s. Photograph: João Laet/The Guardian" — seen on a Guardian article, critique §6.7, 2026-09-01. Completed 2026-09-03, same PR as FAB-332.

  ## Cause

  `HTMLToMarkdownConverter.collapseImageCaptionEcho`'s de-dupe guard already existed but was one comparison too strict: it required `fingerprint(alt) == fingerprint(next)` (exact equality), and publishers appending a photo credit to the echoed paragraph defeat that.

  ## Fix

  New `HTMLToMarkdownConverter.isImageCaptionEcho(alt:followingParagraph:)`: matches on prefix rather than equality — drops the next block when it *starts with* the alt text and the remainder (after trimming leading punctuation left behind by e.g. "...1960s. Photograph: X") is short or starts with a recognized credit prefix (`Photograph:` / `Photo:` / `Credit:` / `Illustration:`). A paragraph that merely shares a prefix before continuing into unrelated content is left alone — only a short/credit-shaped remainder counts as an echo.

- [x] 🔴 **FAB-332** · Publisher chrome and title suffixes survive into the reader  `Done` `Urgent`
  Two content-quality defects on the same CNN article, 2026-09-03: a flattened social-share bar ("Facebook Tweet Email Link Threads Link Copied!") rendered as the first body paragraph, and the title kept its publisher suffix ("God save the drag kings of England | CNN") into the H1, top bar, and article card. Completed 2026-09-03, same PR as FAB-315 — same family of publisher-shaped parsing gaps, same converter and test suite.

  ## Fix

  1. **Share-bar noise line**: `HTMLToMarkdownConverter.isNoiseLine` gained `isShareBarLine` — a short line is treated as noise when most of its words are known share-platform/action tokens (Facebook, Twitter/Tweet/X, Email, Link, Threads, WhatsApp, Reddit, Pinterest, LinkedIn, Messenger, Print, Copy/Copied, …) *and* at least one is an unambiguous platform name, so an ordinary sentence containing a generic word like "link" isn't swept up. "Link Copied!" alone is also caught, via an added exact fingerprint. Considered selecting these structurally by class/role in SwiftSoup instead, but publisher share-bar markup has no consistent class/role across sites — kept it a text heuristic, consistent with every other noise rule here and shared across both import paths.
  2. **Title suffix stripping**: new `HTMLToMarkdownConverter.stripPublisherTitleSuffix(_:siteName:host:)` strips a trailing ` | X` / ` - X` / ` — X` only when `X` matches the article's `siteName` or URL `host` (letters-only containment, so a subdomain like `edition.cnn.com` still matches "CNN") — not a blind "strip after any separator," so a title with a legitimate subtitle survives. Called once, right after title extraction, in both `SwiftSoupParser.parse` and `ReadabilityParser`'s completion handler, so the cleaned title flows into `PendingArticle.title` (and into the existing title-echo stripping) — meaning the card, top bar, and H1, which all render that same stored field, inherit the fix from one place.

  ## Verified

  New tests in `Verso/VersoTests/SwiftSoupParserTests.swift`: `HTMLToMarkdownConverterNoiseTests` (caption-echo-with-credit, exact-duplicate regression, prefix-without-credit guard), `HTMLToMarkdownConverterShareBarTests` (flattened share bar, standalone "Link Copied!", ordinary-sentence-with-"link" guard), `HTMLToMarkdownConverterTitleSuffixTests` (pipe/dash suffix stripped via siteName/host, non-matching suffix left alone, no-siteName-or-host left alone), and a full-pipeline `SwiftSoupParserTests.testCNNArticleDropsShareBarAndStripsTitleSuffix` reproducing the reported article. `xcodebuild build` succeeded; the full updated test suite passes. Not verified here: a live add-by-URL import of the actual CNN/Guardian articles through `ReadabilityParser` — Fabio's part after the PR.

### Design critique 2026-09-03 (Ink theme + onboarding pass)

- [x] 🔴 **FAB-330** · "Continue Reading" progress caption reads "0 read" instead of "0% read"  `Done` `Urgent`
  Cards in Continue Reading showed `0 read`, `20 read`, `3 read` where the value is a percentage — parses as a count, and "0 read" on an article the section claims you're mid-way through is actively contradictory. Seen 2026-09-03 in the Ink theme. Completed 2026-09-03.

  ## Cause

  The BACKLOG entry's original diagnosis ("the string has no percent marker") turned out to be imprecise. `Localizable.xcstrings`'s translated value for `home.section.continueReading.progressCaption` already contained a `%` in all three locales (`"%lld% read"` / `"%lld % lu"` / `"%lld% lido"`, matching `UI_COPY.md` exactly) — but it was a raw, unescaped `%` sitting next to the `%lld` numeric placeholder. `String(localized:)` substitutes that placeholder via Foundation's printf-style formatting, where a literal `%` must be escaped as `%%`; left unescaped, the formatter consumed it as a broken conversion specifier and silently dropped it. Confirmed empirically: `String(format: "%lld% read", 42)` → `"42 read"`, `String(format: "%lld%% read", 42)` → `"42% read"`.

  ## Fix

  Escaped the literal `%` in all three `Localizable.xcstrings` locale values for that one key (`"%lld%% read"` / `"%lld %% lu"` / `"%lld%% lido"`). No change needed to `ArticleCard.swift` (already passes the correct `Int`), `Verso/Generated/L10n.swift` (its `defaultValue` uses plain Swift string interpolation, not printf formatting — unaffected), `UI_COPY.md` (content was already correct), or the VoiceOver value `a11y.progress.value` (`"%lld percent"` spells out the word "percent" instead of using a `%` character, so it never hit this trap). FAB-278's percent→time-remaining redesign for this caption remains a separate, deferred decision.

  ## Verified

  `xcodebuild build` succeeded for the `Verso` scheme (confirms the string catalog still compiles). Re-ran the printf escaping check against the corrected values for all three locales before committing. Not verified here: seeing the corrected caption render on a real Continue Reading card — Fabio's part after the PR.

- [x] 🟠 **FAB-331** · Articles at 0% fill up "Continue Reading"  `Done` `High`
  Seen 2026-09-03: four of five Continue Reading cards showed 0% progress. `ArticleReaderView`'s `.task` calls `advanceStatus(to: .reading)` on open, unconditionally — opening an article and immediately going back set `.reading` permanently, and the section filtered on `statusEnum == .reading` with no progress floor. Every accidental tap landed in Continue Reading forever. Completed 2026-09-04.

  ## Fix

  Took the BACKLOG entry's lower-risk default: filter on `scrollPosition > 0` rather than changing when `.reading` gets set (the promote-to-`.reading` floor stays deferred, revisit post-launch if the filter proves insufficient).

  A bare filter alone would have made a 0%-progress `.reading` article vanish from every section — it fails `.reading`'s new floor and its persisted status genuinely isn't `.unread`. Added `Article.displayStatusEnum` (`Verso/Model/Article.swift`) instead: downgrades a `.reading` article with zero scroll progress back to `.unread` for display only, leaving the persisted `status` untouched. Two call sites switched from `statusEnum` to `displayStatusEnum`: `ArticleListView`'s three section filters (`continueReadingArticles`/`unreadArticles`/`readArticles`) and `ArticleCard`'s `displayStatus` (the `StatusBadge` source) — so an article that falls back to Unread also loses its "reading" badge, not just its section. Every other `statusEnum ==` use (the read/unread toggle logic) stays on the real, persisted status.

  ## Verified

  `xcodebuild build` succeeded for the `Verso` scheme. Not verified here: opening an article and backing out immediately to confirm it no longer appears in Continue Reading, and that scrolling partway into another article still promotes it correctly — Fabio's part after the PR.

### Backgrounding corrupts app state (design critique 2026-09-01, four-cause investigation through 2026-09-04)

- [x] 🔴 **FAB-304** · Backgrounding the app corrupts app state: empty article list, lost reading progress, broken scroll restore  `Done` `Urgent`
  ## History

  Completed 2026-09-04, after four rounds of on-device testing turned up four independent causes. Originally reported 2026-09-01 as: switching theme in Settings across the light/dark boundary (e.g. Ink → Sepia) left the screen blank. Diagnosed and fixed in [PR #360](https://github.com/whysasse/verso-app/pull/360) — see cause/fix below, still valid and shipped. Fabio then tested that PR and reported the blank-screen symptom **still happens**, via a different repro that has nothing to do with Settings or switching theme: reading an article, backgrounding via the app switcher, returning — the body text is blank while the top/bottom chrome renders fine, and tapping/scrolling brings it back. A double-tap while blank still selected text, so the content is present, just not painted. Reopened rather than filed as a new issue, since it's the same reported symptom with a second, independent cause.

  Fabio then tested cause 2's fix on-device 2026-09-04 and reported it did **not** hold — but with a different, more severe symptom cluster than either documented cause: after backgrounding via the app switcher and returning, (a) the article list briefly rendered the genuine "No articles yet" empty state (recovered only by force-quitting and relaunching), (b) a reopened article's saved scroll position landed near the bottom of the article instead of near the top (self-corrected after leaving and reopening), and (c) after switching themes back at the list, an article that had been in "Continue Reading" reverted to "Unread". Screenshots: `docs/printscreens/bugs-2026-09-04/`. This is Cause 3 below — see it for why (a) and (c) are the same root cause; (b) is unconfirmed but plausibly downstream of the same Core Data churn and should be re-checked once cause 3's fix is device-confirmed.

  Fabio tested cause 3's fix on-device same day (2026-09-04): (a) and (b) both held — list stayed populated across backgrounding, scroll position restored correctly. But (c) recurred with a **fresh** article (opened for the first time under the fixed build, ruling out leftover state from the earlier broken session) — it dropped from "Continue Reading" back to "Unread" right when Fabio switched themes in Settings. Checking the file directly (Files app → Quick Look) showed it still correctly said `status: reading` — the file was never wrong, only Core Data was. That pointed at a fourth, independent cause: Cause 4 below.

  ## Cause 1 (fixed, PR #360) — Settings push torn down by a theme-driven rebuild

  `showSettings` (`@State` on `ArticleListView`) drove `.navigationDestination(isPresented: $showSettings) { SettingsView() }`, but that modifier was registered inside the private `ArticleListFetchedBody`, which `ArticleListView` instantiates with `.id(listFetchIdentity)` — a key that changes with search/date, and — per `ContentView.swift`'s `.preferredColorScheme(themeManager.currentTheme.isDark ? .dark : .light)` — gets torn down and rebuilt whenever a theme switch crosses the light/dark boundary and forces a hosting-hierarchy rebuild. When that subtree rebuilt, its `navigationDestination` registration went with it, but `showSettings` (owned one level up) survived as `true`: a pushed slot with no destination left to resolve it.

  **Fix:** in [`ArticleListView.swift`](<Verso/Sources/Screens/ArticleList/ArticleListView.swift>), moved the `navigationDestination` onto `ArticleListView.body` itself, next to `.toolbar(.hidden, for: .navigationBar)` — a stable ancestor nothing re-keys. Removed the now-unused `showSettings` binding plumbing from `ArticleListFetchedBody`. Left the two similarly-shaped `.sheet`s (`showFolderPicker`/`showAddArticle`) and `ContentView`'s `.preferredColorScheme` untouched (removing the latter would trade this bug for system chrome no longer following the theme in Night/Ink).

  ## Cause 2 (fixed, device-confirmed) — reader's UIKit text views don't repaint after returning from background

  The reading view's body isn't pure SwiftUI text: `HighlightableRegionText` ([HighlightableRegionText.swift](<Verso/Sources/Components/Reading/HighlightableRegionText.swift>)) is a `UIViewRepresentable` wrapping a custom `UITextView` subclass (`HighlightableUITextView`), needed for FAB-54/FAB-303's highlighting feature (a selection-change hook and per-run background color that plain SwiftUI `Text` doesn't offer). `MarkdownBodyView` creates one per contiguous region of blocks, so an article's body is several separate `UITextView`s inside a plain `ScrollView`. Nothing in the reading path (`ArticleReaderView`, `MarkdownBodyView`, `HighlightableRegionText`) observed `scenePhase`/`UIApplication.didBecomeActiveNotification`. `HighlightableUITextView` overrides `draw(_:)` for the blockquote accent bar, and iOS gives no guarantee that a custom-drawn view's backing store survives being backgrounded — explaining the exact shape of the symptom: chrome (SwiftUI-native) redraws fine, the UITextView-backed body doesn't until something forces a layout pass, and selection still works while blank because TextKit's layout geometry (used for hit-testing) is untouched by a lost backing store.

  **Fix:** `HighlightableUITextView` now observes `UIApplication.didBecomeActiveNotification` and calls `setNeedsLayout()`/`setNeedsDisplay()` on return to foreground, removing the observer in `deinit`. Scoped to the one class doing custom drawing rather than threading `scenePhase` through three files for the same effect.

  **Alternate theory considered in the original writeup:** `VersoApp.swift` calls `articleLibraryService.rebuildCache(...)` unconditionally on every `scenePhase == .active` transition, not just cold launch, which could in principle invalidate a Core Data object out from under an open `ArticleReaderView`. Set aside at the time because Fabio's repro showed the text was still there (selectable), pointing at a pure redraw problem rather than a data problem — this turned out to be right about cause 2 but wrong to set aside: it's exactly cause 3, below.

  ## Cause 3 (fixed and device-confirmed, 2026-09-04) — `rebuildCache` reads the folder without security-scoped access after the first backgrounding of a session

  [`FolderBookmarkService.swift`](<Verso/Sources/Services/FolderBookmarkService.swift>) only calls `startAccessingSecurityScopedResource()` in `restore()` (app launch) and `save()` (picking a folder). [`VersoApp.swift`](<Verso/Sources/App/VersoApp.swift>)'s `scenePhase` handler calls `folderBookmarkService.stopAccess()` on `.background` — but nothing re-acquires access on the following `.active` transition before it kicks off `PendingArticleIngester().ingest(...)` and `articleLibraryService.rebuildCache(...)`. So from the *first* backgrounding of a session onward, access to the iCloud folder is permanently revoked except for whatever any other call happens to have open at that instant.

  `PendingArticleIngester.ingest` and every write helper in `ArticleReaderView` (`loadContent`, `persistStatusToMarkdownFile`, `persistScrollToDisk`) already bracket their *own* access with `start...`/`stop...` + `defer`, so they keep working regardless. `ArticleLibraryService.rebuildCache` was the one call site that didn't — it assumed access was already open and called `MarkdownReader.readAll(from: folderURL)` directly. Every rebuild after that first backgrounding therefore raced whatever unrelated bracket happened to still be open elsewhere in the app:

  - **Lost race** → `MarkdownReader.readAll` returns zero files → `rebuildCache`'s stale-record cleanup ("remove records whose files no longer exist on disk") saw *no* real paths and deleted every cached `Article` row, since Core Data is a read cache rebuilt from files (see AGENTS.md) — the list genuinely rendered "No articles yet" (screenshot (a) above), fixed only by relaunching, which is the only other thing that calls `restore()`. A later successful rebuild recreating a row from whatever the file said at that racy moment plausibly also explains (c): the "reading" status was correctly written to disk (see below), but a rebuild that raced a still-in-flight write could recreate the row before that write landed.
  - **Won race** (piggybacked on `PendingArticleIngester`'s or another call's still-open bracket) → worked fine, hence the intermittent, hard-to-pin-down nature of all three symptoms.

  **Fix:** [`ArticleLibraryService.swift`](<Verso/Sources/Services/ArticleLibraryService.swift>)'s `rebuildCache` now brackets its own access (`startAccessingSecurityScopedResource()` / `stopAccessingSecurityScopedResource()` via `defer`), the same pattern every sibling call site already uses — self-sufficient instead of depending on ambient state set up elsewhere. Belt-and-suspenders: the stale-record cleanup now also refuses to run when the parsed read comes back empty while Core Data already has cached rows (`readLooksValid = !parsedArticles.isEmpty || existing.isEmpty`), so *any* other way a folder read can fail (permission revoked, iCloud volume briefly unreachable, a transient I/O error) can no longer be misread as "the user deleted every article." The one case this doesn't cover — a folder genuinely emptied by the user through Finder/Files while nothing was reading from it — is indistinguishable from a bad read by design, so the cache is left alone rather than risk a repeat of this bug; documented inline in `ArticleLibraryService.swift`.

  Covered by [`ArticleLibraryServiceTests.swift`](<Verso/VersoTests/ArticleLibraryServiceTests.swift>), which reproduces the race directly (an empty/failed read against a populated cache) and asserts the cache, status, and scroll position all survive. Full `VersoTests` suite (198 tests) passes.

  ## Cause 4 (fixed and device-confirmed, 2026-09-04) — `rebuildCache`'s folder scan isn't atomic with respect to concurrent local writes

  Cause 3's fix made `rebuildCache` succeed reliably instead of usually failing outright — which exposed a second, independent bug in the same function that cause 3's fix didn't touch: `rebuildCache` reads every file in the folder via `Task.detached` (real wall-clock I/O, potentially many files, on iCloud storage), then applies that snapshot to Core Data afterwards. Nothing stops a write from landing on one of those files *while the scan is still in flight*. Confirmed exactly this on-device: `ArticleReaderView.advanceStatus` wrote `status: reading` to a file correctly and quickly (synchronous, no `await` before it, per `ArticleReaderView.swift`'s `.task`) — but a `rebuildCache` that had *already started* scanning captured that file's *older* `status: unread` before the write landed. When that rebuild's upsert loop ran, it applied the stale snapshot to the already-correct Core Data row, reverting `status` back to `unread` even though the file itself was never wrong. The subsequent theme switch (cause 1's mechanic — a light/dark boundary crossing forces `ArticleListFetchedBody` to rebuild) didn't cause this; it just re-fetched and surfaced whatever Core Data already, incorrectly, held.

  This is a different bug from cause 3: cause 3 was about the read failing outright (no access); cause 4 is about a *successful* read being stale by the time it's applied. Fixing cause 3 made cause 4 far more exposed, since `rebuildCache` now runs to completion successfully on nearly every foreground and file-watcher event instead of usually erroring out early.

  **Fix:** [`ArticleLibraryService.swift`](<Verso/Sources/Services/ArticleLibraryService.swift>) now captures `scanStartedAt = Date()` immediately before the folder scan begins. In the upsert loop, before applying a parsed file's fields to an *existing* Core Data row, it stats that one file's current modification date (cheap — no re-read) and skips applying any fields for it this round if the file was modified after `scanStartedAt`. That file's fresher content — plus, most likely, the very write that changed it — will be picked up correctly on the next rebuild (triggered by that same write's file-watcher notification, or the next `scenePhase`-active pass), rather than this round silently reverting it to a stale snapshot.

  Covered by two new `ArticleLibraryServiceTests`: one reproduces the race deterministically (a file's modification date is pushed into the future relative to `scanStartedAt`, standing in for "written after the scan started" without needing to race real concurrent timing) and confirms the existing Core Data row's status/scroll position survive; a second confirms the guard doesn't become a blanket "never trust the file" — an ordinary, non-racing status change on disk still gets applied. Full `VersoTests` suite passes.

  ## Verify

  `xcodebuild build` (Verso scheme) succeeded; `xcodebuild test` (VersoTests, 200 tests) passed, including the new `ArticleLibraryServiceTests` (5 tests covering causes 3 and 4).

  **Round 2 (2026-09-04):** Fabio confirmed cause 3's fix held for (a) the empty list and (b) the scroll-restore position — both fixed. (c) the status-revert-to-unread recurred with a fresh article, traced to cause 4.

  **Round 3 (2026-09-04):** Fabio re-tested cause 4's fix on-device — held. [PR #365](https://github.com/whysasse/verso-app/pull/365) merged.

### Design critique 2026-09-01 — white-on-accent contrast (FAB-305)

- [x] 🔴 **FAB-305** · White-on-accent fails WCAG AA in Night and Ink  `Done` `Urgent`
  Critique §3.1. `VersoButtonStyle.primary` hardcoded `.foregroundColor(.white)` on a `theme.accent` fill. Accent is light in both dark themes, so white-on-accent nearly disappeared: Night 2.25:1, Ink 2.71:1 — both failed even the 3:1 non-text floor. Same hardcoded white also showed up in two places styled by hand instead of through the shared button style: the `+` add-article glyph and the active-filter count badge in the list header. Completed 2026-09-04.

  ## Fix

  * **`VersoButtonStyle.primary`** ([`VersoButton.swift`](<Verso/Sources/Components/Buttons/VersoButton.swift>)): label color now inverts per theme (`theme.background` on `theme.accent`) instead of hardcoded white — the pattern already proven correct in `FolderPickerPrompt.swift`. Passes AA on all 4 themes (Paper 4.87 / Sepia 4.98 / Night 7.71 / Ink 6.82).
  * **`ArticleListView.swift`**: the `+` add-article glyph and the active-filter count badge both switched from `.foregroundColor(.white)` to `.foregroundColor(themeManager.colors.background)`, same fix as above.
  * **Also added, per the critique's "Also add" note:** a real disabled state for `VersoButtonStyle.primary`, reading `@Environment(\.isEnabled)` — muted `theme.surface` fill, `theme.textSecondary` label, thin `theme.border` stroke for definition — replacing the `.opacity(0.4)` / `.opacity(0.5)` hacks in `AddArticleView`'s Save button and `OnboardingFolderPickerView`'s Continue button, which dragged an already-borderline color to 1.55:1 in Paper. `textSecondary`-on-`surface` computes to 4.52–4.58:1 across all four themes — real AA, not an opacity fake.

  ## Verify

  `xcodegen generate` + `xcodebuild build` (Verso scheme, iOS Simulator destination) succeeded. Contrast numbers computed with the standard WCAG relative-luminance formula against the actual hex values in `Colors.swift`, not eyeballed.

### Design critique 2026-09-01 — onboarding theme-picker contrast (FAB-306)

- [x] 🔴 **FAB-306** · Onboarding theme-picker card labels fail contrast in 8 of 16 states  `Done` `Urgent`
  Critique §4.2. `ThemePreviewCard` (in `OnboardingThemePickerView.swift`) colored its label with **the card's own theme's** `accent`/`textSecondary`, painted on the **currently active theme's** background — the label sits outside the card, on the app background. Half the combinations failed 4.5:1 at 13pt; worst was the Night card at 1.85:1 while on Sepia. Completed 2026-09-04.

  ## Fix

  `ThemePreviewCard` now takes the active theme's `ThemeColors` as a parameter (`activeColors`, passed down from `OnboardingThemePickerView.body`'s existing `colors`) and uses it for the label's `foregroundColor` instead of the card's own `themeColors` — the same pattern `ThemeSelector`/`ThemeChip` in Settings already used correctly (caller passes its active `accentColor`/`textColor` in). The card's interior preview (mini background, fake text lines, border/stroke) is unchanged — it's correct to stay in that theme's own colors.

  ## Verify

  `xcodegen generate` + `xcodebuild build` (Verso scheme, iOS Simulator destination) succeeded. Real-device/simulator visual confirmation across all 4 themes is Fabio's part.

### Design critique 2026-09-01 — immersive chrome hit-testing + VoiceOver (FAB-307)

- [x] 🟠 **FAB-307** · Immersive chrome: hidden bars stay hit-testable, and VoiceOver decisions were never implemented  `Done` `High`
  Critique §3.7, §3.8. Two related gaps in `ReadingChrome.swift` / `ArticleReaderView.swift`. **Hit testing:** `ReadingTopBar` and `ReadingBottomBar` hid via `.opacity(isVisible ? 1 : 0)`, which does not disable hit-testing in SwiftUI — the invisible top bar's Back button kept catching the reveal tap in immersive mode. **VoiceOver:** `UIAccessibility.isVoiceOverRunning` appeared nowhere in the codebase, so none of accessibility-specs.md §5.3's three signed-off decisions were built. Completed 2026-09-04.

  ## Fix

  * Added `.allowsHitTesting(isVisible)` next to `.opacity(isVisible ? 1 : 0)` on both `ReadingTopBar` and `ReadingBottomBar` — the whole hit-testing fix.
  * `ArticleReaderView` now tracks `isVoiceOverRunning` and observes `UIAccessibility.voiceOverStatusDidChangeNotification` live. While VoiceOver is running the immersive tap gesture no longer hides chrome, and turning VoiceOver on mid-session immediately brings chrome back.
  * Built the `hasShownImmersiveHint` UserDefaults flag referenced by the spec but never implemented — the "tap anywhere to reveal" hint pill now shows once ever (previously it re-appeared on every immersive toggle), and the flag write only ever happens from the non-VoiceOver code path, satisfying the spec's "must not write during a VoiceOver session."
  * **Note on scope:** the spec/issue describe an "auto-hide timer" for the chrome; there isn't one in this codebase — tap is the only way chrome ever hides — so "must not auto-hide while VoiceOver runs" was implemented as "must not become hidden at all while VoiceOver runs."
  * Out of scope, left for a future issue: `reduceTransparency` and `differentiateWithoutColor`, mentioned once in the critique as unrelated observations, not in its fix list.

  ## Verify

  `xcodebuild build` (Verso scheme, iOS Simulator destination) succeeded, no new warnings in the changed files. Not verified here: the actual repro (tap top-left corner in immersive mode) and real VoiceOver behavior — no reliable headless Simulator automation for this project, so that's Fabio's part after the PR.

### Design critique 2026-09-01 — bundle OpenDyslexic-Bold (FAB-312)

- [x] 🟠 **FAB-312** · Bundle OpenDyslexic-Bold  `Done` `High`
  Critique §7.3. Only `OpenDyslexic-Regular.ttf` was bundled, and SwiftUI does not synthesise bold for custom fonts — so `.custom("OpenDyslexic-Regular", size: 28).weight(.bold)` fell back to the system font entirely, meaning every heading in every article read in OpenDyslexic lost its heading hierarchy. Completed 2026-09-04.

  ## Fix

  * Added `Verso/Resources/Fonts/OpenDyslexic-Bold.ttf`, sourced from the same upstream project (`antijingoist/opendyslexic` on GitHub, SIL OFL 1.1 — same license already vendored for the Regular face) as `compiled/OpenDyslexic-Bold.woff2`. Verified with fontTools before bundling: identical `unitsPerEm`/`ascent`/`descent`/`lineGap` and matching per-glyph advance widths against the existing Regular face, so pairing them doesn't introduce a line-height or reflow mismatch between weights; also carries the accented characters fr-CA/pt-BR need.
  * Registered `Fonts/OpenDyslexic-Bold.ttf` in `UIAppFonts` in both `Verso/project.yml` and `Verso/Resources/Info.plist` (mirroring the existing Regular entry in both). No code change needed for the reading view itself — `Typography.swift`'s `makeFont` already does `.custom(fontFamily, size:).weight(weight)`, which now resolves to a real bold face.
  * Drive-by, named in the same issue: dropped `SettingsRow.fontRow`'s `.lineLimit(1)` on the pangram preview, which truncated at default text size for OpenDyslexic's wider glyphs. Also reconciled `DesignSystemPreview.swift`'s DEBUG-only preview to request `"OpenDyslexic-Regular"` (matching the real `SettingsView`/`ReadingPreferencesService` family string) instead of `"OpenDyslexic"` — both resolved to the same font either way, but the ticket flagged the mismatch as worth cleaning up.

  ## Verify

  `xcodegen generate` + `xcodebuild build` (Verso scheme, iOS Simulator destination) succeeded; confirmed the built `.app` bundle actually contains `OpenDyslexic-Bold.ttf` and declares it in the compiled `Info.plist`'s `UIAppFonts`. Not verified here: visually confirming headings render bold in OpenDyslexic on a real Simulator/device — no reliable headless Simulator automation for this project, so that's Fabio's part after the PR.

### Design critique 2026-09-01 — rebuild reader's font/spacing sheet (FAB-311)

- [x] 🟠 **FAB-311** · Rebuild the reader's font/spacing sheet  `Done` `High`
  Critique §6.8, §6.9, §3.4, §6.2, §6.3 — four problems in `ReadingControls.swift`, the bottom sheet opened by the reader's "Font and spacing" button. Completed 2026-09-05.

  ## Fix

  * **✕ removed.** It sat directly on top of the last control in both sheet variants (the big "A" / the Ink swatch). The sheet already has a drag handle, and swipe-to-dismiss was already on by default (`.presentationDragIndicator(.hidden)` in `ArticleReaderView.swift` only hides the *system* grabber graphic, it doesn't disable interactive dismiss) — VoiceOver's system-wide two-finger "Escape" gesture still dismisses the sheet.
  * **Font-size buttons** ("A"/"A") each now sit in their own filled, bordered 44×44 container — Safari Reader's own affordance — with a real `.disabled()` state at both ends of the scale and `L10n.Reading.controlsDecreaseFontSize`/`controlsIncreaseFontSize` as accessibility labels (both strings pre-existed, unused, in `L10n.swift`).
  * **Line-spacing row** replaced the four `text.alignleft`/`text.justify`/… alignment icons (standing in for *line-height* levels, with no VoiceOver strings) with a 4-segment labelled control using `L10n.ReaderSettings.lineSpacingCompact`/`Normal`/`Relaxed`/`Airy` — pre-existing, fully translated (fr-CA/pt-BR) strings that were defined but never wired to any view. Zero new copy needed. Bumped the row to a full 44pt tall while rebuilding it.
  * **Reconnected the font-size stepper to `BodySize`.** `Typography.Reading.BodySize` (XS 14/S 16/M 18/L 20/XL 22/XXL 26) had no call sites driving the actual stepper: the reader stepped by `±1` (13 reachable values) and Settings by `±2` (7 reachable values, including `24` — not a real size). Added `BodySize.nearest(to:)` and `BodySize.stepped(by:)` in `Typography.swift`; both the reader sheet and `SettingsView.readingSection`'s font-size row now step through the same 6 named sizes and can never land on an off-scale value again (an existing off-scale stored value silently snaps to the nearest real size on next use).

  ## Explicitly out of scope

  * Settings' font-size buttons stay 32×32, no border — that sizing fix was already reassigned to FAB-334 (native-shell replaces this screen); only the stepping *logic* was this issue's concern.
  * `BodySize.lineHeightMultiplier` still has no call site. Wiring it into the reading view's actual line-height would mean deciding how it composes with the separate, user-facing compact/normal/relaxed/airy spacing choice — that composition isn't specified anywhere, and BACKLOG's FAB-333 already treats further scale work as later, stacked work. This fix only guarantees the stored size is always one of the 6 named steps, so that composition is possible later.

  ## Verify

  `xcodegen generate` + `xcodebuild build` (Verso scheme, iOS Simulator destination) succeeded, no new warnings in the changed files. Not verified here: opening the sheet on a real Simulator/device to confirm the stepper stops cleanly at both ends, the ✕ is gone with swipe-to-dismiss intact, and the line-spacing row reads Compact/Normal/Relaxed/Airy — no reliable headless Simulator automation for this project, so that's Fabio's part after the PR.

### Design critique 2026-09-01 — localize reading chrome (FAB-308)

- [x] 🟠 **FAB-308** · Localize the reading chrome's accessibility strings  `Done` `High`
  Critique §3.6. After FAB-275 and FAB-284, `ReadingChrome.swift` still had 4 hardcoded English label/hint pairs — a French or Portuguese VoiceOver user got an English reading toolbar even though everything else in the file already went through `L10n`. Completed 2026-09-05.

  ## Fix

  * **Top bar back button** ("Back" / "Returns to the article list") now uses `L10n.Reading.backAccessibilityLabel` — an existing, already fully-translated key ("Back to reading list") that was sitting unused. It also happens to match `accessibility-specs.md`'s spec'd wording ("Back to Reading List"), which the old hardcoded "Back" didn't. No hint carried over — no matching hint key existed, and the label alone is already self-descriptive (both params on `VersoToolbarIconButton` are optional, so this is a valid call shape).
  * **Bottom bar's font/spacing, TTS (both states), and theme buttons** got 7 new keys in `docs/copy/UI_COPY.md`'s "Bottom Bar (Reading Controls)" table (`reading.controls.fontAndSpacing[.hint]`, `.tts.listen`, `.tts.stopListening`, `.tts.hint`, `.readingTheme[.hint]`) — hand-translated fr-CA/pt-BR, flagged `needs_review` per the repo's existing convention.
  * Found along the way: that same table already had 8 rows (`margins`, `theme`, `markAsRead`, `markAsUnread`, `tts.play`, `tts.pause`, plus their hints) that don't match any string actually in the code — pre-authored for an earlier, unshipped version of this bar (a separate margins control, play/pause TTS phrasing) that FAB-299's ⋯-menu consolidation and FAB-318's margins-never-shipped both superseded. Confirmed unused via grep. Left in place (a real cleanup is out of scope here) but annotated in the table so the next person doesn't mistake them for live.
  * **Drive-by, named in the same issue:** `SearchBar.placeholder` dropped its hardcoded `"Search titles..."` default. Both real call sites already passed an `L10n` string, so this was dead code today but a landmine for the next caller — now the compiler enforces it.
  * `python3 docs/copy/codegen/generate.py` regenerated `Localizable.xcstrings`, `L10n.swift`, and the web `messages/*.json` files from the edited `UI_COPY.md`.

  ## Verify

  `xcodegen generate` + `xcodebuild build` (Verso scheme, iOS Simulator destination) succeeded, no new warnings in the changed files. Checked `Localizable.xcstrings` against a snapshot taken right after the codegen step — unlike FAB-311's build, this one didn't trigger Xcode's auto-extraction rewrite, so the committed file is exactly `generate.py`'s output. Not verified here: actually hearing the new VoiceOver strings in fr-CA/pt-BR on a real device — that's Fabio's part after the PR.

### Bugs — list actions & discovery (reported by Fabio 2026-08-30)

- [x] 🟠 **FAB-297** · Long-press menu shows the wrong read/unread action, and archived articles can't be unarchived  `Done` `High`
  Archiving an article overwrote whatever read state it had, because `Article.Status` was a flat four-case enum (`unread | reading | read | archived`) — so an archived article was never `.read`, the context menu always offered "Mark as read" regardless of actual read state, and there was no way to unarchive at all. Completed 2026-08-31.

  ## Fix — model split (option (c), decided with Fabio 2026-08-30)

  * `Article.Status` reduced to `unread | reading | read`; added a separate `archived: Bool` (+ `archivedAt: Date?`) to Core Data (`Verso.xcdatamodeld`) and `Article.swift` — a lightweight migration (`NSPersistentContainer`'s default automatic-migration options, unchanged), since the model is a single unversioned `.xcdatamodel`.
  * Mirrored to frontmatter as `archived: true` / `archived_at:` lines beside `status:`, omitted entirely when `false` (same convention as `scroll_position`/`tags`). `MarkdownReader.read` parses the new lines and back-fills a legacy `status: archived` file to `status: read, archived: true` — lazily, only rewritten on the next write-back, not at read time (same pattern as FAB-290 adoption).
  * `MarkdownWriter.updateArchived(_:archivedAt:for:)` (new) replaces/removes the two frontmatter lines; `MarkdownWriter.unarchive(filePath:in:)` (new) mirrors `archive(filePath:in:)` — moves the `.md` out of `Archive/` back to the library root, carries the `{stem}.media` sidecar, resolves name collisions via the existing `uniqueFilename`.
  * `ArticleListView`: `archiveArticle`/`unarchiveArticle` now only touch `archived`/`archivedAt`, never `status` — archiving no longer destroys read state. The four list sections and the top-level fetch predicate filter on `archived` instead of a status value. Context menu and trailing swipe now offer Unarchive for archived rows, using the already-authored, already-localized `L10n.ContextMenu.unarchive` / `L10n.Swipe.unarchive` / `L10n.A11y.archiveAction` / `L10n.A11y.unarchiveAction` strings (previously dead code).
  * `ArticleCard.displayStatus`, `ArticleLibraryService.rebuildCache`, `PendingArticleIngester`, and `AddArticleView`'s duplicate-update paths all updated to carry `archived`/`archivedAt` alongside `status` wherever Core Data is written from a parsed file.

  ## Verified

  New/updated unit tests in `Verso/VersoTests/`: `MarkdownWriterTests` (`updateArchived` insert/remove/round-trip, `unarchive` with a `.media` sidecar and a name collision, `buildFrontmatter` archived round-trip through the reader and omission when not archived) and `MarkdownReaderTests` (legacy `status: archived` back-fill, `archived`/`archived_at` round-trip, missing-archived defaults to false) — 18 new tests. Full `VersoTests` suite (67 tests) passes. `xcodebuild build` succeeded for the `Verso` scheme; Share Extension unaffected (it only compiles `Shared/`, untouched by this change). Not verified here: real-device confirmation of the long-press menu and swipe actions across all four states — Fabio's part after the PR.

- [x] 🟠 **FAB-298** · "Related articles" are not related — the similarity scoring is effectively random  `Done` `High`
  `RelatedArticlesService` scored with unweighted Jaccard similarity over a raw word set, threshold 0.04 — any two English prose articles of a few thousand words clear 4% shared-vocabulary overlap on common words alone, so effectively every article "related" to every other one. Completed 2026-08-31.

  ## Fix — TF-IDF cosine similarity, replacing Jaccard

  * **New `Verso/Sources/Services/RelatedArticlesScoring.swift`**: a pure, Core Data-free scoring engine (`RelatedArticlesDocument` in, `[(key, score)]` out) — directly unit-testable with no managed object context. Builds a document-frequency table across the candidate set, smoothed IDF (`log((N+1)/(df+1)) + 1`), TF-IDF vectors, cosine similarity, then a tag-overlap boost (`final = cosine + 0.15 * (sharedTags / max(tagsA.count, tagsB.count))`, clamped to 1). Title terms count 3x toward a document's term frequency.
  * Tokenization: `NLLanguageRecognizer.dominantLanguage(for:)` picks the document's language (mirrors `TTSService`'s existing pattern), `NLTagger` with the `.lemma` scheme collapses "scan/scanning/scanner" to one term. **New `RelatedArticlesStopWords.swift`** ships hand-authored en/pt/fr stopword lists (~80-100 words each), replacing the old 60-word English-only list that left thousands of topic-neutral Portuguese/French words unfiltered.
  * **`RelatedArticlesService.swift` rewritten** as a thin `@MainActor` Core Data wrapper: fetches non-archived candidates (`NSPredicate(format: "archived == NO")` — no such predicate existed before), snapshots them into plain values using `Article.searchableBody` (no file I/O on the main actor), then hands off to `Task.detached(priority: .userInitiated)` — the same pattern `ArticleLibraryService.rebuildCache` already uses — for the file-read fallback (rare) and the actual scoring, off the main actor. Fixes the O(n) main-actor file read the old `loadContent(for:)` did on every article on every reading-view open.
  * **New `#if DEBUG` `RelatedArticlesDebugView.swift`**, reachable from a new DEBUG-only row in `SettingsView`: runs the same scorer over every pair in the real library and lists every score (not threshold-filtered) sorted descending, so the threshold can be calibrated against real data instead of guessed. Not present in a Release build.
  * `ArticleReaderView.swift`'s call site and its `if !relatedArticles.isEmpty` guard were already correct and needed no changes — the fix is entirely inside the service.

  ## Threshold recalibration (round 2, same day)

  Shipped first at `0.18` (middle of the ticket's suggested 0.15–0.25 TF-IDF cosine range, borrowed from general literature). Fabio tested and reported Related Articles never showed anything. Since this session has no access to his real library, the repo's 14 `SampleArticles` (the app's own seed content, and a reasonable proxy for the short-essay/long-read material Verso is actually used to read) were used as a stand-in: ran the scorer over all 91 pairs and printed the full matrix (the same computation `RelatedArticlesDebugView` does). Result: only 1 of 91 pairs cleared 0.18 — the generic literature guideline assumes longer/more technical documents than typical reading-app content, where shared vocabulary is thinner. The measured distribution tops out at 0.24 (the one genuinely on-topic pair, which also shares a tag), with a second tier of plausible thematic pairs in the 0.10–0.15 band and a long tail below 0.08 of clearly unrelated pairs. **Lowered `threshold` to `0.10`** — keeps that second tier so an article with a real thematic neighbor actually surfaces results, while still excluding the unrelated tail. Still a measurement from one small sample library, not Fabio's real one — the DEBUG screen remains the way to check and adjust further.

  Separately, Fabio also reported "a list of topics, no links" at the end of some real articles. Not reproducible in `SampleArticles` (checked all 14 — none have this pattern), so likely a content-import artifact unrelated to this ticket (scoring, not parsing) — flagged back to him for a concrete example rather than guessed at.

  ## Judgment calls (flagged to Fabio in the PR)

  * No persistent cross-call document-frequency cache tied to `ICloudFileWatcher` (the ticket's step 1 suggestion) — `RelatedArticlesService` is instantiated fresh once per reading-view open, not per scroll/keystroke, so a cache would need a new long-lived owner wired through the app for a computation that's already cheap off-main. Can be added later if a real large library shows otherwise.
  * The `0.10` threshold is grounded in a real measurement (see above) but still not Fabio's actual library — the DEBUG screen is the mitigation; he's expected to report back whether it needs further adjustment.

  ## Verified

  New `Verso/VersoTests/RelatedArticlesScoringTests.swift` (pure, no Core Data needed): two related articles rank together among eight unrelated ones and nothing else clears threshold; no topical neighbor returns empty; a shared tag measurably outranks shared-vocabulary-alone (asserts the exact 0.15 boost); a regression test with ten documents sharing only generic filler vocabulary (but each with distinct, non-overlapping topic content — not identical documents, which would trivially cosine=1 regardless of IDF) confirms the old "everything clears threshold" failure mode can't recur; a pt-BR document doesn't relate to unrelated English documents; a real-content regression test using the actual top-scoring `SampleArticles` pair (excerpted verbatim) that caught the recalibration need in the first place; ~500 synthetic documents score in ~2.1s off the main thread. 7 new tests; full `VersoTests` suite (74 tests) passes. `xcodegen generate` + `xcodebuild build` succeeded for the `Verso` scheme. **Not verified here**: the `0.10` threshold against Fabio's real library (see judgment calls above) and real-device confirmation that the reading view's Related Articles section now shows genuinely related articles — both Fabio's part after the PR, using the new DEBUG screen.

- [x] 🟠 **FAB-300** · Guardian articles keep a trailing topic-tag list as plain text in the body  `Done` `High`
  Guardian's "Explore more on these topics" / Share / "Reuse this content" block leaked into the saved article body as plain text with no links. Fabio provided the real HTML from the reported article, which settled what FAB-300's original filing left open. Completed 2026-08-31.

  ## Root cause — confirmed against real markup

  The block is wrapped in `<div data-print-layout="hide">` — a genuine semantic attribute ("hide in the print stylesheet"), unlike Guardian's `dcr-*` classes (hashed CSS-in-JS output, not safe to select on). Two import paths, and the bug lived differently in each:
  - **Share Extension** (`SwiftSoupParser.extractContentMarkdown`) already did real DOM-based noise removal via SwiftSoup, but its selector list didn't include `[data-print-layout="hide"]`.
  - **Add-by-URL** (`ReadabilityParser` → Mozilla Readability.js → `HTMLToMarkdownConverter.convert`) had **no DOM-based noise removal at all** — `convert()` was a lightweight regex/string HTML stripper ending in a blanket "strip every tag" regex, which is exactly why the topic links vanished (`<a href>` and all other tags stripped identically, keeping only inner text) once Readability.js failed to remove this block itself.

  ## Fix

  * **New shared `HTMLToMarkdownConverter.noiseSelector`**: the existing selector list (chrome tags, ARIA roles, known widget `data-testid`s) plus `[data-print-layout=hide]` — now a single source of truth instead of a private duplicate that had drifted out of sync between the two files.
  * `SwiftSoupParser.extractContentMarkdown` now references the shared constant instead of its own local copy.
  * `HTMLToMarkdownConverter.convert` gained a SwiftSoup-based DOM pre-pass (`removeStructuralNoise`): parses the HTML, removes `noiseSelector` matches, serializes the cleaned body back to HTML, then continues through the existing regex pipeline unchanged. Brings real structural noise filtering to the add-by-URL path for the first time — not just a fix for this one Guardian pattern, but the missing mechanism that let it (and potentially similar "hide on print" widgets on other sites) through. Falls back to the original HTML unchanged if parsing fails, so a malformed fragment degrades to pre-fix behavior rather than losing content.

  ## Verified

  New tests in `Verso/VersoTests/SwiftSoupParserTests.swift`: `testGuardianTopicsListDoesNotLeakIntoBody` (Share Extension path) and `testConvertStripsGuardianTopicsListViaDOMPrePass` (add-by-URL path) both use a fixture built from Fabio's real reported HTML, asserting the topic list / Share / "Reuse this content" text is gone and the real paragraph survives; `testConvertHandlesUnparseableFragmentGracefully` covers the parse-failure fallback. 3 new tests; full `VersoTests` suite (77 tests) passes. `xcodebuild build` succeeded for both the `Verso` and `ShareExtension` schemes (the latter rebuilt since `SwiftSoupParser.swift` was touched). **Not verified here**: a real re-save of the reported Guardian article on-device — Fabio's part after the PR.

- [x] 🟡 **FAB-299** · Reading view: replace the Tags and Open-in-browser buttons with an ellipsis menu  `Done` `Medium`
  Requested by Fabio 2026-08-30, scope confirmed in conversation the same day. Completed 2026-08-31.

  ## What changed

  Reading view top bar `← Back | Title | 🏷 Tags | ↗ Open in browser` → `← Back | Title | ⋯`. Tapping `⋯` opens a menu, in order: **Mark as unread/read** (label follows current state) → **Tags** → **Open in browser** → **Share** (new) → **Archive/Unarchive** → *divider* → **Delete** (destructive, confirmed). Archive, Delete, and Mark-as-unread all dismiss back to the list — confirmed decisions, per the ticket.

  ## Implementation

  * **`ReadingChrome.swift`**: `ReadingTopBar` became generic over a `@ViewBuilder menuContent`, wrapped in `Menu { menuContent() } label: { ⋯ icon }` — replaces the `onOpenExternal`/`onEditTags` closures, stays presentational (all Article-specific logic lives in `ArticleReaderView`, the only caller). Needed an explicit `init` with `menuContent` as the true trailing parameter — the synthesized memberwise init would have put `isVisible` last (declaration order), which silently breaks trailing-closure call sites.
  * **`ArticleReaderView.swift`**: new `readingMenuContent` view builder plus `closeReader()` (factors out the existing `onRequestClose`/`dismiss()` pattern the back button already used), `toggleReadStatusAndClose()` (sets `status` directly rather than via `advanceStatus`, which refuses to move backwards by design), `archiveAndClose()`/`unarchiveAndClose()` (reader-scoped mirrors of `ArticleListView.archiveArticle`/`unarchiveArticle` from FAB-297 — archiving never touches `status`), and `deleteArticleAndClose()` (deletes the `.md`/`.media` sidecar and the Core Data row in the same transaction — new plumbing, since no single-article delete existed anywhere before this; only bulk delete did). `ShareLink` is the first use of it (or `UIActivityViewController`) anywhere in the codebase.
  * No `advanceStatus`/`onDisappear` race: `evaluateReadCompletion` (which drives `advanceStatus(to: .read)`) only ever fires from live scroll-metric callbacks, which stop once the menu action isn't a scroll gesture — the `onDisappear` scroll-position write only ever touches `scroll_position`, never `status`.

  ## Copy

  Reused as-is: `L10n.ContextMenu.markAsRead`/`.markAsUnread`/`.addTags`/`.archive`/`.unarchive`/`.delete`. Also reused, but discovered to be pre-authored-and-never-wired (same pattern FAB-297 found with the unarchive strings) — `reading.openExternal.accessibilityLabel` ("Open original article"): the old icon button used a hardcoded, unlocalized "Open in browser" instead of this already-existing key. Similarly, `dialog.deleteArticle.title`/`.message`/`.confirm`/`.cancel` existed but had zero call sites anywhere; **repurposed** `dialog.deleteArticle.title` in place (free, since nothing used it) from a plain "Delete article?" to a parameterized `Delete "{title}"?`, matching how `dialog.bulkDelete.title` is already parameterized by count — satisfies the ticket's "confirmation must name the article" requirement without a near-duplicate key. Two genuinely new keys: `reading.topBar.moreActions` (+ `.hint`) and `reading.menu.share`, authored in `docs/copy/UI_COPY.md` and run through `docs/copy/codegen/generate.py` per the FAB-275 workflow (en/fr-CA/pt-BR, `needs_review` state for the hand-translated locales, same as every other string in this codebase).

  ## Verified

  `xcodebuild build` succeeded for the `Verso` scheme. Full `VersoTests` suite (77 tests) passes — unchanged, since this is a UI-orchestration change entirely reusing already-tested lower-level functions (`MarkdownWriter.archive`/`unarchive`/`delete`/`updateStatus`, all covered by FAB-297's tests). **Not verified here** — needs a real device/simulator and is entirely manual per the ticket's own acceptance criteria: VoiceOver reading the `⋯` button and every item's current-state label correctly, menu legibility across all 4 themes and at XXL Dynamic Type, and updated `docs/printscreens` screenshots — all Fabio's part after the PR.

- [x] 🟡 **FAB-301** · OpenDyslexic reading font never actually loads on-device  `Done` `Medium`
  Found by Fabio reading a real-device Xcode console log while testing FAB-299 (`FontParser could not open filePath .../Verso.app/Fonts/OpenDyslexic-Regular.ttf: [2: No such file or directory]`, `GSFont: file doesn't exist`). Diagnosed and fixed same session, 2026-08-31.

  ## Root cause

  `Verso/Resources/Info.plist`'s `UIAppFonts` declares `Fonts/OpenDyslexic-Regular.ttf`, but `project.yml` included the whole `Resources/` folder as a plain source group rather than a true folder reference — unlike `Resources/readability` and `../SampleArticles`, which were already explicitly `type: folder` a few lines above it. XcodeGen flattens a plain source group's files into the bundle root, so `OpenDyslexic-Regular.ttf` landed at `Verso.app/OpenDyslexic-Regular.ttf`, never at the `Fonts/` subpath iOS was told to look for — meaning the custom font could never actually register, and Settings' OpenDyslexic option silently fell back to something else instead of rendering in it.

  ## Fix

  Added `Resources/Fonts` as its own `type: folder` source in `project.yml`, mirroring the exact pattern `Resources/readability` already used. Verified directly against the built bundle (not just "it compiles"): `Verso.app/Fonts/OpenDyslexic-Regular.ttf` now exists at the path `Info.plist` declares, confirmed after a full `clean build` too, not just an incremental one.

  A harmless side effect, not a regression: the plain `Resources/` source entry still also copies a flattened, unused duplicate of the font to the bundle root, same as `Readability.js` already does (also duplicated at root, also just unused cruft — `ReadabilityParser.swift` only ever reads the nested copy via `Bundle.main.url(forResource:withExtension:subdirectory:)`). Restructuring `sources:` to eliminate that duplication for every resource wasn't necessary to fix the actual bug and would be a larger, separate change.

  ## Verified

  `xcodegen generate` + `xcodebuild build` succeeded, and `xcodebuild clean build` confirmed the fix survives a full rebuild, not just an incremental one. Full `VersoTests` suite (77 tests) passes — unaffected, this is a build-config-only change with no Swift code touched. **Not verified here**: that OpenDyslexic actually renders correctly on a real device with the font now loading — Fabio's part after the PR, though this is about as close to certain as a fix gets without that final check (the exact missing-file path from the bug report now exists, byte-for-byte, exactly where `Info.plist` said to look).

- [x] 🟡 **FAB-293** · Markdown tables are not rendered in the reading view  `Done` `Medium`
  A `.md` file with a GFM pipe table rendered as one run-on paragraph — `MarkdownNode`/`MarkdownParser` had no concept of a table at all. Completed 2026-08-31.

  ## Fix

  * **`MarkdownBodyView.swift`**: new `MarkdownNode.table(headers:rows:alignments:)` case + nested `TableAlignment` enum. `MarkdownParser.parse`'s line loop became index-based (`while i < lines.count`) so it can look ahead: right before the paragraph-accumulator fallback, a pipe-containing line followed by a delimiter row (`^\s*\|?\s*:?-{1,}:?\s*(\|\s*:?-{1,}:?\s*)*\|?\s*$`) consumes the header, delimiter, and every following pipe row into one `.table` node — a pipe line with no delimiter row falls through unchanged (still a paragraph), which is the false-positive guard. Cells split on unescaped `|` (a literal `\|` is protected first), trimmed, with a leading/trailing empty cell from outer pipes dropped; ragged rows are padded/truncated to the header's column count so a malformed table can't crash. Rendered via a SwiftUI `Grid` wrapped in a horizontal `ScrollView` (wide tables scroll instead of squeezing the reading column) — bold header row, a 1pt border rule under it (`GridRow` + `.gridCellColumns`), ~8pt cell padding, per-column alignment via `.gridColumnAlignment(_:)`. `MarkdownNode.plainText` joins all cells with a space so search indexing keeps working.
  * **`SwiftSoupParser.swift`** (`collectLines`): new `case "table"` builds real GFM pipe syntax from an HTML `<table>` (the first `<tr>` in document order is always the header, everything after is data — including HTML5's implicit `<tbody>`-wrapping of bare `<tr>`s with no `<thead>`/`<tbody>` at all, which made an earlier "prefer `<tbody>`'s own rows" approach silently include the header as a data row too; caught by a test, not by inspection). HTML has no GFM alignment syntax, so the synthesized delimiter row is always plain `---` — real alignment is a `.md`-only feature for hand-written tables. `<td>`/`<th>` are now only reached for a cell sitting outside a proper `<table>` ancestor (malformed markup).

  ## Verified

  New `Verso/VersoTests/MarkdownParserTests.swift` (11 tests): basic 3-column table, table amid ordinary paragraphs, alignment colons (all three + default), short-row padding, long-row truncation, escaped `\|` inside a cell, the false-positive guard (a pipe line with no delimiter row stays a paragraph, both standalone and directly after a real table), `plainText` joining. Plus two new `SwiftSoupParserTests`: a `<thead>`/`<tbody>` table round-trips through `MarkdownParser.parse` as a real `.table` node (not just loose lines — supersedes but doesn't replace the older loose-line regression test, which stays as a coarser guard against the text vanishing outright), and a bare-`<tr>` table with no `<thead>`/`<tbody>` correctly treats the first row as the header. 11 new tests; full `VersoTests` suite (89 tests) passes. `xcodebuild build` succeeded for both the `Verso` and `ShareExtension` schemes (the latter rebuilt since `SwiftSoupParser.swift` was touched). **Not verified here**: real-device confirmation that a wide table actually scrolls horizontally without the surrounding article text scrolling, and that XXL Dynamic Type doesn't clip cells — both Fabio's part after the PR.

- [x] 🟡 **FAB-296** · Duplicate articles appear in the list despite the duplicate check  `Done` `Medium`
  Fabio saw the same article twice in the list. Duplicate detection already existed (`ArticleDuplicateFinder`, wired into the Share Extension and in-app Add Article, with an Update/Save-copy prompt), so this was a set of holes in an existing feature, not a missing one. Read every file the report named and found **all four candidate causes were real, simultaneous gaps**, not competing hypotheses — fixed all four. Completed 2026-08-31.

  ## Fix

  * **`VersoArticleURL.canonicalKey`** (weak URL matching): now strips a known tracking-parameter set (`utm_*`, `source`, `sk`, `gi`, `ref`, `ref_src`, `fbclid`, `gclid`, `mc_cid`, `mc_eid`, `_branch_match_id`), sorts the remaining query items by name, drops an empty query entirely, strips a leading `www.` host label, and normalizes `http` → `https` — comparison only, the stored `url:` frontmatter is never rewritten. An unrecognized query parameter (e.g. `?page=2`) still counts as a different article.
  * **`ArticleDuplicateFinder.scanDirectory`** (scan scope too narrow): dropped `.skipsSubdirectoryDescendants` and made the scan recursive across the whole library tree, pruning `*.media` sidecar folders via `enumerator.skipDescendants()` (they only ever hold downloaded images, never `.md` files). This also made the separate explicit `Archive/` scan in `findDuplicate` redundant — removed it, since the recursive scan already covers `Archive/` as part of the tree.
  * **`LibraryBookmarkResolver.resolveLibraryFolderURL()`** (check skipped silently): now logs via `OSLog` on every `nil` return (missing/unresolvable bookmark) instead of failing silently, and — mirroring `FolderBookmarkService.restore()`'s existing pattern — refreshes and re-persists the bookmark when `isStale` is true, so a stale bookmark self-heals instead of degrading on every subsequent share. *Scoped out deliberately*: a new user-facing "library folder unreachable" screen in the Share Extension — the ingest backstop below already catches the practical consequence (a missed duplicate), so a new `ShareState` case plus new localized copy in three locales wasn't needed for a failure mode that no longer loses or duplicates data.
  * **`PendingArticleIngester`** (no backstop at ingest): when `pending.duplicateResolution == nil`, now runs `ArticleDuplicateFinder.findDuplicate` against the resolved library folder before writing — the main app has full folder access here even when the extension didn't. **UX call, asked and answered by Fabio**: on a match, keep both articles (no interrupting prompt at an arbitrary launch/foreground moment) but tag the new one `"Possible Duplicate"`, surfaced via the existing tag filter/side panel — no new UI component. Also fixed the new-`Article`-row branch of `upsertCoreData`, which never set `tagsSerialized` at all (previously dead code, since `tags` was always `nil` on this path) — needed so the flag is visible immediately rather than after the next full cache rebuild. Added the defensive uniqueness check the report called for: an existing `Article` row with the same `filePath` is updated in place instead of a duplicate row being inserted, guarding double-ingest of one pending JSON. New analytics value `duplicate_resolution: "backstop_flagged"` on the existing `article.saved` event.

  ## Verified

  New `Verso/VersoTests/VersoArticleURLTests.swift` (10 tests: UTM/tracking params, unrecognized params kept, query ordering, `www.`, `http`→`https`, trailing slash, root slash, fragment, combined noise) and `ArticleDuplicateFinderTests.swift` (6 tests: library root, `Archive/`, a nested subfolder, `.media` folders not descended into, tracking-parameter normalization end-to-end, no-match returns nil) — all pass. `xcodegen generate` + `xcodebuild build` succeeded for both the `Verso` and `ShareExtension` schemes (the latter rebuilt since `LibraryBookmarkResolver.swift` in `Shared/` was touched). Full `VersoTests` suite (105 tests) passes. **Not verified here**: an actual live Share Extension save against a real Medium URL with tracking params, confirming the prompt fires end-to-end — needs network access and a real device/simulator run, Fabio's part after the PR.

### Bugs — layout (reported by Fabio 2026-08-31)

- [x] 🟠 **FAB-302** · Empty navigation bar leaves a ~44pt gap above the "Verso" title  `Done` `High`
  FAB-292 (commit `4befaba`, "feat: redesign article list") moved the title and every control out of the navigation bar and into the in-content `headerRow`, but left `.navigationBarTitleDisplayMode(.inline)` and two `.toolbarBackground(…)` calls behind on `ArticleListFetchedBody` — those modifiers style a nav bar, they don't remove it, so `NavigationSplitView`'s sidebar column kept reserving an empty ~44pt inline bar above `headerRow`. Completed 2026-08-31.

  ## Fix

  In `Verso/Sources/Screens/ArticleList/ArticleListView.swift`: deleted the three now-purposeless modifiers from `ArticleListFetchedBody`, and added `.toolbar(.hidden, for: .navigationBar)` to the `GeometryReader` at the root of `ArticleListView.body` — column-level chrome belongs at the top of the view handed to the sidebar column, not buried inside a child view. No compensating padding added; `headerRow`'s existing `.padding(.top, VersoSpacing.md)` now sits directly below the safe area, per the FAB-292 layout intent. Mirrors `ArticleReaderView`'s existing `.navigationBarHidden(true)` for its own column (left as-is — converting it to the modern API is separate cleanup, out of scope here).

  ## Verified

  `xcodebuild build` succeeded for the `Verso` scheme. **Not verified here**: the actual visual result on a simulator/device (top spacing under the Dynamic Island, all three `headerRow` states, the folder-picker prompt state, iPad sidebar toggle behavior) — Fabio's part after the PR.

### Phase 1 — Foundation

- [x] ⚪ **FAB-163** · Shipped: Duplicate article detection (share extension + in-app)  `Done` `No priority`
  Implemented duplicate detection when saving an article whose canonical source URL already exists in the library (YAML `url:` in root + `Archive/` .md files).

  **Share extension:** After parse, resolves library folder via app-group bookmark; if duplicate, prompts **Update existing** / **Save as copy** / **Cancel** (cancel completes without pending JSON). Pending payload carries `DuplicateSaveResolution` for ingester.

  **Main app:** `MarkdownWriter.replaceArticle` preserves `added`, `status`, `scroll_position`, `tags`; `PendingArticleIngester` updates Core Data by file path on replace. Analytics `article.saved` includes `duplicate_resolution`: `none` | `update` | `copy`.

  **In-app Add Article:** Same duplicate UI and write paths for parity.

  **Docs:** `docs/copy/UI_COPY.md` (share.duplicate.\*), `docs/ANALYTICS_STRATEGY.md`.

  Verified 2026-08-24: both write paths (`AddArticleView.replaceArticleInLibrary` / `applyDuplicateCopy` and `PendingArticleIngester`) confirmed wired to `MarkdownWriter.replaceArticle`; share extension prompt (`ShareViewModel.duplicatePrompt`) confirmed present. Completed 2026-08-24.

- [x] 🟡 **FAB-164** · Fix GoodLinks JSON backup import (native export format)  `Done` `Medium`
  ## Root cause

  GoodLinks exports a **top-level JSON array** of bookmarks with `addedAt` as a numeric Unix timestamp (`url`, `title`, `tags`, etc.). Verso only matched a **dictionary** with `items` and ISO strings `created_at` / `read_at`, so real backups failed `canParse` → unsupported format or bad decode. Fixed 2026-06-12.

  **Real-file smoke test (2026-08-25), against Fabio's actual export (`GoodLinks-Export-2026-08-25-20-25.json`, 485 items):** structure matches the native-array path exactly (top-level array, `url` + numeric `addedAt` per row) and classifies/decodes correctly. 481/485 items would import; 4 have no `title` in the source data at all (all PDFs/anchor-fragment URLs GoodLinks never resolved a title for) and get silently dropped by `mapNativeBookmarks`'s title-required `compactMap` — expected/acceptable, no fix needed. Tags round-trip correctly (60/485 items have tags).

  **Bug found:** 86/485 items (~18%) have a non-null `readAt` in the export (i.e. were actually read in GoodLinks), but `mapNativeBookmarks` hardcoded every native-array import's status to `.unread` and never read any read-status field from the row, even though the sibling legacy `{ "items": [...] }` path correctly derived `.read` vs `.unread` from `readAt`. This meant all importable articles would land as unread instead of the true 86 read / 395 unread split.

  ## Fix (2026-08-26)

  `mapNativeBookmarks` now computes `status` the same way `dateFromAddedAt` already parses `addedAt`: `.read` when `row["readAt"]` decodes to a numeric timestamp (Double or Int), `.unread` otherwise. The real export's native rows carry `readAt` as a Unix timestamp, not the ISO string the legacy path expects — no `Date` parsing needed, presence is enough.

  ## Acceptance criteria

  - [x] Import succeeds for minimal native-array fixture (same shape as public GoodLinks-Export.json converters).
  - [x] Legacy `{ "items": [...] }` + ISO dates path still works if present.
  - [x] GoodLinks array is not misclassified as Matter JSON (detector order / heuristics).
  - [x] Native-array rows with a numeric `readAt` import as `.read`; rows without it import as `.unread`.

  ## Implementation

  Parser update in `Verso/Sources/Services/Import/GoodLinksParser.swift`. Regression tests in `Verso/VersoTests/GoodLinksParserTests.swift` (`testNativeTopLevelArrayParses` for the no-`readAt` → `.unread` case, added 2026-06-12; `testNativeTopLevelArrayWithReadAtParsesAsRead` for the numeric-`readAt` → `.read` case, added 2026-08-26). Full `VersoTests` suite (27 tests) passes.

  **Real-file recheck (2026-08-26):** ran the app's actual import pipeline (`ImportFormatDetector` → `GoodLinksParser` → `MarkdownWriter` → Core Data insert) against Fabio's real GoodLinks export (`GoodLinks-Export-2026-08-25-20-25.json`, 485 rows, kept local/untracked per privacy — not committed) via an isolated in-memory Core Data store. Result: 481 articles imported (4 rows have no `title` key at all — genuinely untitled GoodLinks bookmarks, correctly dropped), split **86 read / 395 unread**, matching the source data's 86 non-null `readAt` rows exactly. Titles, dates, and tags all came through correctly.

- [x] 🔴 **FAB-9** · [ARCH] Define Article Core Data model  `Done` `Urgent`
  Create the Core Data entity for Article with fields: id (UUID), filePath (String), title (String), url (String), status (String: unread/reading/read), dateAdded (Date), source (String). This is a cache only — never the source of truth.

- [x] 🔴 **FAB-10** · [ARCH] Implement Markdown file writer  `Done` `Urgent`
  Write a function that takes a parsed article and saves it as a .md file with YAML frontmatter to the user's iCloud Drive folder. Filename format: YYYY-MM-DD Article [Title.md](<http://Title.md>). Handle filename collisions by appending a counter.

- [x] 🔴 **FAB-11** · [ARCH] Implement Markdown file reader  `Done` `Urgent`
  Write a function that reads a .md file from iCloud Drive, parses the YAML frontmatter, and returns an Article model. Handle graceful degradation: missing fields use defaults, invalid frontmatter skips the file with a warning.

- [x] 🔵 **FAB-12** · [ARCH] Implement iCloud Drive file watcher  `Done` `Low`
  Use NSMetadataQuery to watch the iCloud Drive folder for file changes. On file add/change/delete, update the Core Data cache accordingly. This keeps the app reactive when Obsidian or another app modifies files.

- [x] 🔵 **FAB-13** · [ARCH] Implement Core Data cache rebuild  `Done` `Low`
  On first launch and when the iCloud folder changes, rebuild the Core Data cache by scanning all .md files in the folder. Core Data is never the source of truth — it is always derived from the files.

- [x] 🟠 **FAB-14** · [PARSING] Bundle Readability.js in app  `Done` `High`
  Add the latest Readability.js (from Mozilla) as a bundled resource. Write a WKWebView wrapper that loads a local HTML page, injects Readability.js, and runs it against a fetched article URL. Return the parsed title and content.

- [x] 🟠 **FAB-15** · [PARSING] Implement SwiftSoup fallback parser  `Done` `High`
  Integrate SwiftSoup via Swift Package Manager. Implement a basic HTML parser that extracts the main content block as a fallback when Readability.js fails or WKWebView is unavailable.

- [x] 🟡 **FAB-16** · [PARSING] Implement parsing error handling  `Done` `Medium`
  When parsing fails, show an in-app error state: "Could not parse this article" with a button to open the original URL in Safari. Log the failure reason for debugging.

- [x] 🟠 **FAB-17** · [SHARE EXT] Implement URL capture in Share Extension  `Done` `High`
  In the Share Extension, extract the URL from the incoming NSExtensionItem. Validate that it's a web URL. Pass the URL to the main app via App Group shared container.

- [x] 🟠 **FAB-18** · [SHARE EXT] Implement background parsing from Share Extension  `Done` `High`
  Trigger article parsing from the Share Extension after capturing the URL. Save the result to the shared App Group container so the main app can pick it up on next launch.

- [x] 🟠 **FAB-19** · [SHARE EXT] Implement Share Extension UI  `Done` `High`
  Design and implement the Share Extension's small UI: a brief loading state ("Saving...") and a success/failure confirmation. Should feel instant — close automatically after \~1.5s on success.

- [x] 🟠 **FAB-20** · [LIST] Implement article list view  `Done` `High`
  Build the main Reading List screen using SwiftUI List. Show article cards with: title, source domain, date saved, and a status indicator (Unread dot, Reading progress indicator, or Read checkmark). Sort by date added (newest first by default). Fetch from Core Data.

  **Article statuses:**

  * **Unread** — saved, never opened
  * **Reading** — opened at least once but not scrolled to end (set automatically when article is opened)
  * **Read** — scrolled to end (set automatically on scroll completion)

  **Filter chips** (top of list): All / Unread / Reading / Read. Default: All.

- [x] 🟠 **FAB-21** · [LIST] Implement article card component  `Done` `High`
  Build a reusable ArticleCard view. Shows: title (2 lines max, truncated), source domain, relative date (e.g. "2 days ago"). Tappable to open reading view.

- [x] 🟡 **FAB-22** · [LIST] Implement swipe-to-delete  `Done` `Medium`
  Add swipe-left gesture on article cards to reveal a Delete action. On confirm, delete the .md file from iCloud Drive and remove from Core Data cache.

- [x] 🟡 **FAB-23** · [LIST] Implement swipe to mark read/unread  `Done` `Medium`
  Add swipe-right gesture on article cards to toggle read/unread status. Update the YAML frontmatter in the .md file and reflect the change in the UI immediately.

- [x] 🟠 **FAB-24** · [LIST] Implement empty state  `Done` `High`
  When the reading list is empty, show a friendly empty state: brief message + illustration/icon. Hint at how to save the first article via the Share sheet.

- [x] 🟡 **FAB-25** · [LIST] Implement pull-to-refresh  `Done` `Medium`
  Add pull-to-refresh to the article list that re-scans the iCloud Drive folder and refreshes the Core Data cache.

- [x] 🟠 **FAB-26** · [LIST] Implement sort and filter controls  `Done` `High`
  Add filter chips to the article list. The filter bar sits below the search bar and allows the user to filter by reading status.

  **Filter options (in order):** All, Unread, Reading, Read

  * Single-selection — one chip is always active. Default: All.
  * Each chip shows the article count for that status inline (e.g. "Unread 12").
  * When count is zero the chip remains visible but dimmed to 50% opacity.

  **Sort options:** Newest first (default), Oldest first. Persist preference in UserDefaults.

  **Design reference:** `docs/component-inventory.md` §1.3 (FilterChipBar), §5.6 (FilterChip)

- [x] 🟠 **FAB-27** · [READING] Implement reading view container  `Done` `High`
  Build the Reading View screen. It receives an Article and renders it full-screen. Handles navigation in/out and passes context for immersive mode.

- [x] 🟠 **FAB-28** · [READING] Implement article header  `Done` `High`
  At the top of the Reading View, show: article title (large), source domain, and date saved. Should be part of the scrollable content, not a fixed nav bar.

- [x] 🟠 **FAB-29** · [READING] Implement Markdown body renderer  `Done` `High`
  Render the article's Markdown body as styled SwiftUI text.

  **Markdown elements to support:**

  * Paragraphs
  * Headings H1–H4 (using typography scale from DS §3.4)
  * Bold / Italic
  * Links (Accent color, underlined)
  * Lists (ordered and unordered)
  * Blockquotes (border-left in Accent color)
  * Code blocks (Surface background, SF Mono)
  * Images (async load, aspect fit, full width)
  * Horizontal rules

  **Design reference:** `docs/component-inventory.md` §2.3 (MarkdownBody), `docs/DESIGN_SYSTEM_FOUNDATIONS.md` §3.4 (heading typography)

- [x] 🟠 **FAB-30** · [READING] Implement immersive reading mode  `Done` `High`
  Tap anywhere on the article body to toggle the reading chrome (top bar, bottom controls). Chrome fades in/out smoothly. Status bar also hides in immersive mode.

- [x] 🟠 **FAB-31** · [READING] Implement bottom reading controls  `Done` `High`
  Implement the bottom reading controls bar. This bar is part of the ReadingChrome and hides/reveals with the top bar in immersive mode.

  **Controls (left to right):**

  * Font size − / + (stepper, two IconButtons)
  * Line spacing (IconButton → popover with 4 presets: Compact, Normal, Relaxed, Airy)
  * Margins (IconButton → popover with 4 presets: Compact, Normal, Wide, Extra Wide)
  * Theme (IconButton → inline chip row: Paper, Sepia, Night, Ink)
  * Mark as read (IconButton toggle: Unread → Reading → Read)

  **Not in this bar:**

  * Font family selection is in Settings ([FAB-47](https://linear.app/fabiosasseron/issue/FAB-47/settings-implement-settings-screen)), not the reading controls
  * TTS playback is a separate issue ([FAB-39](https://linear.app/fabiosasseron/issue/FAB-39/tts-implement-text-to-speech-playback))

  **Design reference:** `docs/component-inventory.md` §2.1 (ReadingChrome), §2.5 (ReadingControls), §5.5 (IconButton)

- [x] 🟠 **FAB-32** · [READING] Implement font size control  `Done` `High`
  6 font size steps (XS to XXL). Changing size updates the reading view in real-time. Persist preference in UserDefaults.

- [x] 🟠 **FAB-33** · [READING] Implement font selection  `Done` `High`
  4 fonts: New York (default), Georgia, San Francisco, OpenDyslexic. Changing font updates the reading view in real-time. Persist preference in UserDefaults. Bundle OpenDyslexic as a custom font resource.

- [x] 🟠 **FAB-34** · [THEMES] Implement theme switching  `Done` `High`
  Theme picker in reading controls and in Settings. Switching theme updates the reading view and list view in real-time. Persist selection in UserDefaults.

- [x] 🟠 **FAB-35** · [THEMES] Implement Paper theme (default)  `Done` `High`
  Implement the Paper theme — the default theme applied on first launch.

  **Token values (from DESIGN_SYSTEM_FOUNDATIONS.md §2.1):**

  | Token | Value |
  | -- | -- |
  | Background | `#F5F0E8` |
  | Text Primary | `#2C2924` |
  | Text Secondary | `#6E675F` |
  | Surface | `#EDE8DF` |
  | Accent | `#766655` |
  | Divider | `#DDD8CE` |
  | Error | `#C0392B` |
  | Warning | `#B45309` |
  | Success | `#166534` |

  All token pairs meet WCAG AA contrast. See `docs/DESIGN_SYSTEM_FOUNDATIONS.md` for full rationale and contrast verification notes.

- [x] 🟡 **FAB-36** · [THEMES] Implement Sepia theme  `Done` `Medium`
  Implement the Sepia theme — classic warm sepia, closer to vintage books and warm lamp light.

  **Token values (from DESIGN_SYSTEM_FOUNDATIONS.md §2.2):**

  | Token | Value |
  | -- | -- |
  | Background | `#F2E8D5` |
  | Text Primary | `#2E2013` |
  | Text Secondary | `#755E40` |
  | Surface | `#E8DEC7` |
  | Accent | `#825A37` |
  | Divider | `#D9CAAC` |
  | Error | `#C0392B` |
  | Warning | `#B45309` |
  | Success | `#166534` |

  All token pairs meet WCAG AA contrast. See `docs/DESIGN_SYSTEM_FOUNDATIONS.md` for full rationale and contrast verification notes.

- [x] 🟡 **FAB-37** · [THEMES] Implement Night theme  `Done` `Medium`
  Implement the Night theme — warm dark. A dark room lit by a lamp. Less harsh than cold dark themes.

  **Token values (from DESIGN_SYSTEM_FOUNDATIONS.md §2.3):**

  | Token | Value |
  | -- | -- |
  | Background | `#1C1A16` |
  | Text Primary | `#E8E0D0` |
  | Text Secondary | `#8F897F` |
  | Surface | `#252320` |
  | Accent | `#C4A97D` |
  | Divider | `#2E2B26` |
  | Error | `#F87171` |
  | Warning | `#FCD34D` |
  | Success | `#4ADE80` |

  All token pairs meet WCAG AA contrast. See `docs/DESIGN_SYSTEM_FOUNDATIONS.md` for full rationale and contrast verification notes.

- [x] 🟡 **FAB-38** · [THEMES] Implement Ink theme  `Done` `Medium`
  Implement the Ink theme — cool dark. Neutral and modern. For users who prefer a contemporary dark mode over a warm one.

  **Token values (from DESIGN_SYSTEM_FOUNDATIONS.md §2.4):**

  | Token | Value |
  | -- | -- |
  | Background | `#111418` |
  | Text Primary | `#E4E6EB` |
  | Text Secondary | `#7E8492` |
  | Surface | `#181C22` |
  | Accent | `#7B9FD4` |
  | Divider | `#1E2228` |
  | Error | `#FC8181` |
  | Warning | `#F6E05E` |
  | Success | `#68D391` |

  All token pairs meet WCAG AA contrast. See `docs/DESIGN_SYSTEM_FOUNDATIONS.md` for full rationale and contrast verification notes.

- [x] 🟡 **FAB-42** · [ONBOARDING] Implement Welcome screen  `Done` `Medium`
  First onboarding screen. Headline: "Your articles. Your files." Brief subtext explaining the core value proposition. CTA: "Get Started".

- [x] 🟡 **FAB-43** · [ONBOARDING] Implement Theme Picker screen  `Done` `Medium`
  Second onboarding screen. Let the user pick their preferred reading theme before they start. Show live previews of Paper, Sepia, Night, Ink.

- [x] 🟡 **FAB-44** · [ONBOARDING] Implement Vault/Folder Setup screen  `Done` `Medium`
  Third onboarding screen. Two paths: (1) standalone — pick any iCloud Drive folder; (2) Obsidian users — point to their vault. Uses UIDocumentPickerViewController. This step is required to proceed.

- [x] 🟡 **FAB-45** · [ONBOARDING] Implement Quick Tour screen  `Done` `Medium`
  Fourth onboarding screen. One screen showing the share-to-save flow with a simple illustration. CTA: "Start Reading".

- [x] 🟡 **FAB-46** · [ONBOARDING] Persist onboarding completion  `Done` `Medium`
  After the user completes onboarding, save a flag in UserDefaults so they never see it again. On fresh install, always show onboarding from the first screen.

- [x] 🟡 **FAB-47** · [SETTINGS] Implement Settings screen  `Done` `Medium`
  Build the Settings screen as a SwiftUI Form/List. Sections: Reading (font, size, theme), Storage (current folder, change folder), About (version, privacy policy, open-source link).

- [x] 🟡 **FAB-48** · [SETTINGS] Implement folder management  `Done` `Medium`
  Allow the user to view and change their iCloud Drive folder from Settings. If they change the folder, re-scan and rebuild the Core Data cache from the new location.

  **Folder change dialog:** If the user selects a different folder and articles already exist in the current one, show a confirmation dialog before proceeding:

  > *"Move your existing articles to the new folder?"*\*  
  > \**"Your old folder won't be touched if you choose No."*  
  > \[Move Articles\] \[Keep in Old Folder\]

  * If the user taps **Move Articles**: copy all `.md` files from the old folder to the new one, then delete them from the old folder. Update the stored folder path and rebuild Core Data.
  * If the user taps **Keep in Old Folder**: update the stored folder path and rebuild Core Data from the new (empty) folder. Old articles remain in the old folder but disappear from the app.
  * If the new folder is empty (first time setup), no dialog needed — just switch.

- [x] 🔵 **FAB-49** · [SETTINGS] Implement About section  `Done` `Low`
  Show the app version, a link to the GitHub repo, and a link to the privacy policy (in-app web view or external link).

- [x] 🟠 **FAB-99** · Persist iCloud Drive folder access via security-scoped bookmarks  `Done` `High`
  ## Problem

  The selected iCloud Drive folder URL is stored only in a SwiftUI `@State` var (`ContentView.swift`), so access is lost on every app restart. iOS requires **security-scoped bookmarks** to re-establish access to user-picked directories across launches.

  ## Work Required

  1. **After folder pick** (`DocumentPicker.swift`): call `url.startAccessingSecurityScopedResource()`, then persist a bookmark:

     ```swift
     let bookmark = try url.bookmarkData(
         options: .minimalBookmark,
         includingResourceValuesForKeys: nil,
         relativeTo: nil
     )
     UserDefaults.standard.set(bookmark, forKey: "folderBookmark")
     ```
  2. **On app launch**: restore the URL from the stored bookmark and call `startAccessingSecurityScopedResource()`:

     ```swift
     var isStale = false
     let url = try URL(
         resolvingBookmarkData: data,
         options: .withoutUI,
         relativeTo: nil,
         bookmarkDataIsStale: &isStale
     )
     url.startAccessingSecurityScopedResource()
     ```
  3. **On app background / termination**: call `stopAccessingSecurityScopedResource()` on the active URL.

  ## Notes

  * Deferred from [FAB-6](https://linear.app/fabiosasseron/issue/FAB-6/setup-configure-icloud-drive-entitlement) review.
  * The iCloud Drive entitlement (`com.apple.security.files.user-selected.read-write`) added in [FAB-6](https://linear.app/fabiosasseron/issue/FAB-6/setup-configure-icloud-drive-entitlement) is a prerequisite and is already in place.

- [x] 🔴 **FAB-112** · [ARCH] Ingest pending articles from Share Extension into Core Data  `Done` `Urgent`
  ## Context

  The Share Extension parses articles and writes them as JSON files to the app group container's `pending/` directory (`PendingArticle` Codable structs in `ShareViewModel.swift`). The main app currently has no code to read from this directory — so articles saved via Share never appear in the reading list.

  ## What needs to happen

  On every app foreground event (`scenePhase == .active`), the main app should:

  1. Scan the app group `pending/` directory for `.json` files
  2. For each file, decode it as `PendingArticle`
  3. Write the article to the user's selected iCloud Drive folder as a `.md` file (via `MarkdownWriter`)
  4. Insert a new `Article` record into Core Data
  5. Delete the `.json` file from `pending/`
  6. Handle errors gracefully — if writing fails, leave the `.json` in place and retry next foreground

  ## Key files

  * `ShareExtension/Sources/ShareViewModel.swift` — writes `PendingArticle` JSON to app group container
  * `Verso/Sources/Services/MarkdownWriter.swift` — writes `.md` files to iCloud Drive
  * `Verso/Model/CoreDataStack.swift` — Core Data context
  * `Verso/Sources/App/VersoApp.swift` — good place to trigger ingestion on `scenePhase` change

  ## Acceptance criteria

  - [ ] Save an article via the Share Extension
  - [ ] Open the main app — the article appears in the reading list within 1–2 seconds
  - [ ] `pending/` directory is empty after successful ingestion
  - [ ] If no iCloud folder is selected yet, pending articles are held and ingested after folder setup

  ## Dependencies

  Requires [FAB-99](https://linear.app/fabiosasseron/issue/FAB-99/persist-icloud-drive-folder-access-via-security-scoped-bookmarks) (security-scoped bookmarks) and [FAB-44](https://linear.app/fabiosasseron/issue/FAB-44/onboarding-implement-vaultfolder-setup-screen) (folder picker wired) to be fully end-to-end, but the ingestion logic itself can be written and tested independently.

- [x] 🟠 **FAB-113** · [READING] Implement article status auto-tracking (Unread → Reading → Read)  `Done` `High`
  ## Context

  The `Article` Core Data model has a `status` field with `unread / reading / read` states, and `ArticleStatus` is defined in `Colors.swift`. However, nothing in the app currently updates this status — opening or reading an article leaves it permanently `unread`.

  ## Rules

  | Trigger | New status |
  | -- | -- |
  | Article opened (reading view appears) | `reading` (if currently `unread`) |
  | User scrolls to ≥ 95% of article body | `read` |
  | User taps "Mark as read" in bottom controls | `read` (manual override) |
  | User taps status badge in reading chrome | cycles: `read → unread → reading` |

  ## Implementation

  * On `ArticleReaderView.onAppear`: if `article.status == .unread`, update to `.reading`, save Core Data, write updated frontmatter to `.md` file
  * In the scroll progress tracker (already in `ArticleReaderView` via `GeometryReader`): when `scrollProgress >= 0.95`, update to `.read`, save Core Data, write frontmatter
  * Debounce the 95% write — only fire once per article open, not on every scroll tick
  * Persist status to YAML frontmatter (`status:` field) via `MarkdownWriter`

  ## Key files

  * `Verso/Sources/Screens/ArticleReader/ArticleReaderView.swift` — scroll tracking already present, status updates go here
  * `Verso/Sources/Services/MarkdownWriter.swift` — needs to support updating an existing file's frontmatter without rewriting the body
  * `Verso/Model/Article.swift` — `status` property

  ## Acceptance criteria

  - [ ] Opening an unread article changes its status to Reading in the list
  - [ ] Scrolling to the end changes status to Read
  - [ ] Status persists after closing and reopening the app (written to `.md` frontmatter)
  - [ ] Filter chips on the Home screen correctly reflect updated counts

- [x] 🟠 **FAB-114** · [LIST] Implement manual URL entry — Add button action  `Done` `High`
  ## Context

  The `+` button in the navigation bar of ArticleListView exists but has no action — the handler is empty (`// FAB-21: add article action`). Tapping it does nothing.

  This is the primary fallback for saving articles when the Share Extension isn't available (e.g. copying a URL from somewhere other than Safari).

  ## Behaviour

  Tapping `+` opens a sheet with:

  * A URL text field ("Paste a link…")
  * A "Save" button (disabled until the field contains a valid URL)
  * A "Cancel" button
  * Loading state while parsing
  * Success/error feedback matching the Share Extension's ShareView states

  ## Implementation notes

  * Reuse `ArticleParserService` for parsing (same as Share Extension)
  * On success, write to `pending/` via `MarkdownWriter` (same ingestion path as Share Extension, so [FAB-112](https://linear.app/fabiosasseron/issue/FAB-112/arch-ingest-pending-articles-from-share-extension-into-core-data) handles the rest)
  * The sheet UI can mirror `ShareView.swift` from the Share Extension

  ## Key files

  * `Verso/Sources/Screens/ArticleList/ArticleListView.swift` — wire the `+` button action here
  * `Verso/Sources/Services/ArticleParserService.swift` — reuse for parsing
  * `ShareExtension/Sources/ShareView.swift` — reference for the sheet UI pattern

  ## Acceptance criteria

  - [ ] Tapping `+` opens the URL entry sheet
  - [ ] Invalid/empty URL keeps Save button disabled
  - [ ] Valid URL triggers parsing with a loading indicator
  - [ ] On success, sheet dismisses and article appears in the list (once [FAB-112](https://linear.app/fabiosasseron/issue/FAB-112/arch-ingest-pending-articles-from-share-extension-into-core-data) ingestion is wired)
  - [ ] On failure, shows error with option to open URL in Safari instead

- [x] 🟠 **FAB-116** · [SETUP] Add app icon to Xcode project  `Done` `High`
  ## Context

  Once the app icon is approved in Figma ([FAB-115](https://linear.app/fabiosasseron/issue/FAB-115/design-design-app-icon-in-figma)), it needs to be exported and added to the Xcode asset catalog so it appears on the home screen, in Settings, and in the App Store.

  ## Steps

  1. Export the final icon from Figma at **1024×1024px** as PNG (no alpha/transparency — Apple rejects icons with transparency)
  2. In Xcode, open `Verso/Assets.xcassets`
  3. Select the `AppIcon` image set
  4. In the Attributes Inspector, set "Single Size" (Xcode 14+ generates all sizes automatically from one 1024pt asset)
  5. Drag the 1024×1024px PNG into the `1024pt` slot
  6. Build and run on simulator — confirm the icon appears on the home screen
  7. Also verify the icon appears correctly in:
     - [ ] Home screen (light wallpaper)
     - [ ] Home screen (dark wallpaper)
     - [ ] Settings app
     - [ ] App switcher

  ## Notes

  * Do NOT use an icon with transparency — Apple will reject the build
  * The Share Extension inherits the main app icon automatically, no extra work needed
  * If the asset catalog doesn't have an AppIcon set yet, create one: Assets.xcassets → + → App Icons & Launch Images → App Icon

  ## Dependencies

  Requires [FAB-115](https://linear.app/fabiosasseron/issue/FAB-115/design-design-app-icon-in-figma) (design approved in Figma) to be done first.

- [x] 🟡 **FAB-117** · [READING] Make links tappable in Markdown body  `Done` `Medium`
  ## Context

  Links in `MarkdownBodyView.swift` are rendered visually (accent colour, underlined) but are not tappable. There's an explicit comment in the code at line 383: *"tap handling via AttributedString is a future enhancement"*.

  ## Requirement

  Tapping a link in the article body should open the URL in Safari (via `UIApplication.shared.open` or `openURL` environment value). This matches the existing "Open in Safari" button in the reading chrome top bar.

  ## Implementation notes

  * The `MarkdownBodyView` uses custom SwiftUI views per block element
  * Links are currently rendered as styled `Text` — they need to become `Button` or use `Link` view
  * Use SwiftUI's `Link` view for inline links where possible, or wrap in a `Button` that calls `openURL`
  * Be careful with inline links inside paragraphs — may require splitting the text run around the link

  ## Acceptance criteria

  - [ ] Tapping a link in an article opens it in Safari
  - [ ] Link visual style (accent colour, underline) is unchanged
  - [ ] Non-link text in the same paragraph remains non-tappable

- [x] 🔵 **FAB-118** · [SETTINGS] Implement Version / About in-app screen  `Done` `Low`
  Create a dedicated in-app screen for the About / Version entry in Settings.

  The screen should show:

  * App name and version number (from bundle)
  * A short tagline or description of Verso
  * Links to GitHub repo and Privacy Policy (navigating to their respective in-app screens)

  Navigate to it via a `NavigationLink` from the About section of `SettingsView`. Do not open an external browser.

- [x] 🔵 **FAB-119** · [SETTINGS] Implement Privacy Policy in-app screen  `Done` `Low`
  Create a dedicated in-app screen that displays the Privacy Policy text inside the app.

  The screen should:

  * Render the privacy policy as styled text (Markdown or plain) using the current reading theme
  * Be navigated to via `NavigationLink` from the About section of `SettingsView`
  * Not open an external browser

  Host the privacy policy text as a local asset (e.g. `privacy_policy.md` in `Resources/`) so the app works offline.

- [x] 🟠 **FAB-128** · [SETUP] Implement launch / loading screen  `Done` `High`
  ## Context

  When the app opens, it needs to restore the security-scoped folder bookmark, scan the iCloud Drive folder, and rebuild the Core Data cache before the article list is ready. Currently there's no loading state — the list just appears empty or incomplete while this work happens in the background.

  A brief loading screen gives the app a polished, intentional first impression and prevents the user from seeing a flash of empty content.

  ## Behaviour

  * Show on every cold launch, for as long as it takes to complete initial setup (bookmark restore + cache rebuild)
  * Display the Verso wordmark or icon centred on the theme background colour
  * Optionally: a subtle activity indicator below the mark
  * Once the cache rebuild completes, transition to the article list with a short fade (0.25s)
  * Should respect the user's saved theme (Paper by default on first launch)

  ## Implementation notes

  * Add a `@State var isLoading: Bool` in `ContentView` (or `VersoApp`)
  * Show `LaunchView` when `isLoading == true`, otherwise show `ArticleListView`
  * Set `isLoading = false` in the completion handler of `ArticleLibraryService.rebuildCache`
  * Keep it simple — this is not the same as the iOS Launch Screen (LaunchScreen.storyboard), which is a static image shown before the app process starts

  ## Acceptance criteria

  - [ ] Opening the app shows a loading screen instead of an empty list flash
  - [ ] Loading screen uses the correct theme background and accent colours
  - [ ] Transitions smoothly to the article list once data is ready
  - [ ] On subsequent opens (warm launch), loading is fast enough to be barely noticeable

- [x] 🟠 **FAB-130** · [DEV] Export new app icon from Figma and add to Xcode  `Done` `High`
  The new app icon has been designed in Figma. This task covers exporting it and wiring it into the Xcode project so it replaces the current placeholder.

  ## Figma source

  [App icon frame — Reader-UI, node 100-1747](<https://www.figma.com/design/WCPHZNg1my8VSSMbLO5bvX/Reader-UI?node-id=100-1747>)

  ## Steps

  1. In Figma, select the icon frame (node 100-1747) and export at the required sizes (see below), or export a single 1024×1024 PDF/PNG and let Xcode generate the rest
  2. Replace the contents of `Verso/Assets.xcassets/AppIcon.appiconset/`
  3. Update `Contents.json` inside the appiconset if adding individual sizes manually
  4. Build and run — verify the icon appears on the Home Screen and in the Settings app
  5. Check it looks correct on both light and dark wallpapers

  ## Required export sizes (if not using a single 1024 PNG)

  | Size | Usage |
  | -- | -- |
  | 1024×1024 | App Store |
  | 180×180 (@3x) | iPhone Home Screen |
  | 120×120 (@2x) | iPhone Home Screen |
  | 87×87 (@3x) | iPhone Spotlight / Settings |
  | 58×58 (@2x) | iPhone Spotlight / Settings |

  > Tip: Xcode can generate all sizes automatically from a single 1024×1024 PNG — set the appiconset to "Single Size" in the asset catalog.

  ## Acceptance criteria

  - [ ] New icon visible on Home Screen after build
  - [ ] No "missing icon" warnings in Xcode
  - [ ] Icon looks sharp on Retina and Super Retina XDR displays
  - [ ] Replaces the placeholder — no remnants of the old icon

- [x] 🟠 **FAB-132** · Implement onboarding step 3: folder picker screen  `Done` `High`
  ## Overview

  The third onboarding screen — where the user picks their iCloud Drive folder — was never implemented. This issue covers creating `OnboardingFolderPickerView` and wiring it into `OnboardingFlowView`.

  ## Figma

  [Screen design (node 46-964)](<https://www.figma.com/design/WCPHZNg1my8VSSMbLO5bvX/Reader-UI?node-id=46-964>)

  ## Design spec

  * **Icon:** 64×64 circle badge (surface fill + border) with cloud emoji "☁" centered
  * **Headline:** "Where should Verso save your articles?" — New York Semibold 26pt, centered
  * **Subtitle:** "Pick a folder in iCloud Drive. Articles are saved as Markdown files — yours to keep." — Regular 15pt, secondary color
  * **Folder picker row:** Rounded rect (radius 12), surface fill + border, "Choose folder…" label + "›" chevron — taps open DocumentPicker
  * **Continue button:** Disabled at 50% opacity until a folder is chosen, then becomes active
  * **Privacy footnote:** "Verso never uploads your files. They live in your iCloud Drive." — 13pt, secondary color

  ## Implementation notes

  * Create `Verso/Sources/Screens/Onboarding/OnboardingFolderPickerView.swift`
  * Insert at `.tag(2)` in `OnboardingFlowView`, shifting Analytics Consent to `.tag(3)` and Quick Tour to `.tag(4)`
  * Update `pageCount` from 4 to 5
  * Reuse existing `DocumentPicker` + `FolderBookmarkService.save(url:)`
  * Fix existing analytics label on Theme Picker step ("folder_picker" should be "theme_picker")
  * Track `onboarding.stepCompleted` with `step: folder_picker` on Continue


### Phase 2 — Experience

- [x] 🔵 **FAB-54** · [PHASE 3] Implement highlighting  `Done` `Low`
  Select text in the reading view and highlight it, stored as `==text==` inline markers in the article's `.md` body (the Obsidian/CommonMark-extension convention — plain, portable, no proprietary format). The backlog entry was thin and left the storage format as an open question; before implementing, found the real blocker wasn't the storage format but that the reading view had **no text selection at all** — every paragraph rendered as one non-selectable SwiftUI `Text`. Put both the scope call and the storage-format question to Fabio directly rather than guessing; he chose to build a real (scoped-down) version this session, inline markers over frontmatter offsets. Completed 2026-09-01.

  ## What shipped

  * **New `highlight` design token** (`docs/DESIGN_TOKENS.md` §4, `Colors.swift`'s `VersoHighlightColor.wash`): `#F5C842` @ 30% opacity, deliberately **not** one of `ThemeColors`' 9 per-theme roles and not theme-tinted like `accentSurface` — a highlight should read as "highlighter ink," not shift with the palette the way `accent` does. WCAG contrast computed (not eyeballed) for `textPrimary` over the wash on each theme's `background`: Paper 11.49:1, Sepia 11.88:1, Night 6.20:1, Ink 7.03:1 — all clear of the 4.5:1 minimum.
  * **`MarkdownBodyView.swift`**: new `InlineNode.highlight(String)` parses `==text==` (added to the existing `inlinePatterns` table, same mechanism as bold/italic/code). `MarkdownNode.paragraph` gained a `rawText` field — the paragraph's original source lines joined by `\n` (as opposed to the space-joined, trimmed text used for rendering) — so a highlight action can locate an exact, unambiguous span of the real file content rather than a synthesized rendering string.
  * **New `HighlightableParagraphText.swift`**: a `UIViewRepresentable` wrapping a `UITextView` subclass (`isSelectable = true, isEditable = false`), used only for `.paragraph` nodes — every other block type keeps rendering as plain `Text`, unchanged. Bridges to UIKit because SwiftUI `Text` has neither a selection-change hook to build a custom menu action, nor per-run background-color support on `AttributedString` (both needed to show/manage a highlight). `buildMenu(with:)` inserts "Highlight" into the system edit menu when there's a selection, or "Remove Highlight" when the selection lands inside an existing highlighted run (detected via a custom `.versoHighlightIndex` attribute tagged onto each highlighted run at build time, in source order).
  * **New `ArticleHighlighter.swift`**: the pure, UIKit-free raw-text matching/wrapping logic. `addHighlight` builds a whitespace-tolerant regex from the selected text (so a soft line-wrap inside the raw source still matches) and searches it literally in the paragraph's `rawText`; a selection that crossed a bold/italic/code/link boundary won't literally match and is declined gracefully (verified by actually re-parsing the wrapped result and confirming it produced a real `.highlight` node with the expected content — checking the real parser's output, rather than hand-enumerating boundary rules). `removeHighlight(at:in:)` unwraps by source-order index, sidestepping re-matching entirely for removal.
  * **`MarkdownWriter.updateBody(_:for:)`**: new — replaces everything after the frontmatter's closing `---` while leaving the frontmatter block untouched. Every other updater in this file rewrites exactly one YAML line; this is the first one that replaces the body.
  * **`ArticleReaderView.swift`**: wires the highlight callback — splices a paragraph's updated `rawText` back into the full in-memory article body (first-occurrence literal match, exact since `rawText` is reconstructed from precisely the source lines the parser consumed) and persists via `MarkdownWriter.updateBody`.
  * **Copy**: two new keys, `reading.highlight.add`/`reading.highlight.remove`, added to `docs/copy/UI_COPY.md` and run through the codegen pipeline — `needs_review` state for fr-CA/pt-BR, same convention as every other hand-translated string here.

  ## Explicit scope limits (by design, not oversight)

  * Selecting **within one paragraph at a time** only — not across paragraph boundaries.
  * Selecting text that overlaps bold/italic/code/link formatting declines gracefully (a single error haptic, no blocking alert) rather than corrupting the file — a real fix needs the parser to track per-character source ranges, a follow-up if it turns out to matter in practice.
  * No highlighting on headings, list items, blockquotes, or table cells — paragraphs only.
  * One highlight color; no cross-article "Highlights" list/summary view.
  * A paragraph whose exact text repeats elsewhere in the article could have a highlight land on the wrong occurrence (first-occurrence matching) — narrow, accepted edge case.

  ## Verified

  New `Verso/VersoTests/ArticleHighlighterTests.swift` (12 tests: literal match, whitespace-tolerant match across a line wrap, decline on a bold-boundary crossing, decline when not found, first-occurrence targeting, leading/trailing whitespace trimmed, empty-selection decline, remove by index at various positions, out-of-range decline, no-highlights decline, add-then-remove round-trip) and 3 new `MarkdownParserTests` cases (single highlight marker, multiple markers in order, `rawText` preserves original source lines). Found and fixed one real bug this way: the round-trip verification in `ArticleHighlighter` was checking the un-collapsed raw candidate (which can contain a literal `\n` for a hand-wrapped paragraph) against a regex whose `.` doesn't cross newlines by default — rejecting a highlight that would actually render fine once reopened, since `MarkdownParser.flushParagraph` always collapses a paragraph's lines to single spaces before real rendering ever sees it. Fixed by normalizing newlines before the verification check, matching what real rendering will actually see. Full `VersoTests` suite (120 tests) passes. `xcodegen generate` + `xcodebuild build` succeeded for both the `Verso` and `ShareExtension` schemes. **Not verified here** — this is the one where "compiles" and "actually works" are furthest apart all year: a `UITextView` bridged into SwiftUI needs on-device confirmation that selection visually matches the theme (handle color, font, line spacing identical to the old `Text` rendering), the edit menu shows "Highlight" cleanly, Dynamic Type still reflows, VoiceOver still reads paragraphs sensibly, and the highlight wash actually looks right against all 4 themes on a real screen — all Fabio's part after the PR.

- [x] 🟡 **FAB-292** · Redesign article list: icon-first header + grouped-by-progress body  `Done` `Medium`
  Replaced the article list's four stacked control rows (search bar, tag-filter icon button, date-range row, status `FilterChipBar`) with one icon-first header row sharing "Verso"'s line, and replaced the status filter chips with always-visible, collapsible list sections. Design: [Verso Article List](https://claude.ai/code/artifact/ba753f85-c837-42a0-b11c-78c91e13d238) (settled 2026-08-29 design review). Completed 2026-08-29.

  ## What shipped

  * **Header row** (`ArticleListView.swift`): "Verso" + four plain icon buttons — search (expands into a full-width field with Cancel, replacing the row), filter (opens the combined tag + date panel below), Add (filled accent circle), and a "•••" overflow menu (Select, Settings). While bulk-selecting, the row becomes a Cancel button instead.
  * **`FilterPanel`** (renamed from `TagFilterPanel`): now combines tag selection with the date-range presets that previously lived in their own inline row — one filter icon covers both facets, with an active-count badge (tags + date) carried over from the old tag-only badge.
  * **Sections replace the status chip bar**: `ArticleListFetchedBody` now fetches every status (search/date predicate only, no status clause) and groups client-side into **Continue Reading** (`.reading`, pinned first, each card showing `ScrollProgress` + a live "N% read" caption via `Article.scrollPosition`), **Unread**, **Read** (collapsed by default), and **Archived** (collapsed by default — kept so archived articles stay reachable; the approved mockups didn't show this case since the sample data had none). Empty sections are omitted entirely rather than shown empty.
  * **`.contextMenu`** (long-press) added per row: Select, Mark as Read/Unread, Add Tags (opens the existing `ArticleTagsEditorSheet`), Archive — same actions the swipe gestures already perform, now with a tap-discoverable path. Also wired up `contextMenu.open`/`.archive`/`.unarchive`/`.markAsRead`/`.markAsUnread` — these were documented in `UI_COPY.md` but never consumed by any code before this (same stale-doc pattern as FAB-278's `home.dateFilter.label`).
  * **`ArticleCard`** gained a `showsProgress` param (Continue Reading cards) that swaps the date line for a progress bar + percentage.
  * **Removed**: `FilterChipBar.swift`, `FilterChip.swift`, and `ArticleStatus.filterAccessibilityLabel(count:)` (now-dead code with no other call sites). `filterLabel` stays — `StatusBadge`'s `.archived` fallback still uses it.
  * **Copy**: `docs/copy/UI_COPY.md` + `docs/copy/codegen/generate.py` updated and regenerated — several new keys (search/filter/overflow/add-article a11y labels, section headers and hints, `contextMenu.addTags`), two existing keys reworded in place (`home.tagFilter.button.accessibilityLabel`, `.close.accessibilityLabel`, both single-use), and five genuinely dead keys removed (`filter.all`, `.all.accessibilityLabel`, `.reading.accessibilityLabel`, `.chip.selected.hint`, `.chip.unselected.hint`). New fr-CA/pt-BR strings are `needs_review` in the generated catalog, same as every other new string in this pipeline — not a special gap.
  * `docs/COMPONENT_SPECS.md` updated (v1.1): new Header Row and Sections entries replacing the old FilterChipBar/FilterChip specs, plus a note on `ArticleCard`'s progress mode.

  ## Verified

  `xcodegen generate` + `xcodebuild -scheme Verso -destination 'generic/platform=iOS Simulator' build` — succeeded, no new warnings.

- [x] 🟡 **FAB-39** · [TTS] Implement text-to-speech playback  `Done` `Medium`
  Use AVSpeechSynthesizer to read the article aloud. Strip Markdown syntax before passing to the synthesizer. Start from the current scroll position.

- [x] 🟡 **FAB-40** · [TTS] Implement playback speed control  `Done` `Medium`
  Allow 3 speeds: 0.75x, 1x (default), 1.5x. Persist preference in UserDefaults.

- [x] 🟡 **FAB-41** · [TTS] Implement paragraph skip controls  `Done` `Medium`
  Forward/back buttons to jump to next/previous paragraph during TTS playback. Highlight the current paragraph being read.

- [x] 🔵 **FAB-50** · [PHASE 2] Implement full-text body search  `Done` `Low`
  Add full-text search across article body content, surfaced inline on the Home screen (not a separate screen — see site-map [FAB-60](https://linear.app/fabiosasseron/issue/FAB-60/design-define-main-screens-and-navigation-structure)).

  **Scope (post-MVP):**

  * Search across article body content (requires a search index)
  * Filter results by read status (All / Unread / Reading / Read)
  * Filter by date range
  * Filter by source domain
  * Use Core Data predicates for fast local search

  **Out of scope for this issue:**

  * Title-only filtering (already handled in MVP as a real-time list filter on Home — no index needed)
  * Tag filtering (requires tagging system, [FAB-52](https://linear.app/fabiosasseron/issue/FAB-52/phase-2-implement-tagging-system))

  **Note:** The search bar and title filtering are MVP (4.1.6). This issue covers only the full-text body search capability, which requires indexing and has meaningful performance implications on large Markdown files.

- [x] 🔵 **FAB-51** · [PHASE 2] Implement scroll position saving  `Done` `Low`
  When the user leaves a reading view, save the scroll offset to the article's .md frontmatter (e.g., scroll_position: 0.42). Restore on re-open. Syncs across devices via iCloud Drive.

- [x] 🔵 **FAB-52** · [PHASE 2] Implement tagging system  `Done` `Low`
  Allow users to add flat tags to articles (e.g., "research", "work"). Tags are stored in the YAML frontmatter. Filter the reading list by tag. No hierarchy.

- [x] 🔵 **FAB-53** · [PHASE 2] Implement bulk actions  `Done` `Low`
  Select multiple articles in the list view. Actions: Mark all as read, Delete all. Standard iOS multi-select pattern.

- [x] 🔵 **FAB-55** · [PHASE 3] Implement reading time estimate  `Done` `Low`
  Calculate and display estimated reading time on the article card (e.g., "5 min read"). Based on average reading speed (\~200 wpm).

- [x] 🔵 **FAB-93** · Add Archived chip filter to Home screen  `Done` `Low`
  ## Context

  Based on conflict resolution during interaction spec documentation ([FAB-82](https://linear.app/fabiosasseron/issue/FAB-82/design-document-all-interaction-specs)), we need to add an "Archived" chip filter to the Home screen.

  ## Current State

  * Home screen has filter chips: All / Unread / Reading / Read
  * No filter exists for Archived articles

  ## Requirement

  Add an "Archived" chip filter to the Home screen filter row, allowing users to view only archived articles.

  ## Acceptance Criteria

  - [ ] Archived chip appears in the filter row after "Read"
  - [ ] Tapping Archived filter shows only archived articles
  - [ ] Filter state persists appropriately
  - [ ] Empty state handling for Archived filter (no archived articles)

  ## Related

  * [FAB-82](https://linear.app/fabiosasseron/issue/FAB-82/design-document-all-interaction-specs): Document all interaction specs
  * Conflict #7 resolution: "We should have a chip filter for Archived"

- [x] 🟡 **FAB-140** · Save article images to a media folder and render captions distinctly  `Done` `Medium`
  When saving an article, images should be downloaded and stored in a `media/` subfolder inside the article's folder (rather than being referenced by remote URL). This keeps articles fully offline and self-contained.

  Additionally, image captions (subtitles) should be rendered with a distinct style — smaller, muted text — to visually differentiate them from the article body.

- [x] 🟡 **FAB-135** · Detect clipboard URL when tapping the add article button  `Done` `Medium`
  When the user taps the "+" button to manually add an article, the app checks the clipboard for a plausible HTTP(S) URL and pre-fills the URL field if found. Uses `UIPasteboard.general.hasURLs` (quiet check, no "Pasted from…" system banner).

  ## Bug found during device testing (2026-06-16)

  Initial implementation read `UIPasteboard.general.string` to get the clipboard contents after confirming `hasURLs == true`. On-device this silently failed: `hasURLs` is true whenever the pasteboard holds a URL-*type* item (e.g. copied from Safari's address bar), but `.string` reads the plain-text representation — which is `nil` when the source app stored the URL as a URL type without an accompanying plain-text type. The guard hit `nil`, the function returned early, and the field never pre-filled, with no visible error.

  **Fix:** `AddArticleView.prefillURLFromClipboardIfNeeded()` now falls back to `UIPasteboard.general.url?.absoluteString` when `.string` is nil:
  ```swift
  guard let raw = UIPasteboard.general.string ?? UIPasteboard.general.url?.absoluteString else { return }
  ```

  ## Verification (device, 2026-06-16)

  - [x] Copy a URL in Safari → switch to Verso → tap + → field pre-fills, no system banner shown
  - [x] No URL in clipboard → field stays empty
  - [x] Non-URL text in clipboard → field stays empty
  - [x] Field already has content → no overwrite

- [x] 🟡 **FAB-290** · [Phase 2] Adopt manually-added Markdown files into the reading list  `Done` `Medium`
  A note dragged into the reading folder by hand, or an existing Obsidian note, now shows up as an article instead of being silently skipped. Decisions from the 2026-08-24 brainstorm with Fabio, all shipped:

  **`MarkdownReader`:** `.invalidFrontmatter` (no `---` block) and `.missingTitle` no longer throw — both are graceful-default paths per `docs/OBSIDIAN_INTEGRATION.md` §9. No frontmatter → the whole file becomes the article body. Missing/empty `title` → falls back to the filename, stripped of extension and a leading `YYYY-MM-DD ` prefix (`MarkdownReader.synthesizedTitle(from:)`). `added`/`status` already defaulted correctly and are unchanged. `ParsedArticle` gained `needsAdoption: Bool` (true iff no frontmatter, or frontmatter with no title — recomputed fresh from disk on every read, never cached) and `unrecognizedFrontmatterLines: [String]` (any YAML key Verso doesn't own — `aliases`, `cssclass`, a personal `tags` scheme, etc. — preserved verbatim as a side effect of the frontmatter parser already being line-based).

  **Lazy write:** detecting a file needs adoption never touches disk — it's cached in Core Data with synthesized defaults and just appears in the list.

  **Adoption commit, on first write-back:** `MarkdownWriter.adoptIfNeeded(fileURL:in:)` is called from every write-back path — `ArticleListView` (toggle read/unread, archive, bulk mark-read), `ArticleReaderView` (status advance, scroll-position auto-save — the path that fires almost immediately after opening a file), and `ArticleTagsEditorSheet` (tag save). It's a no-op (`nil`) for a file that already has title'd frontmatter. Otherwise it builds a full Verso frontmatter block via a new `buildFrontmatter(for:preservingUnrecognized:)` overload (merges in the unrecognized keys rather than dropping them) and renames the file to `YYYY-MM-DD Title.md` — deliberately *not* reusing `generateFilename()`'s literal `"Article"` token (that convention is specific to brand-new Verso-authored articles per FAB-10; adopting someone else's note shouldn't insert it), reusing `uniqueFilename()` for collisions. Old file removed after the new one writes successfully; each call site updates the in-memory `Article.filePath` (and saves the context) before the old path can vanish from under `NSMetadataQuery`, so the list doesn't flash a duplicate or lose selection.

  **First-run notice:** ships as a one-time `.alert` at the app root (`ContentView`, driven by a new `AdoptionNoticeService` environment object `AdoptionNoticeService.notify()`), copy key `notice.fileAdopted.message` / `.dismiss` in `docs/copy/UI_COPY.md` (en/fr-CA/pt-BR, regenerated via `docs/copy/codegen/generate.py`). Exact placement (toast vs. modal vs. row subtitle) was an explicit open question in the original brainstorm and is **not fully resolved** — an alert was the lowest-risk option given no toast component exists yet in the codebase; revisit if it reads as too intrusive in practice.

  **Explicitly out of scope (per brainstorm, left as open questions):** a Settings toggle to opt out of auto-adoption. The known rename-vs-Obsidian-wikilinks trade-off is documented in `docs/OBSIDIAN_INTEGRATION.md` §9 but not otherwise mitigated.

  **Tests:** `MarkdownReaderTests.swift` (no frontmatter, frontmatter without title, unrecognized custom keys, filename date-prefix stripping) and `MarkdownWriterTests.swift` (`buildFrontmatter` merge, adopt-and-rename for both no-frontmatter and missing-title cases, already-adopted no-op, filename collision handling) — 20 new tests, all passing alongside the existing suite (26 total).

  **Docs:** `docs/OBSIDIAN_INTEGRATION.md` (v2.0 → v2.1) — §2, §6, §9 updated to describe adoption instead of "skip file"; `docs/copy/UI_COPY.md` new "File Adopted" entry.

  **Completed:** 2026-08-24.


- [x] 🟡 **FAB-303** · [Phase 3] Highlighting v2: cross-block selection, formatting-aware spans, headings/lists/quotes  `Done` `Medium`
  Lifts the five scope limits [FAB-54](DONE.md) shipped with on 2026-09-01: no selecting across paragraphs, a graceful decline whenever the selection crosses bold/italic/code/a link, no highlighting of headings, list items, blockquotes or table cells, and a first-occurrence splice that can target the wrong duplicate paragraph. Scope, formatting behavior and remove behavior agreed with Fabio 2026-09-01. **Parent issue — implemented incrementally, one step at a time, rather than as one PR** (this is a near-rewrite of reading-view text rendering; too large and too risky to land and verify in a single shot). Steps below get checked off as they ship; use `Refs #303` (not `Closes`) in each step's PR body so this stays open until Step 5 lands. **Completed 2026-09-02** — every step and both named follow-ups (headings/lists/blockquotes joining regions, merge with an existing highlight, and the blockquote accent bar) have shipped.

  - [x] **Step 1 — source line ranges on every block node.** Shipped 2026-09-01 (`feat/fab-303-step1-source-line-ranges`). Scoped to exactly the five block types Step 4 below names as the future cross-block "text region" (paragraph, heading, unordered/ordered list item, blockquote) — `codeBlock`/`image`/`horizontalRule`/`table` don't get a `BlockSource`, since nothing consumes it for those. `contentOffset` is UTF-16-based (matching this file's existing `NSRange` conventions) and computed generically as line length minus already-extracted content length, not hardcoded per syntax. The stated immediate payoff shipped too: `ArticleReaderView.applyHighlightChange` now splices by exact line index instead of `parsedContent.range(of: oldRawText)`, retiring the duplicate-paragraph-text edge case outright rather than leaving it for later.
  - [x] **Step 2 — per-run source offsets.** Shipped 2026-09-01 (`feat/fab-303-step2-per-run-offsets`). One correction to this step's own write-up below, found while implementing: deleting `literalRange(of:in:)`/`highlightRoundTrips` is only safe for a selection that stays inside a *single* tagged inline run — slicing raw text between two exact offsets when the selection crosses into a differently-formatted run would split that run's delimiters (e.g. `**`) and corrupt the file. So this step restricts the new offset-based `ArticleHighlighter.addHighlight(atRawOffsetRange:in:)` to the same-run case (the common one — an ordinary sentence with no internal formatting is almost always one run) and keeps declining a cross-run selection, same visible behavior as before, just detected by comparing tagged runs instead of a failed text search. Making the cross-run case itself work correctly is still Step 3's job, not moved up.
  - [x] **Step 3 — formatting-aware wrapping.** Shipped 2026-09-01 (`feat/fab-303-step3-formatting-aware-wrapping`). One narrowing of this step's own write-up below, decided before writing code rather than found mid-PR like the last two steps' corrections: shipped snap-outward (bold/italic/bold-italic/link/code), the inline-code decline, and the recursive `.highlight([InlineNode])` this all depends on — **deferred "merging with an adjacent or overlapping existing highlight."** That case needs finding every highlight run a selection touches, stripping their markers, and computing one fresh merged wrap, all before the offsets used for the wrap are still valid — close in shape to Step 5's own "collect every touched highlight run" remove logic, so it's landing there instead of being built twice. For now a selection touching an existing highlight still declines, same as before this step — no regression, just not the improvement yet. Also worth knowing: markdown delimiters are never rendered as visible characters, so *any* touch of a delimited run — even one that happens to land exactly at its rendered edge — snaps to that run's full span; there's no "safely outside the delimiters" rendered position short of the whole thing.
  - [x] **Step 4 — text regions, paragraphs only.** Shipped 2026-09-01 (`feat/fab-303-step4-paragraph-regions`). A real narrowing of this step's written scope below, decided up front rather than found mid-PR: the spec merges *five* block types (paragraph/heading/both list-item kinds/blockquote) into one shared `UITextView`, rebuilding heading fonts, bullet/number indentation, and — the spec's own words — "the one real visual risk," blockquote's 3pt accent bar, as TextKit attributes. That visual-fidelity work needs a real device to get right and I don't have one; shipped only **consecutive `.paragraph` merging** this session — headings/list items/blockquotes still render individually, unmerged, exactly as before this step, still not selectable across their own boundary. This covers the single most common case (a highlighted thought spanning a paragraph break within a run of body text) without touching the genuinely risky part. Extending regions to the other four block types is a named follow-up, not silently dropped. Also added the guard Step 5 will build on: `HighlightableUITextView` now tracks which underlying paragraph a run belongs to (`.versoParagraphIndex`), and declines a wrap spanning more than one paragraph — selection already flows across a paragraph break today, but turning that into an actual cross-paragraph highlight is still Step 5's job.
  - [x] **Step 5 — cross-paragraph write and remove.** Shipped 2026-09-01 (`feat/fab-303-step5-cross-paragraph-write-remove`). A further narrowing on top of Step 4's own: since only consecutive `.paragraph` nodes are merged into a region so far, "cross-block" in practice means "cross-paragraph" until that follow-up lands. Shipped: a selection spanning two or more paragraphs now writes one `==…==` pair per paragraph (tail of the first, full middle paragraphs, head of the last — `ArticleHighlighter.crossParagraphHighlightRanges`), and Remove Highlight on any piece of a highlight that got split across a paragraph break now removes every linked piece in one action, walking outward through as many paragraphs as are actually chained (`ArticleHighlighter.chainedHighlightPieces`/`leadingHighlightIndex`/`trailingHighlightIndex`) — not just the 2-paragraph case. Both are pure, UIKit-free functions, directly unit-tested, unlike most of Steps 2–4's core logic. **Deferred again, contradicting Step 3's own note that it'd land here:** "merge with an adjacent/overlapping *existing* highlight" — touching a selection boundary to an already-highlighted run still declines, unchanged. Building it well turned out to need the same chain-walking Remove got here, *plus* stripping old markers and recomputing a fresh wrap across however many paragraphs the merged result spans — a second, similarly-sized problem, not a small add-on, so it's staying out rather than being rushed into this step. **FAB-303 stays open** — two follow-ups remain, both already named, nothing newly dropped: headings/lists/blockquotes joining regions (Step 4's own follow-up), and this merge case.
  - [x] **Headings/lists/blockquotes join regions** (Step 4's own follow-up). Shipped 2026-09-01 (`feat/fab-303-headings-lists-blockquotes-regions`), after Fabio confirmed on device that Step 5 worked but flagged the thing this follow-up fixes: bullets and titles couldn't be selected or highlighted at all. `groupIntoRenderUnits` now merges `.heading`/`.unorderedListItem`/`.orderedListItem`/`.blockquote` into the same region a run of paragraphs already forms — a region only ever breaks at image/codeBlock/table/horizontalRule now. Renamed for accuracy since a region is no longer paragraph-only: `HighlightableParagraphText`→`HighlightableRegionText`, `MarkdownRegionParagraph`→`MarkdownRegionBlock`, `.paragraphRegion`→`.textRegion`, `.versoParagraphIndex`→`.versoBlockIndex`, `ArticleHighlighter.crossParagraphHighlightRanges`→`crossBlockHighlightRanges` (param renames only — that function and `chainedHighlightPieces` were already block-kind-agnostic, since both only ever read a block's own `BlockSource`). **A real bug caught while designing this, before any code was written:** `leadingHighlightIndex`/`trailingHighlightIndex` (from the step above) re-parsed a block's raw text by trimming *whitespace* — correct for a paragraph, whose only leading "extra" is whitespace, but a heading/list-item/blockquote's `rawText` carries its own syntax prefix (`"## "`, `"- "`, `"> "`), which whitespace-trimming doesn't strip. Re-parsing without removing it would have made "does this block start with a highlight" subtly wrong for every non-paragraph block, right where they were becoming reachable for the first time. Fixed by slicing on the block's own `contentOffset` (already correct for every block kind, from Step 1) instead of naively trimming whitespace — both functions now take the block's `BlockSource` directly rather than a bare `rawText: String`. **Blockquote's colored accent bar stayed out, exactly as flagged when this follow-up was named:** shipped indent-only (italic, secondary color, same 15pt total inset as the bar+gap, just no bar) rather than guessing at a TextKit custom-draw override blind — the backlog's own note said this needed a real device, "do not assume," and that hasn't changed. Two smaller judgment calls, lower risk: heading weight on a custom font family approximates "semibold" with the same bold-symbolic-trait fallback already used elsewhere (UIKit has no semibold symbolic trait); list bullet/number indent numbers (20pt/32pt) are a close port of the old `HStack`-based layout's numbers, not an exact translation. **FAB-303 stays open** — the colored accent bar and the existing-highlight-merge case (from Step 5) are what remain, both small, both needing Fabio's own eyes or judgment rather than a blind guess.
  - [x] **Merge with an existing highlight** (deferred from Step 3, then again from Step 5). Shipped 2026-09-02 (`feat/fab-303-merge-existing-highlight`), Fabio's pick over the blockquote accent bar. Scoped to **same-block merge only**: a selection that overlaps or is directly adjacent to one or more existing highlights within one block — whether touched at an edge or fully enclosing one in the middle — strips their markers and wraps the whole union fresh in one pair (`ArticleHighlighter.addOrMergeHighlight`), transitively, so a chain of mutually-adjacent highlights merges in one action. Pure, offset-based, directly unit-tested — no UIKit needed. **A real, already-shipped corruption bug surfaced while designing this, not just a missing feature:** the old decline check only ever looked at a selection's two boundary positions, so a selection starting and ending in plain text with an *entire* existing highlight sitting inside it never tripped it — it fell through to a plain wrap, nesting a fresh `==…==` around text that already had one (`==very much before ==highlighted middle== well after==`, not valid). Fixed as a side effect of merge, since merge has to find every touched highlight anyway, not just the ones at the edges. **Cross-block merge deliberately not attempted** — the same order of complexity as this session's own scope (finding every touched piece across blocks and re-verifying boundaries after stripping), so a cross-block write still declines on touching an existing highlight, but now via an explicit check (`ArticleHighlighter.rangeTouchesExistingHighlight`) rather than the narrower boundary-only check that let the corruption case above slip through — closing the same latent bug on that path too, without taking on full cross-block merging. **FAB-303 stays open** — the blockquote accent bar is the only piece left.
  - [x] **Blockquote's colored accent bar** — the last piece. Shipped 2026-09-02 (`feat/fab-303-blockquote-accent-bar`). Drawn directly by `HighlightableUITextView.draw(_:)` rather than as an attributed-string attribute — TextKit has no attribute for "colored rectangle beside these lines." `HighlightableRegionText.buildAttributedString` now also returns each `.blockquote` block's `NSRange` within the built string; the text view asks its layout manager for that range's on-screen bounding rect each time it draws (spanning every wrapped line of a multi-line quote as one continuous bar, not one bar per line). 3pt bar, 12pt gap, `colors.accent` fill — ported 1:1 from the deleted SwiftUI `HStack(spacing: 12) { Rectangle().fill(colors.accent).frame(width: 3) }` this replaced; the 15pt blockquote indent already reserved exactly this space, so nothing about the text layout itself changes. **No unit test for this one** — everything else FAB-303 shipped had a pure, UIKit-free core `VersoTests` could assert on; this is pixel-level `CoreGraphics` drawing inside a live `UITextView`, so the real check is Fabio's own eyes on device across all 4 themes and at larger Dynamic Type sizes, same as the backlog's own note said it would need. **FAB-303 is done** — every step and every follow-up named across this checklist has shipped; see `docs/DONE.md`.

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

  ## Step 3 — Formatting-aware wrapping ✅ Done 2026-09-01 (merge deferred to Step 5, see checklist above)

  With exact offsets, marker placement is now a decision rather than a search:

  * Boundary inside a plain-text run → wraps exactly there. ✅ Shipped (already true as of step 2).
  * Boundary strictly inside a bold/italic/bold-italic/link/code run → **snaps outward** to that run's edge. Never splits an emphasis run; never places a marker inside a link's `(url)` or a code span's backticks. ✅ Shipped — and turned out to apply to *any* touch of such a run, not just a boundary landing "strictly inside" one, once it became clear delimiters are never rendered characters at all: there's no rendered position that's safely outside them, even at a run's own edge.
  * Selection lying **entirely** inside one inline-code run → nothing safe to wrap, declines (a single error haptic, same quiet no-op every other decline in this feature uses — no new Copy needed). ✅ Shipped.
  * Selection overlapping or directly adjacent to an existing highlight → strip those markers and emit **one merged pair**. **Deferred to land alongside Step 5** (see checklist above) — still declines today, unchanged from before this step. **✅ Shipped 2026-09-02** (see the checklist's own "Merge with an existing highlight" entry above) — same-block only; cross-block still declines.
  * `InlineNode.highlight` is now recursive — `.highlight([InlineNode])` instead of `.highlight(String)` — so `==**bold** x==` renders as bold inside the wash instead of literal asterisks. ✅ Shipped; required for snap-outward itself to render correctly, not a separate nice-to-have.

  ## Step 4 — Text regions: one text view per run of consecutive text blocks ⚠️ Done 2026-09-01, paragraphs only (see checklist above)

  This is the cross-paragraph fix and the bulk of the work. iOS cannot extend a native selection across two views, and today every paragraph is its own `UITextView`.

  **Shipped this session:** group consecutive `.paragraph` nodes into a **text region**, rendered as a single `HighlightableParagraphText` — the multi-paragraph case, where every merged block is the same type and needs the same (already-existing, 16pt default) spacing rule, no font/bullet/bar work at all. Selection flows across a paragraph break today.

  **Not shipped — deferred, not silently dropped:** merging `.heading` / `.unorderedListItem` / `.orderedListItem` / `.blockquote` into regions too. What that still needs, unchanged from the original write-up:

  * Bullets and numbers → a literal `•\u{2003}` / `3.\u{2003}` prefix plus `headIndent` / `firstLineHeadIndent`, tagged non-highlightable so a marker can never land in the bullet.
  * Heading fonts → `VersoTypography.Reading` mapped to `UIFont`; the custom-font fallback in `withSymbolicTraits` already handles families with no bold face.
  * Inter-block spacing between *different* block types (24 before a heading, 6 between sibling list items) → `NSParagraphStyle.paragraphSpacingBefore`, reusing `topSpacing`'s existing numbers (only the paragraph-to-paragraph 16pt case was needed this session, since a paragraphs-only region never sits next to a different type internally).
  * **Blockquote's 3pt accent bar is the one real visual risk.** In TextKit it needs either a text-layout-fragment draw override or a downgrade to indent-only. Decide during implementation against a side-by-side with the current build — do not assume. This is the specific piece that needs a real device in the loop, not just a build, which is why it's not part of this session. **✅ Shipped 2026-09-02** (see the checklist's own "Blockquote's colored accent bar" entry above) — went with the draw-override option this note named, not the indent-only downgrade.

  Also needs re-verification when that follow-up lands, not assumption: `sizeThatFits` is doing more work now that a region can be several paragraphs tall (already true this session, worth Fabio's own pass), and Dynamic Type reflow within a region has never been exercised on any real device yet.

  **✅ Follow-up shipped 2026-09-01** (see the checklist's own "Headings/lists/blockquotes join regions" entry above): every bullet point above landed except the accent bar, which stayed a downgrade to indent-only exactly as this note said it might need to.

  ## Step 5 — Cross-paragraph write and remove ⚠️ Done 2026-09-01, paragraphs only (see checklist above)

  * **Write:** a selection spanning blocks becomes one `==…==` pair per block — tail of the first, whole middle blocks, head of the last. Any block in the range that can't take markers (code block, table, rule) is skipped rather than aborting the whole action. ✅ Shipped, scoped to consecutive paragraphs (the only block type merged into a region so far — see Step 4); the "skip a block that can't take markers" case doesn't actually arise yet, since every block a region can currently span is a plain paragraph. `ArticleHighlighter.crossParagraphHighlightRanges` computes the ranges; a paragraph's own content bounds come from trimming `BlockSource.rawText`'s leading/trailing whitespace, mirroring the exact trim `MarkdownParser.flushParagraph` already does — same coordinate space, no new assumption.
  * **Remove:** `removeHighlight(at:in:)` goes from index-based to range-based. Collect every `.highlight` run the selection touches, walk outward while neighbouring runs are contiguous (only whitespace or a block boundary between them), unwrap them all. ✅ Shipped as `ArticleHighlighter.chainedHighlightPieces` — walks outward through as many linked paragraphs as are actually chained (each one's own leading/trailing highlight lining up with its neighbor's), not capped at two.
  * **Merge with an adjacent/overlapping existing highlight** (deferred from Step 3, which said it'd land here): still declines, unchanged. Turned out to need the same chain-walking Remove got, plus stripping the old markers and recomputing a fresh wrap across however many paragraphs the merge spans — a second, similarly-sized problem, not a small add-on. This is now the one remaining piece of FAB-303's original write-up not yet shipped, alongside Step 4's headings/lists/blockquotes follow-up. **✅ Shipped 2026-09-02, same-block only** (see the checklist's own "Merge with an existing highlight" entry above) — cross-block merge turned out to need the exact same chain-walking-plus-recomputing problem predicted here, so it's still deferred, but a cross-block write can no longer silently corrupt an existing highlight it doesn't merge with — it declines instead, closing a real bug this step's own scope surfaced.

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


### Phase 3 — Expansion

- [x] 🔵 **FAB-90** · Import articles from other reading apps  `Done` `Low`
  Allow users to import their existing reading list from other apps into Verso.

  ## Supported sources (initial scope TBD)

  * GoodLinks
  * Instapaper
  * Readwise Reader
  * Matter
  * Pocket
  * Others TBD

  ## Notes

  Each app has its own export format (JSON, CSV, HTML bookmarks, etc.), so the import flow will need to handle multiple formats. This is also an important onboarding feature — users switching from other apps should be able to bring their library with them.

- [x] 🔵 **FAB-91** · Smart links — auto-link related articles in the vault  `Done` `Low`
  Automatically detect and surface relevant connections between articles saved in the user's vault.

  ## Concept

  When reading an article, the app suggests other articles in the vault that are semantically related — similar to how tools like Obsidian or Readwise Reader surface related notes/highlights. Links could appear as an inline suggestion, a sidebar panel, or a "Related" section at the end of the article.

  ## Considerations

  * Needs a similarity/relevance algorithm (could be keyword-based, embedding-based, or a hybrid)
  * Should work offline or degrade gracefully without a network connection
  * User should have some control over what gets linked (e.g., minimum relevance threshold, ability to dismiss suggestions)
  * Privacy implications of any server-side processing should be evaluated


### TestFlight bugs — 2026-08-23

- [x] 🟠 **FAB-285** · Onboarding "How it works" tour has no way to advance except Skip  `Done` `High`
  On the tour screen (3 steps, after the folder picker), nothing advanced the steps except the Skip button — no swipe, no tap target. Root cause: `QuickTourView` put its own 3-step `TabView` (page style, swipeable) *inside* `OnboardingFlowView`'s 5-screen `TabView` (also page style, swipeable) — two horizontally-paging containers on the same axis, a known SwiftUI/UIKit conflict. Since the tour was the *last* of the outer TabView's pages, it had nowhere further to swipe to, so it absorbed the gesture and the inner tour never saw it; this also produced two overlapping page-dot indicators. Fixed by flattening the 3 tour steps directly into `OnboardingFlowView`'s own `TabView` (tags 4–6) — `QuickTourView` no longer owns a `TabView` or page-dot indicator; it now renders a single step's content, parameterized by `stepNumber`, and `OnboardingFlowView`'s outer 7-dot indicator covers the whole flow. Added an explicit "Next" button (with chevron) on the two non-final tour steps — not swipe-only — for discoverability and for VoiceOver/Switch Control users; the final step still reads "Start reading" and Skip still works from any step. New copy key `onboarding.tour.next` added to `docs/copy/UI_COPY.md` and regenerated via `docs/copy/codegen/generate.py`.

  **Completed:** 2026-08-23.

- [x] 🟠 **FAB-286** · New files dropped into the folder aren't picked up automatically  `Done` `High`
  First run correctly picked up the pre-existing .md files in the chosen folder; files added to that folder afterward didn't show up in the list. The library rescan was wired to `ICloudFileWatcher`, but that watcher is built on `NSMetadataQuery` (Spotlight), whose coverage of an arbitrary folder picked through the Files/document picker — outside the app's own iCloud container — is unreliable. Fixed by also calling `articleLibraryService.rebuildCache(from:context:)` inside `VersoApp.swift`'s existing `scenePhase == .active` branch, alongside the `PendingArticleIngester` call already there — this guarantees a rescan every time the app returns to the foreground, independent of whether the watcher fires.

  **Completed:** 2026-08-23.

- [x] 🟠 **FAB-288** · Status badge in the "All" list doesn't refresh after reading an article  `Done` `High`
  Opening an unread article correctly flipped it to Reading in Core Data right away (and to Read once scrolled ~95% through), but the badge on the list row didn't repaint until something else forced the list to redraw (e.g. pull-to-refresh), because `ArticleCard` held the article as a plain, unobserved reference rather than one SwiftUI was told to watch. Fixed by changing `let article: Article` to `@ObservedObject var article: Article` in `ArticleCard.swift` — the standard fix for a Core Data object whose attribute changes need to redraw a specific row. Checked `ArticleListView.swift`'s `rowLabel(for:)` and swipe-action closures for the same plain-reference pattern; both only pass `article` through as a fresh function/closure parameter each render (not a stored field), so no further fix was needed there.

  **Completed:** 2026-08-23.

- [x] 🟡 **FAB-287** · "All" tab count includes archived articles  `Done` `Medium`
  The number on the "All" filter chip should only reflect Unread + Reading + Read, since archived articles never show in any of those lists — but it summed the per-status counts across *every* `ArticleStatus` case, including `.archived`, always overcounting by however many articles were archived. Fixed in `FilterChipBar.swift` by summing only Unread + Reading + Read for the "All" count via a new `allCount` computed property, excluding Archived; the Archived chip keeps its own (already-correct) count.

  **Completed:** 2026-08-23.

- [x] 🔵 **FAB-289** · Release pipeline hardening (`release.yml`, `ci.yml`)  `Done` `Low`
  Follow-up pass after `release.yml`'s first successful run (32651214255), scoped to changes around the archive/sign/upload steps only — those were left byte-for-byte untouched. Added SPM caching to `release.yml` (mirroring `ci.yml`'s existing cache step, same key). Confirmed via a real run (32652825341) that the cache genuinely hits, but delivers no measurable speedup (5m50s → 5m49s across two full runs): the cached path (`.../xcshareddata/swiftpm`) mostly holds `Package.resolved`, not the downloaded package sources, so there's little to actually cache — worth knowing so no one re-chases this expecting a win. Bumped `actions/checkout@v4` → `@v7` in both workflows (clean, no new warnings) — but a full log grep on the verification run found the Node 20 deprecation notice we were trying to clear is actually emitted by `actions/cache@v4`, not `checkout`, so that specific warning is still present; bumping `actions/cache` would be the actual fix, if ever worth doing (low priority, cosmetic). Investigated the "untrusted tap" Homebrew annotation seen during `brew install xcodegen`: tested `HOMEBREW_NO_AUTO_UPDATE=1` / `HOMEBREW_NO_INSTALL_CLEANUP=1` on a real run, confirmed the warning still fired identically — disproving the auto-update theory — so reverted rather than ship an ineffective fix. It's macos-26 runner-image noise (a pre-tapped, untrusted `aws` tap triggering Homebrew's trust check on any `brew` command), not something this repo's workflow config can address; left as-is. Also corrected `release.yml`'s header comment, which had called it "UNTESTED SCAFFOLDING... has never run successfully" — no longer true.

  **Completed:** 2026-08-23.

### TestFlight bugs — 2026-08-25

- [x] 🔴 **FAB-291** · App crashes on launch and on foregrounding (Core Data thread-safety violation)  `Done` `Urgent`
  Reported by Fabio, reproduced by a friend's device too — crashed both on a cold launch and when switching back to Verso from another app. Confirmed via two real crash logs pulled from Xcode Organizer (TestFlight builds 4 and 5): both were Swift runtime traps ("Unexpectedly found nil while unwrapping an Optional value") reading a non-optional `@NSManaged` property — `Article.id` (a `ForEach` in the article list) in one, `Article.dateAdded` (`ArticleReaderView`'s header) in the other. Root cause: `PendingArticleIngester` was the only Core Data-touching service in the codebase not isolated to `@MainActor` (unlike `ArticleLibraryService` and `ImportOrchestrator`, which both correctly are). Since `viewContext` is confined to the main thread, `PendingArticleIngester.ingest(...)` — kicked off via a plain `Task { }` in `VersoApp.swift`'s `onAppear` and `.onChange(of: scenePhase)` (i.e. on every launch and every foreground) — was fetching, mutating, and saving `Article` objects from a background thread at the same moment the UI was reading those same objects on the main thread. One of the crash logs shows this directly: `PendingArticleIngester.upsertCoreData` mid-`context.save()` on a background dispatch thread, at the exact instant the main thread crashed reading `Article.id`. This is a race, not a deterministic bug — explains why it wasn't consistently reproducible in dev, and why it was more likely whenever a share-extension import was pending during launch/foreground. **Fix:** added `@MainActor` to `PendingArticleIngester`, matching the existing pattern on its sibling services. **Not yet verified by a real build/CI run** — see [[project_verso]] / next TestFlight upload. `RelatedArticlesService` (also Core Data-touching, also not `@MainActor`) is lower risk — it's read-only and currently only called from a `.task` already on the main actor — but is a good candidate for the same hardening as a follow-up if it's ever called from elsewhere.

  **Completed:** 2026-08-25.


## Web

### Phase 3 — Expansion

- [x] 🟠 **FAB-165** · [WEB] Phase 1: Scaffold Next.js app + port design system tokens  `Done` `High`
  Set up the `verso-web/` directory as a Next.js + TypeScript app and port the full Verso design system to CSS custom properties.

  ## Tasks

  * Scaffold `verso-web/` with `create-next-app` (TypeScript, Tailwind, App Router)
  * Port all 4 themes (Paper, Sepia, Night, Ink) from `docs/DESIGN_TOKENS.md` to CSS custom properties (`--color-background`, `--color-text-primary`, etc.)
  * Implement `ThemeProvider` (React context) with localStorage persistence + system dark mode detection
  * Add OpenDyslexic font (bundled, matching iOS)

  ## Verification

  App loads, theme toggle switches all CSS variables correctly across all 4 themes.

- [x] 🟠 **FAB-166** · [WEB] Phase 1: FileSystemService + Article model + useArticleLibrary hook  `Done` `High`
  Build the core file system abstraction and article data layer that mirrors the iOS file-first architecture.

  ## Tasks

  * Define `Article` TypeScript type matching iOS YAML frontmatter fields exactly (`title`, `url`, `status`, `tags`, `added`, `scroll_position`, `author`, `site_name`)
  * Build `FileSystemService`:
    * `openFolder()` → `showDirectoryPicker()` with IndexedDB persistence of `FileSystemDirectoryHandle`
    * `readArticles()` → enumerate `.md` files, parse frontmatter with `gray-matter`
    * `writeArticle(file, content)` → write back to FS handle
    * `createArticle(title, url, body, metadata)` → create new `YYYY-MM-DD Title.md` file
  * Implement `useArticleLibrary` hook — in-memory cache rebuilt from FS reads (mirrors Core Data pattern)

  ## Notes

  * File format is identical to iOS: `YYYY-MM-DD Title.md` with YAML frontmatter
  * Browser support: Chrome 86+, Edge 86+ (File System Access API)
  * Verification criterion met by FAB-167 article list screen (data layer fully implemented; wiring deferred to avoid duplicating UI work)

- [x] 🟠 **FAB-167** · [WEB] Phase 2: Article list screen  `Done` `High`
  Main article list screen matching the iOS Home screen. Delivered: `ArticleListPage`, `FilterChipBar`, `SearchBar`, `ArticleCard`, `EmptyState`, `LoadingState`, unsupported browser gate, theme switcher. Verified 2026-06-12.

- [x] 🟠 **FAB-168** · [WEB] Phase 3: Article reader + Markdown renderer  `Done` `High`
  Full-screen immersive reading view with Markdown rendering.

  ## Delivered

  * `ArticleReaderPage` (`/app/article/[id]/page.tsx`) — loads article by filename from saved FS handle; back nav; Aa toggle for controls panel
  * `MarkdownRenderer` — `react-markdown` + `remark-gfm`; all element types styled with design tokens: headings (h1–h6), paragraphs, links, ul/ol/li, blockquote, inline code, code blocks, hr, images, GFM tables, strikethrough
  * Typography controls (bottom panel): 4 font families (Georgia / System / Mono / OpenDyslexic), 6 font sizes (14–26px), 4 line-height presets (Compact / Normal / Relaxed / Airy), theme switcher
  * Prefs persisted to localStorage; restored on next visit
  * Article header: title, site_name, date, author, source URL
  * `readArticle()` added to `FileSystemService` for single-file reads
  * `ArticleCard` click updated to `router.push(/article/[filename])`

  ## Verification

  Open article from list → markdown renders with all element types. Font/size/spacing controls update reading area live. TypeScript-clean.

- [x] 🟡 **FAB-170** · [WEB] Phase 3: Scroll position persistence + auto-status progression  `Done` `Medium`
  Mirror the iOS reading progress tracking — save scroll position to YAML frontmatter and auto-update article status.

  ## Delivered

  * **Scroll restore** — on article open, if `scroll_position` is set in frontmatter, scrolls to that position after two `requestAnimationFrame`s (waits for browser reflow). Uses `behavior: "instant"` to avoid jarring animation.
  * **Scroll save (debounced 500ms)** — watches `scrollProgress` (0–1 ratio computed for the progress bar); debounces writes at 500ms idle; persists `scroll_position` to YAML frontmatter via `FileSystemService.writeArticle()`.
  * **`unread → reading`** — fires once on article open via a `useRef` one-shot guard; writes new status to frontmatter immediately.
  * **`reading → read` at 90%** — fires once when scroll crosses 0.9; guards against re-triggering and skips `archived` articles.
  * All logic in `verso-web/app/article/[id]/page.tsx`; no changes to `FileSystemService` or `types/article.ts` — both already supported `scroll_position`.

  ## Verification

  Open article → scroll halfway → close tab → re-open → scrolled to same position. Article status in list shows "Reading" after opening unread article. Status auto-advances to "Read" after scrolling past 90%. Open `.md` file in text editor — `scroll_position` and `status` updated in YAML frontmatter. TypeScript-clean.

- [x] 🟡 **FAB-169** · [WEB] Phase 3: Auto-hide chrome + reading controls panel  `Done` `Medium`
  Immersive reading experience — chrome fades out during reading and snaps back on interaction.

  ## Delivered

  * `useIdleChrome` hook — chrome visible on mount; hides after 2s idle; any mousemove / touch / keydown shows it for 3s; idle timer suspended while controls panel is open
  * `ScrollProgressBar` — 3px accent-colored bar fixed at very top of viewport, tracks scroll 0→100%, always visible (not subject to auto-hide)
  * `FirstUseHint` — "Tap anywhere to show or hide controls" tooltip shown once per device (localStorage flag), fades out on first interaction
  * `Chrome` component — top nav + bottom controls panel both use `opacity` + `pointer-events` CSS transitions (0.3s ease); controls panel slides with `max-height` transition
  * Aa button highlights when controls panel is open
  * Mark as read button in controls panel — writes status back to frontmatter via `FileSystemService.writeArticle()`; hidden once article is already read
  * Links in article body `stopPropagation` so clicking them doesn't toggle chrome
  * `fsHandle` stored in state so mark-as-read can write without re-fetching

  ## Verification

  Read article → chrome hides after 2s → click reveals it → controls panel opens → theme/font changes apply instantly. TypeScript-clean. · [WEB] Phase 2: Article list screen  `Done` `High`
  Main article list screen matching the iOS Home screen.

  ## Delivered

  * `ArticleListPage` (`/app/page.tsx`) — full list wired to `useArticleLibrary`
  * `FilterChipBar` — All / Unread / Reading / Read chips with live counts; persistent on empty filtered views
  * `SearchBar` — real-time in-memory title search with clear button
  * `ArticleCard` — status dot (fixed iOS colors), title, site_name / hostname, date
  * `EmptyState` — context-aware messaging (no folder / no results / no search match) with folder-picker CTA
  * `LoadingState` — spinner during FS reads
  * Unsupported browser gate (Chrome/Edge 86+ notice)
  * Theme switcher preserved in top bar

  ## Verification

  Selected iCloud Drive folder → articles from iOS app appeared with correct status colors, metadata, and filter/search working. Confirmed 2026-06-12.


## Design / UX

### Phase 1 — Foundation

- [x] 🔴 **FAB-56** · [DESIGN] Create proto-personas  `Done` `Urgent`
  Define 2–3 archetypal users (e.g., Knowledge Worker, News Enthusiast, Academic Researcher). Simple 1-page persona per type: name, goals, frustrations, tech comfort level. Everything builds from this.

- [x] 🔴 **FAB-57** · [DESIGN] Document user frustrations with Pocket/Instapaper  `Done` `Urgent`
  What specifically frustrates target users? Feature bloat? Privacy? UI clutter? Deliverable: 5–7 bullet points per persona's pain points. Guides differentiation strategy.

- [x] 🔴 **FAB-58** · [DESIGN] Define primary user flows  `Done` `Urgent`
  Step-by-step journeys for: (1) Save article via Share sheet, (2) Read article with all features, (3) Archive/search. Deliverable: 3 flowcharts (text-based or sketched). Unblocks all wireframing.

- [x] 🟠 **FAB-59** · [DESIGN] Map secondary user flows  `Done` `High`
  Flows for: offline reading, tagging, progress saving, text-to-speech, data access via iCloud Drive. Deliverable: 2–3 additional flowcharts.

- [x] 🔴 **FAB-60** · [DESIGN] Define main screens and navigation structure  `Done` `Urgent`
  Identify all screens needed for MVP: Home/List, Reading View, Settings, Search, Onboarding. Deliverable: site map (boxes + connections) + short description of each screen's purpose. Required before wireframes.

  **Deliverable:** [docs/site-map.md](<https://github.com/whysasse/verso/blob/main/docs/site-map.md>)

- [x] 🔴 **FAB-61** · [DESIGN] Prioritize features per screen  `Done` `Urgent`
  Which features appear on which screen for MVP vs. post-MVP? Deliverable: table — Screen name | MVP features | Post-MVP features. Guides scope for Phase 1 wireframes.

- [x] 🟠 **FAB-62** · [DESIGN] Define key interactions and gestures  `Done` `High`
  Swipe to delete, pull-to-refresh, tap to save, long-press for context menu, tap to toggle immersive mode, etc. Deliverable: list of core interactions and what they trigger. Needed before wireframes.

  **Deliverable:** `docs/interactions-and-gestures.md`

  Covers all interactions across: Share Extension, Onboarding, Home, Archive View, Reading View, Reader Settings, Settings, Folder Setup, Appearance, and About. Organized by screen with gesture type, trigger, and result for each interaction.

- [x] 🔴 **FAB-63** · [DESIGN] Map out navigation patterns  `Done` `Urgent`
  Tab bar? Bottom sheet? How does the user move between screens? Deliverable: navigation sketch or diagram. Critical part of IA.

  **Deliverable:** `docs/navigation-patterns.md` — covers the top-level architecture decision (NavigationStack, no tab bar), a Mermaid diagram annotating every transition with its iOS pattern type (push, modal sheet, bottom sheet, inline toggle), a full transition reference table, and the reasoning behind each key decision.

- [x] 🔴 **FAB-64** · [DESIGN] Define typography system  `Done` `Urgent`
  ## Typography Spec — Complete

  ### Font Choices

  * **New York** (default) — system serif, Apple-designed for reading
  * **Georgia** — classic serif, universally loved
  * **San Francisco** — system sans-serif, clean and modern
  * **OpenDyslexic** — bundled dyslexia-adapted font (accessibility requirement)

  ### 6 Reading Sizes (per PRD)

  | Label | Size | Weight | Line Height |
  | -- | -- | -- | -- |
  | XS | 14pt | Regular | 1.75× |
  | S | 16pt | Regular | 1.75× |
  | **M (default)** | **18pt** | **Regular** | **1.75×** |
  | L | 20pt | Regular | 1.75× |
  | XL | 22pt | Regular | 1.6× |
  | XXL | 26pt | Regular | 1.5× |

  ### Heading Typography

  * H1: 28pt Bold (1.2× line height)
  * H2: 24pt Semibold (1.25×)
  * H3: 20pt Semibold (1.3×)
  * H4: 18pt Semibold (1.35×)

  ### UI Typography (non-reading)

  Uses San Francisco at system sizes: screen titles (34pt Bold), list items (17pt), captions (13pt).

  ### Rationale

  * Regular weight across all sizes maximizes legibility
  * Line height decreases at larger sizes to maintain visual balance
  * OpenDyslexic uses separate font files (not weight axis)
  * All reading fonts are system fonts except OpenDyslexic (bundled)

  Spec documented in: `docs/DESIGN_SYSTEM_FOUNDATIONS.md` Sections 3.1–3.5

- [x] 🔴 **FAB-65** · [DESIGN] Define color palette (light and dark mode)  `Done` `Urgent`
  Primary, secondary, accent, and neutrals for all 4 themes (Paper, Sepia, Night, Ink). Consider WCAG AA contrast. Deliverable: color palette (hex codes) + contrast ratios for critical pairs.

- [x] 🟠 **FAB-66** · [DESIGN] Define spacing and grid system  `Done` `High`
  8pt grid? 4pt? Margins, padding, gaps between elements. Deliverable: spacing scale (4, 8, 12, 16, 24, 32px...) + grid documentation. Keeps the design consistent.

- [x] 🔴 **FAB-67** · [DESIGN] Define accessibility requirements  `Done` `Urgent`
  Min touch target size (44×44pt), font scaling rules, color contrast (WCAG AA), focus states. Deliverable: accessibility checklist + specs. Non-negotiable — define upfront, not as an afterthought.

- [x] 🟠 **FAB-68** · [DESIGN] Create component inventory  `Done` `High`
  List of all UI components needed: buttons, cards, tabs, nav bar, text input, etc. Deliverable: component list with brief description of each variant and state needed.

- [x] 🔴 **FAB-69** · [DESIGN] Wireframe Home/Reading List screen  `Done` `Urgent`
  Article list view. Title, source, date. Swipe actions. Empty state. Pull-to-refresh. Deliverable: low-fi sketch or wireframe (Figma, Excalidraw, or paper). MVP core screen.

  **Include in wireframe:**

  * Filter chips at the top: **All / Unread / Reading / Read**
  * Article card status indicators (e.g., dot for Unread, partial indicator for Reading, no indicator for Read)
  * Empty state variant for each filter (e.g., "Nothing here yet" for All, "You're all caught up!" for Unread)

- [x] 🔴 **FAB-70** · [DESIGN] Wireframe Reading View  `Done` `Urgent`
  Article title, source, date, body text with proper spacing. Top/bottom controls. Immersive mode toggle. Deliverable: low-fi wireframe showing the full reading UX. MVP core screen.

- [x] 🔴 **FAB-71** · [DESIGN] Wireframe Settings screen  `Done` `Urgent`
  Typography controls (size, font), theme switcher, folder management, privacy policy, about. Deliverable: low-fi wireframe.

  **Include in wireframe:**

  * Folder management row showing current folder path
  * Folder change dialog: *"Move your existing articles to the new folder? Your old folder won't be touched if you choose No."* with \[Move Articles\] and \[Keep in Old Folder\] actions

- [x] 🟠 **FAB-72** · [DESIGN] Wireframe Home screen — search-active state  `Done` `High`
  Search bar, filters, results list, empty state. Deliverable: low-fi wireframe.

  **Filters to include:** status (All / Unread / Reading / Read), date range. Tag filter is post-MVP.

  **Note:** Search lives inline on the Home screen (not a separate tab destination) — it appears when the user taps the Search icon in the nav bar. This wireframe covers the search-active state of the Home screen.

- [x] 🟠 **FAB-73** · [DESIGN] Wireframe Onboarding flow  `Done` `High`
  All 4 screens: Welcome, Theme Picker, Vault/Folder Setup, Quick Tour. Deliverable: low-fi wireframes for all onboarding screens. Get feedback before going hi-fi.

- [x] 🔴 **FAB-74** · [DESIGN] Set up Figma design system  `Done` `Urgent`
  Create color tokens, typography styles, and spacing components in Figma. Document naming conventions. Deliverable: organized Figma file with design tokens and auto-layout components. Foundation for all hi-fi work.

- [x] 🔴 **FAB-75** · [DESIGN] Create component variations in Figma  `Done` `Urgent`
  Build button states (default, pressed, disabled), card types, input states, tab bar, navigation bar. Deliverable: Figma components library. Ensures consistency across all screens.

- [x] 🔴 **FAB-76** · [DESIGN] Design Home/Reading List screen (all themes)  `Done` `Urgent`
  Polish wireframe into final design. Article cards with proper typography, spacing, and states. Deliverable: hi-fi Figma mockup in all 4 themes (Paper, Sepia, Night, Ink).

  **Design must include:**

  * Filter chips (All / Unread / Reading / Read) — styled consistently across all 4 themes
  * Article card status indicators for all three states (Unread, Reading, Read)
  * Empty state for each filter variant

- [x] 🔴 **FAB-77** · [DESIGN] Design Reading View (all themes)  `Done` `Urgent`
  Polished reading experience. Title, metadata, body, controls, immersive mode. Perfect spacing and typography. Deliverable: hi-fi Figma mockups in all 4 themes.

- [x] 🔴 **FAB-78** · [DESIGN] Design Settings screen (all themes)  `Done` `Urgent`
  Typography previews, theme switcher, folder management, links. Deliverable: hi-fi Figma mockup in all 4 themes.

- [x] 🟠 **FAB-79** · [DESIGN] Design Home screen — search-active state (all themes)  `Done` `High`
  Search bar active, filters, empty state, results list. Deliverable: hi-fi Figma mockup in all 4 themes (Paper, Sepia, Night, Ink).

  **Note:** Search is inline on the Home screen — not a separate destination (see site-map [FAB-60](https://linear.app/fabiosasseron/issue/FAB-60/design-define-main-screens-and-navigation-structure)). This issue covers the search-active state of the Home screen, where the search bar is focused and results are filtered in real-time.

- [x] 🟠 **FAB-80** · [DESIGN] Design Onboarding screens (all themes)  `Done` `High`
  All 4 onboarding screens in hi-fi: Welcome, Theme Picker, Folder Setup, Quick Tour. Deliverable: hi-fi Figma mockups showing the full onboarding flow.

- [x] 🟠 **FAB-81** · [DESIGN] Design all component states and variants  `Done` `High`
  Loading states, error states (parsing failed), empty states, success states. Deliverable: Figma screens showing each state variant. Prevents surprises during development.

- [x] 🟠 **FAB-82** · [DESIGN] Document all interaction specs  `Done` `High`
  Button taps, swipe gestures, animations, transitions. What happens when user taps "Save", "Delete", etc.

  Deliverable: `docs/interaction-spec.md` in the Verso repo.

  ## Document Sections

   0. Onboarding Flow (Welcome → Theme Picker → Folder Setup → Quick Tour)
   1. Interaction Principles
   2. Global Gestures & Patterns
   3. Home Screen (Search, Filter Chips, Article Cards, Empty States, Loading, Errors)
   4. Reading View (Header, Body, Bottom Bar, Font Picker, Theme Picker, Immersive Mode)
   5. Settings Screen (Theme, Typography, Folder, Links, Confirmation Dialogs)
   6. Toast Notifications (Success, Error, Warning, Undo)
   7. Component State Summary (table)
   8. Animations & Transitions (descriptive)
   9. Share Extension Flow
  10. File System Behavior

- [x] 🟡 **FAB-83** · [DESIGN] Design micro-interactions  `Done` `Medium`
  Pull-to-refresh animation, article appear/disappear, loading spinner, screen transitions. Deliverable: Figma prototypes or animation spec.

- [x] 🔴 **FAB-84** · [DESIGN] Write all UI copy and microcopy  `Done` `Urgent`
  Button labels, error messages ("Could not parse article"), empty states, onboarding text, settings labels. Deliverable: copy spreadsheet or doc with all text strings. Devs need this.

- [x] 🟠 **FAB-85** · [DESIGN] Define error states and messaging  `Done` `High`
  No internet, parsing failed, sync error, folder not found, etc. What does the user see in each case? Deliverable: error message specifications (copy + UI treatment).

- [x] 🟠 **FAB-86** · [DESIGN] Export design tokens  `Done` `High`
  Codify the design system as exportable tokens — SwiftUI constants or a JSON file the developer can use directly. Deliverable: tokens file covering colors, spacing, and typography.

- [x] 🟠 **FAB-87** · [DESIGN] Create component specifications  `Done` `High`
  For each component: anatomy, states, size specs, padding, typography, color rules. Deliverable: Figma specs page or component doc. Developers need exact dimensions.

- [x] 🔴 **FAB-88** · [DESIGN] Create design handoff spec  `Done` `Urgent`
  Comprehensive doc for the developer: design system, components, states, interactions, copy, edge cases. Deliverable: handoff doc (Markdown). Final deliverable before development begins.

- [x] 🟠 **FAB-92** · Design System Foundations — Sample/Preview File  `Done` `High`
  Create a sample Swift preview file (`DesignSystemPreview.swift`) that displays all design system foundations in one place, with a section for each of the 4 themes (Paper, Sepia, Night, Ink).

  ## Goal

  Give designers and developers a single file to visually verify the full design system — colors, typography, spacing — across all themes, without needing to navigate the app.

  ## Acceptance Criteria

  * Shows all 4 themes side by side or selectable ✓
  * Covers all color tokens (background, surface, textPrimary, textSecondary, accent, accentHover, border) ✓
  * Shows status colors (unread, reading, read) ✓
  * Covers the full type scale (XS–XXL body, H1–H4 headings, UI typography) ✓
  * Shows spacing tokens (xs, sm, md, lg, xl, xxl) ✓
  * Shows font options (New York, Georgia, SF, OpenDyslexic) ✓
  * SwiftUI Preview-compatible (`#Preview`) ✓

  ## Implementation

  File: `Verso/Sources/Design/DesignSystemPreview.swift`

  A self-contained SwiftUI view with a theme picker at the top. Selecting a theme updates all sections live. Sections: Color Tokens, Status Colors, Body Scale, Headings, UI Typography, Spacing Tokens, Typefaces. Not included in the production build — preview-only.

- [x] 🟠 **FAB-100** · Extract & fix ArticleCard component  `Done` `High`
  Create `Verso/Sources/Components/Cards/ArticleCard.swift` to replace the existing `Screens/ArticleList/ArticleCardView.swift`, aligned with the Figma `ArticleCard` component spec.

  **Figma spec:**

  * Full-width list item, all-sides padding 16pt, corner radius 12pt
  * `surface` background, **1pt** `border` stroke (currently missing)
  * Title: SF Pro Semibold 17pt `textPrimary`, 1.3× line height, max 2 lines
  * Source name: SF Pro Regular 15pt `textSecondary`, 1.4× line height
  * Date / read time: SF Pro Regular 13pt `textSecondary`
  * StatusBadge positioned top-right
  * Gap between cards: **12pt** (currently 9pt)
  * Pressed state: surface at 80% opacity

  **Tasks:**

  - [ ] Create `Components/Cards/ArticleCard.swift` with `#Preview` showing all 3 status variants
  - [ ] Add 1pt `border` stroke
  - [ ] Fix card gap to 12pt in `ArticleListView`
  - [ ] Delete `Screens/ArticleList/ArticleCardView.swift`
  - [ ] Update `ArticleListView` import

- [x] 🟠 **FAB-101** · Extract & fix SearchBar component  `Done` `High`
  Extract the inline search bar from `ArticleListView` into `Verso/Sources/Components/Inputs/SearchBar.swift`, matching the Figma `SearchBar` component.

  **Figma spec:**

  * Height 44pt, corner radius 10pt (`VersoRadius.sm`)
  * `surface` background, 1pt `border` stroke by default
  * **2pt** `accent` border when focused (currently no focus state)
  * Leading `magnifyingglass` SF Symbol in `textSecondary`
  * Trailing `xmark.circle.fill` clear button — visible **only when text is present**
  * Placeholder text in `textSecondary`, input in `textPrimary`

  **Tasks:**

  - [ ] Create `Components/Inputs/SearchBar.swift` as a standalone View with `@Binding text: String`
  - [ ] Add focused state with 2pt accent border
  - [ ] Add `#Preview` showing Default and Focused states
  - [ ] Remove inline implementation from `ArticleListView`

- [x] 🟠 **FAB-102** · Extract & fix FilterChip + FilterChipBar components  `Done` `High`
  Extract the private `FilterChip` from `FilterChipBar.swift` and move both to `Components/Inputs/`, matching the Figma spec.

  **Figma spec — FilterChip:**

  * Height 36pt, fully rounded pill (corner radius 18pt)
  * Horizontal padding 12pt (`VersoSpacing.sm`)
  * Label + count inline (e.g. "Unread 12")
  * Font: **SF Pro Semibold 15pt** — currently uses hardcoded 17pt; should use `VersoTypography.UI.button` (fix the style definition or use 15pt directly)
  * Unselected: transparent background, `textSecondary` text, 1pt `border` stroke
  * Selected: `accentSurface` background (accent at 15% opacity), `accent` text, no border
  * Zero-count chips: 50% opacity, still tappable

  **Figma spec — FilterChipBar:**

  * Horizontal scroll row, 16pt edge padding, 8pt gap between chips

  **Tasks:**

  - [ ] Create `Components/Inputs/FilterChip.swift`
  - [ ] Create `Components/Inputs/FilterChipBar.swift` (move from Screens/)
  - [ ] Fix font to 15pt (update `VersoTypography.UI.button` or use `.system(size: 15, weight: .semibold)`)
  - [ ] Delete old `Screens/ArticleList/FilterChipBar.swift`
  - [ ] Add `#Preview` showing Selected and Unselected states

- [x] 🟠 **FAB-103** · Extract StatusBadge + EmptyState components  `Done` `High`
  Extract two private components into the shared library.

  **StatusBadge** — Figma spec (`Components/Indicators/StatusBadge.swift`):

  * Unread: 12pt solid circle in `statusUnread` blue (`#4A90D9`)
  * Reading: pill (capsule) with "Reading" label in white, `statusReading` amber (`#D4A353`) background — **current implementation uses a circle for all states; needs pill for Reading/Read**
  * Read: same pill, `statusRead` green (`#5AAF7A`), "Read" label in white

  **EmptyState** — Figma spec (`Components/Cards/EmptyState.swift`):

  * Centered VStack
  * 48pt SF Symbol in `textSecondary` (doc.text.magnifyingglass for search miss, tray for empty library)
  * SF Pro Semibold 20pt headline in `textPrimary`
  * SF Pro Regular 15pt subheadline in `textSecondary`
  * 48pt vertical spacing between elements

  **Tasks:**

  - [ ] Create `Components/Indicators/StatusBadge.swift` with pill variants for Reading/Read
  - [ ] Create `Components/Cards/EmptyState.swift`
  - [ ] Add `#Preview` for all variants of each
  - [ ] Remove private implementations from `ArticleCardView` and `ArticleListView`

- [x] 🟡 **FAB-104** · Implement VersoButton component  `Done` `Medium`
  Create `Verso/Sources/Components/Buttons/VersoButton.swift` implementing all 4 Figma button styles as SwiftUI `ButtonStyle` conformances.

  **Figma spec:**

  * **Primary**: filled `accent` background, white label, height 50pt, corner radius 12pt (`VersoRadius.md`). Disabled: 40% opacity.
  * **Secondary**: `accent`-colored 1.5pt border, transparent background, `accent` label. Disabled: 40% opacity.
  * **Text**: plain label-only, `accent` color, no background/border. Min tap target 44×44pt.
  * **Icon**: 44×44pt transparent touch target, 24pt SF Symbol. Color: `textSecondary` idle / `accent` active / 60% opacity pressed / 30% opacity disabled.

  **Usage:**

  ```swift
  Button("Save") { }
    .buttonStyle(VersoButtonStyle(.primary, theme: theme))

  Button { } label: { Image(systemName: "bookmark") }
    .buttonStyle(VersoButtonStyle(.icon, theme: theme))
  ```

  **Tasks:**

  - [ ] Create `VersoButtonStyle` with `Variant` enum: `.primary`, `.secondary`, `.text`, `.icon`
  - [ ] Implement pressed and disabled states for each
  - [ ] Add `#Preview` showing all variants and states

- [x] 🟡 **FAB-105** · Implement VersoTextField component  `Done` `Medium`
  Create `Verso/Sources/Components/Inputs/VersoTextField.swift` matching the Figma `Input/Text` component.

  **Figma spec:**

  * Corner radius 10pt (`VersoRadius.sm`), `surface` background
  * Default border: 1pt `border`
  * Focused border: 2pt `accent`
  * Error border: 2pt `error` color + error message text below field in `error` color, SF Regular 13pt
  * Disabled: 40% component-level opacity
  * Height: \~48pt (padding-driven: 12pt vertical padding)

  **Usage:**

  ```swift
  VersoTextField("Email", text: $email, state: .error("Invalid email"), theme: theme)
  ```

  **Tasks:**

  - [ ] Create `VersoTextField` View with `State` enum: `.default`, `.focused`, `.error(String)`, `.disabled`
  - [ ] Implement focused state via `@FocusState`
  - [ ] Show error message below field only in `.error` state
  - [ ] Add `#Preview` showing all 4 states

- [x] 🟡 **FAB-106** · Implement ReadingChrome (TopBar + BottomBar)  `Done` `Medium`
  Create `Verso/Sources/Components/Reading/ReadingChrome.swift` with TopBar and BottomBar, matching the Figma `ReadingChrome/TopBar` and `ReadingChrome/BottomBar` components.

  **Figma spec — TopBar:**

  * Full-width, 44pt + top safe area
  * `surface` at 95% opacity background, 1pt `border` at bottom edge
  * Leading: back button (`chevron.left`, 24pt) in `accent`
  * Center: article title truncated, SF Regular 15pt `textSecondary`
  * Trailing: open-externally button (`arrow.up.right`, 24pt) in `accent`
  * **Auto-hide**: opacity 0 after 2s of no interaction (ease-out 300ms); tap to reveal (ease-in 200ms)

  **Figma spec — BottomBar:**

  * Full-width, 44pt + bottom safe area
  * `surface` at 95% opacity background, 1pt `border` at top edge
  * 5 icon buttons: font-size minus/plus, line spacing, margin, theme, mark-as-read
  * Same auto-hide behavior as TopBar

  **Tasks:**

  - [ ] Create `ReadingTopBar` and `ReadingBottomBar` views
  - [ ] Implement auto-hide/reveal with timer and tap gesture
  - [ ] Add `#Preview` for each

- [x] 🟡 **FAB-107** · Implement ReadingControls bottom sheet  `Done` `Medium`
  Create `Verso/Sources/Components/Reading/ReadingControls.swift` matching the Figma `ReadingControls` component.

  **Figma spec:**

  * Bottom sheet: 16pt corner radius on top corners, `surface` background, 1pt `border` top edge
  * Drag handle: 36×4pt pill in `border` color, centered at top
  * Padding: 20pt horizontal, 16pt top, 28pt bottom
  * **Font variant**: font-size stepper (A− / current size / A+) + line-spacing segmented control (4 icon tiles)
  * **Theme variant**: single row of 4 theme swatch tiles (32pt tall, 8pt corner radius); active tile has 2pt `accent` border, inactive has 1pt `border`; theme name at 11pt SF Regular below each tile

  **Tasks:**

  - [ ] Create `ReadingControls` view with `Variant` enum: `.font`, `.theme`
  - [ ] Implement font size stepper and line spacing selector
  - [ ] Implement theme tile row (reuse ThemeSelector if possible)
  - [ ] Add `#Preview` for both variants

- [x] 🟡 **FAB-108** · Implement ScrollProgress, ArticleHeader, ImmersiveHintPill  `Done` `Medium`
  Create three small reading-view components.

  **ScrollProgress** (`Components/Reading/ScrollProgress.swift`):

  * 3pt-tall progress bar, full width, pinned below TopBar
  * Track: `border` color. Fill: `accent` color. Grows left-to-right with `progress: Double` (0.0–1.0)

  **ArticleHeader** (`Components/Reading/ArticleHeader.swift`):

  * VStack: title (Bold 28pt `textPrimary` in user's reading font), source (SF Regular 15pt `textSecondary`), date (SF Regular 13pt `textSecondary`)
  * 24pt vertical spacing between elements

  **ImmersiveHintPill** (`Components/Reading/ImmersiveHintPill.swift`):

  * Centered pill, fully rounded (20pt radius)
  * Fixed `rgba(0,0,0,0.70)` background (intentionally not theme-aware)
  * White text "Tap anywhere to reveal", SF Regular 13pt
  * Padding: 6pt vertical, 14pt horizontal
  * Shown once; dismissed permanently on any tap

  **Tasks:**

  - [ ] Create all 3 files
  - [ ] Add `#Preview` for each

- [x] 🟡 **FAB-109** · Implement SettingsRow component  `Done` `Medium`
  Create `Verso/Sources/Components/Settings/SettingsRow.swift` matching the Figma `SettingsRow` component.

  **Figma spec:**

  * 44pt minimum height
  * **Default**: label in `textPrimary` SF Regular 17pt + trailing chevron (`chevron.right`) in `textSecondary`
  * **Folder**: label + current path value in `textSecondary` + trailing chevron
  * **Font**: font name at 17pt Semibold in its own font family, preview text "The quick brown fox..." at 15pt Regular `textSecondary`, selection dot `accent` top-right when selected; row height \~78pt
  * **Theme**: renders ThemeSelector (see separate issue); no chevron

  **Tasks:**

  - [ ] Create `SettingsRow` with `RowType` enum: `.default(label:)`, `.folder(label:, path:)`, `.font(name:, preview:, isSelected:)`, `.theme`
  - [ ] Add `#Preview` showing all 4 types

- [x] 🟡 **FAB-110** · Implement ThemeSelector component  `Done` `Medium`
  Create `Verso/Sources/Components/Settings/ThemeSelector.swift` matching the Figma `ThemeSelector` component.

  **Figma spec:**

  * Horizontal row of 4 ThemeChip tiles, one per theme (Paper, Sepia, Night, Ink)
  * Each chip: 80pt wide × 100pt tall, \~12.7pt gap between chips
  * Chip contains: 32pt-tall color rectangle (8pt corner radius) with the theme's swatch color (hardcoded — all 4 are shown simultaneously, so they can't use variables), theme name at 11pt SF Regular below
  * Swatch colors: Paper `#F5F0E8`, Sepia `#F2E8D5`, Night `#1C1A16`, Ink `#111418`
  * Selected chip: 2pt `accent` border
  * Unselected chip: 1pt `border` stroke

  **Note:** The existing `ThemeCard` in `ContentView.swift` is similar but not spec-compliant. This new component should replace it.

  **Tasks:**

  - [ ] Create `ThemeSelector` view with `@Binding selectedTheme: VersoTheme`
  - [ ] Create `ThemeChip` subview matching spec dimensions
  - [ ] Add `#Preview`
  - [ ] Update `ContentView.swift` to use `ThemeSelector` instead of `ThemeCard`

- [x] 🔵 **FAB-111** · Implement LoadingState skeleton component  `Done` `Low`
  Create `Verso/Sources/Components/Cards/LoadingState.swift` matching the Figma `LoadingState` composite component.

  **Figma spec:**

  * 5 skeleton ArticleCard-shaped placeholders
  * Each has 3 shimmer blocks: 75% / 40% / 25% of card width
  * Fill: `placeholder` token
  * Shimmer overlay: `textSecondary` at 30% opacity, left-to-right animation
  * Shimmer duration: 1.5s, linear, repeating forever

  **Tasks:**

  - [ ] Create `LoadingState` view with 5 `SkeletonCard` instances
  - [ ] Implement shimmer animation with `withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false))`
  - [ ] Use `placeholder` and `textSecondary` tokens
  - [ ] Add `#Preview`

- [x] 🟠 **FAB-115** · [DESIGN] Design app icon in Figma  `Done` `High`
  ## Context

  Verso has no app icon yet. The icon is the first impression of the app — it should communicate the core idea (reading, minimalism, calm focus) and feel at home alongside other reading apps on the iOS home screen.

  ## Design brief

  * **Style:** Minimal, flat or subtly textured. No 3D. No gradients unless very subtle.
  * **Concept directions to explore:** A stylised open book, a reading light, a clean letterform (V), a stack of pages, or an abstract mark that evokes a calm reading session.
  * **Colour:** Should work well with the Paper theme palette (warm beige/brown tones) as the default. Consider how it looks in both light and dark home screen contexts.
  * **Feel:** Warm, focused, premium — consistent with the Verso design language.

  ## Deliverables in Figma

  - [ ] At least 2–3 icon concept directions explored
  - [ ] Final icon design at 1024×1024pt on the 🧩 Components page (or a dedicated Icon page)
  - [ ] Icon shown at small sizes (60pt, 29pt) to verify legibility at scale
  - [ ] Icon shown on a realistic home screen mockup (light and dark wallpaper)
  - [ ] Save a named Figma version after approval: `v1.x — App icon approved`

  ## Reference

  * Apple HIG: [https://developer.apple.com/design/human-interface-guidelines/app-icons](<https://developer.apple.com/design/human-interface-guidelines/app-icons>)
  * iOS icon size: 1024×1024px export for App Store Connect; Xcode generates all other sizes from this via asset catalog

- [x] 🟡 **FAB-129** · [DESIGN+DEV] Add static iOS launch screen (LaunchScreen.storyboard)  `Done` `Medium`
  Add a static launch screen that iOS displays before the app process fully starts.

  ## Context

  This is distinct from [FAB-128](https://linear.app/fabiosasseron/issue/FAB-128/setup-implement-launch-loading-screen) (in-app loading state). The system-managed launch screen appears the instant the user taps the app icon — before SwiftUI loads, before UserDefaults is read. It must be a static storyboard; no code runs.

  ## Design

  * Centered wordmark or app icon on a neutral background (Paper theme background `#F5F0E8` is a safe default — light, on-brand)
  * Keep it visually consistent with the app's first screen so the transition feels seamless
  * Save a version to Figma version history when the design is finalised

  ## Implementation

  1. Add `LaunchScreen.storyboard` to `Verso/Sources/App/` (or a dedicated `Resources/` folder)
  2. Set a `UIImageView` with the wordmark/icon, centred with Auto Layout constraints
  3. Set the background colour to match Paper theme (`#F5F0E8`)
  4. Reference it in `project.yml` under `info` → `UILaunchStoryboardName: LaunchScreen`
  5. Run `xcodegen generate` and verify in Xcode that the launch screen previews correctly
  6. Test on a real device — simulators sometimes cache the old launch screen; reset if needed

  ## Acceptance criteria

  - [ ] Launch screen appears immediately on cold launch with no white flash
  - [ ] Transitions smoothly into the in-app loading state ([FAB-128](https://linear.app/fabiosasseron/issue/FAB-128/setup-implement-launch-loading-screen))
  - [ ] Works on all supported device sizes (iPhone SE through Pro Max)
  - [ ] No Xcode validation warnings about the storyboard


### Phase 2 — Experience

- [x] 🟠 **FAB-133** · Share Extension not appearing in Safari  `Done` `High`
  The Verso Share Extension does not show up in Safari's share sheet, making it impossible to save articles directly from the browser.

  ## Steps to reproduce

  1. Open a web article in Safari
  2. Tap the Share button
  3. Look for Verso in the share sheet

  ## Expected

  Verso appears as a share destination in the sheet.

  ## Actual

  Verso is not listed.

- [x] 🟡 **FAB-134** · Replace "Cancel" text label with icon on all sheets and panels  `Done` `Medium`
  All bottom sheets and modal panels currently show a "Cancel" text label as the dismiss button. This should be replaced with an icon (e.g. `xmark`) to keep the UI minimal and consistent.

  Affects all panels/sheets in the app.

- [x] 🟡 **FAB-136** · Settings font selector: fix dot vertical alignment and add OpenDyslexic  `Done` `Medium`
  Two issues with the font picker in the Settings panel:

  1. **Selection dot misaligned** — the dot indicating the currently selected font is not vertically centered on the card height.
  2. **OpenDyslexic missing** — OpenDyslexic is not listed as an option in the font picker even though it should be available.

- [x] 🟡 **FAB-137** · Version 1.0 and Privacy Policy links are broken in Settings  `Done` `Medium`
  Tapping the "Version 1.0" and "Privacy Policy" links in the Settings panel does nothing. Both links should navigate to their respective destinations.

- [x] 🟡 **FAB-138** · Empty article list: center icon and message vertically and horizontally  `Done` `Medium`
  When the article list is empty, the placeholder icon and message are not centered in the screen. They should be centered both horizontally and vertically within the available space.

- [x] 🟠 **FAB-139** · Read status indicator not updating after finishing an article  `Done` `High`
  After reading an article to completion, the status indicator remains blue (Unread) instead of transitioning to green (Read). The article status lifecycle (Unread → Reading → Read) is not being reflected in the UI.

  ## Steps to reproduce

  1. Open an unread article
  2. Scroll to the end
  3. Return to the article list

  ## Expected

  Indicator turns green (Read).

  ## Actual

  Indicator stays blue (Unread).

- [x] 🟠 **FAB-141** · Article view bottom bar clipped — needs more bottom padding  `Done` `High`
  The bottom action bar in the Article reading view sits too close to the bottom edge of the screen. Buttons are nearly clipped, especially on devices with a home indicator. Increase the bottom padding so buttons are comfortably above the safe area.

- [x] 🟠 **FAB-142** · Reading progress bar not updating on scroll in Article view  `Done` `High`
  The progress bar in the Article reading view does not update as the user scrolls through the article. It should reflect the current scroll position as a percentage of total content read.

- [x] 🟡 **FAB-143** · Article view panels have unwanted bottom margin  `Done` `Medium`
  Both the font size + line spacing panel and the theme picker panel in the Article reading view display an extra bottom margin that should not be there. This creates visual dead space at the bottom of the sheets.

  Affects:

  * Font size / line spacing panel
  * Theme picker panel

- [x] 🟡 **FAB-144** · Show author name (or site name) below article title instead of URL  `Done` `Medium`
  Below the article title in the Article reading view, the app currently shows the raw website URL. This should instead show:

  1. The author's name, if available in the article metadata.
  2. The website/publication name as a fallback if the author is not available.

  The raw URL should not be shown to the user.

- [x] 🟠 **FAB-145** · Unify toolbar button style across the entire app  `Done` `High`
  Toolbar buttons are visually inconsistent between views. The "Add" and "Settings" buttons on the Article list view look different from the "Back", "Open URL", "Font settings", "TTS", and "Theme settings" buttons in the Article reading view.

  All toolbar buttons should use the same visual style as the "Add" and "Settings" buttons (the reference style).

- [x] 🔵 **FAB-146** · Remove chevron from article list cards  `Done` `Low`
  Each article card in the article list shows a disclosure chevron (›) on the right side. Since the entire card is tappable and the navigation destination is obvious, the chevron adds visual noise without value. Remove it.

- [x] 🟠 **FAB-147** · Loading screen not showing on app launch  `Done` `High`
  The loading/launch screen is not displayed when opening the app. The app either goes directly to the main view or shows a blank screen during startup.

  ## Expected

  The loading screen is shown while the app initializes.

  ## Actual

  Loading screen is skipped entirely on launch.

- [x] 🔴 **FAB-148** · Article content shows "Loading…" and never renders  `Done` `Urgent`
  Opening an article shows "Loading…" indefinitely — the markdown content never renders.

  ## Root cause

  `ArticleReaderView.loadContent()` reads the article file without first calling `startAccessingSecurityScopedResource()` on the iCloud Drive bookmark URL. The file read silently fails and `parsedContent` stays empty, leaving the view stuck on the loading placeholder.

  This is the same class of bug fixed in commit `126b990` for *writing* (`AddArticleView`, `PendingArticleIngester`), but the *reading* path was not covered.

  ## Fix

  Wrap the file read in `ArticleReaderView.loadContent()` with security-scoped access, following the pattern already used in `ImportOrchestrator`:

  ```swift
  private func loadContent() {
      let filePath = article.filePath
      guard !filePath.isEmpty else { return }
      let fileURL = URL(fileURLWithPath: filePath)
      // Retrieve the bookmark URL for the iCloud folder
      guard let folderURL = FolderBookmarkService.shared.resolvedURL() else { return }
      folderURL.startAccessingSecurityScopedResource()
      defer { folderURL.stopAccessingSecurityScopedResource() }
      if let parsed = try? MarkdownReader.read(fileURL: fileURL) {
          parsedContent = parsed.contentMarkdown
      }
  }
  ```

  ## Pattern to follow going forward

  Any file I/O against the user's iCloud Drive folder — read **or** write — must be wrapped with `startAccessingSecurityScopedResource()` / `stopAccessingSecurityScopedResource()` on the security-scoped bookmark URL. See `ImportOrchestrator` as the canonical reference implementation.

- [x] 🟡 **FAB-149** · Status badge missing icon — shows color only  `Done` `Medium`
  The article status badge renders only the colored dot/pill with no icon inside. Per the Figma design, each status should display an icon alongside (or inside) the color indicator.

  ## Reference

  [Figma – StatusBadge component](<https://www.figma.com/design/WCPHZNg1my8VSSMbLO5bvX/Reader-UI?node-id=30-656&t=Q0givZ15J4XWmw24-11>)

  ## Expected

  Each status badge shows its corresponding icon:

  * Unread → e.g. circle / bookmark icon
  * Reading → e.g. book / open-book icon
  * Read → e.g. checkmark icon

  ## Actual

  Only the badge color is shown; no icon is rendered.


## Infra / Docs

### Phase 1 — Foundation

- [x] 🔴 **FAB-5** · [SETUP] Review and finalize Xcode project configuration  `Done` `Urgent`
  ## Context

  The Xcode project was bootstrapped via XcodeGen (`project.yml` + `Verso.xcodeproj`). Before implementation begins, verify that the project configuration is complete and correct.

  ## Checklist

  - [X] Open `Verso.xcodeproj` in Xcode and confirm it builds cleanly on a simulator
  - [X] Verify bundle ID is `com.fabiosasseron.verso`
  - [X] Confirm iOS 16+ deployment target is set
  - [X] Confirm `Sources/` folder structure matches `project.yml`
  - [X] Run `xcodegen generate` to ensure project file is up to date with `project.yml`
  - [X] Confirm signing & capabilities are set (personal team is fine for now)

  ## Notes

  Do NOT configure iCloud entitlement here — that is [whysasse/verso-app#2](https://linear.app/fabiosasseron/issue/FAB-6/setup-configure-icloud-drive-entitlement).

  ## Completed Work

  * Fixed missing `GENERATE_INFOPLIST_FILE: YES` setting in `project.yml`

- [x] 🔵 **FAB-8** · Add GitHub Actions CI (build-only)  `Done` `Low`
  `.github/workflows/ci.yml` — builds the `Verso` scheme unsigned on every push/PR to `main` (XcodeGen generate → xcodebuild, `CODE_SIGNING_ALLOWED=NO`).

  Originally attempted on `claude/exciting-engelbart-6294a1` (2026-05-09), which debugged the destination/simulator/asset-catalog issues but was never merged and went untracked after the Linear migration. Rebuilt fresh against the current project structure rather than resurrected — that branch predated most of the current app and could not be merged as-is. Reused its proven `platform=macOS,variant=Designed for iPad` + `CODE_SIGNING_ALLOWED=NO` combination, verified locally against a truly fresh checkout (no `Secrets.xcconfig`, no `.xcodeproj`) before landing. Completed 2026-08-02.

  Build-only for now — does not run `VersoTests`. A follow-up to add test execution would need its own simulator-availability investigation.
  * Fixed typo in `ContentView.swift`: `VerseTheme` → `VersoTheme`
  * Successfully built project for iPhone 17 simulator (iOS 16.0+)
  * Verified all source files are properly referenced in the Xcode project

- [x] 🔴 **FAB-6** · [SETUP] Configure iCloud Drive entitlement  `Done` `Urgent`
  Enable iCloud Documents capability in Xcode. Add NSUbiquitousContainers to Info.plist. Confirm the app can read/write to a user-selected iCloud Drive folder via UIDocumentPickerViewController.

- [x] 🔴 **FAB-7** · [SETUP] Add Share Extension target  `Done` `Urgent`
  Add a new Share Extension target to the project. Bundle ID: com.fabiosasseron.verso.ShareExtension. Configure App Group so the extension can communicate with the main app.

- [x] 🔴 **FAB-94** · [SETUP] Initialize local git repository and push to GitHub  `Done` `Urgent`
  ## Context

  The GitHub repo already exists at [https://github.com/whysasse/verso-app](<https://github.com/whysasse/verso-app>). The local project folder (`/Users/fabiosasseron/Claude/reader/`) has never been committed to git. This must be done before any implementation work begins.

  ## Steps

  1. `cd /Users/fabiosasseron/Claude/reader`
  2. Create a `.gitignore` for Xcode/Swift — use [https://github.com/github/gitignore/blob/main/Swift.gitignore](<https://github.com/github/gitignore/blob/main/Swift.gitignore>) as reference
  3. [`git init`](<https://github.com/github/gitignore/blob/main/Swift.gitignore>)
  4. `git remote add origin https://github.com/whysasse/verso-app.git`
  5. `git add .`
  6. `git commit -m "chore: initial commit — design system and project scaffold"`
  7. `git push -u origin main`

  ## Done when

  * `git status` is clean
  * The full `Verso/` folder, `docs/`, and `CLAUDE.md` are visible on [https://github.com/whysasse/verso-app](<https://github.com/whysasse/verso-app>)

- [x] 🟠 **FAB-95** · [WORKFLOW] Save Figma version to version history — design phase complete  `Done` `High`
  ## Context

  Before switching from design to implementation, save a named version in Figma's version history so the full design phase is permanently checkpointed.

  ## Steps

  1. Open the Verso Figma file: [https://www.figma.com/design/WCPHZNg1my8VSSMbLO5bvX/Reader-UI](<https://www.figma.com/design/WCPHZNg1my8VSSMbLO5bvX/Reader-UI>)
  2. File menu → **Save to version history**
  3. Name it: `v1.0 — Design phase complete (pre-implementation)`
  4. Add a description: "All screens designed across 4 themes. Component library complete. Interaction specs documented."

  ## Do this after

  All remaining \[DESIGN\] Todo issues are complete ([FAB-83](https://linear.app/fabiosasseron/issue/FAB-83/design-design-micro-interactions), [FAB-84](https://linear.app/fabiosasseron/issue/FAB-84/design-write-all-ui-copy-and-microcopy), [FAB-85](https://linear.app/fabiosasseron/issue/FAB-85/design-define-error-states-and-messaging), [FAB-86](https://linear.app/fabiosasseron/issue/FAB-86/design-export-design-tokens), [FAB-87](https://linear.app/fabiosasseron/issue/FAB-87/design-create-component-specifications), [FAB-88](https://linear.app/fabiosasseron/issue/FAB-88/design-create-design-handoff-spec), [FAB-89](https://linear.app/fabiosasseron/issue/FAB-89/define-analytics-strategy-and-key-metrics-for-ux-decision-making)).

- [x] 🟠 **FAB-96** · [WORKFLOW] Push to GitHub — save loop complete  `Done` `High`
  ## When to do this

  After completing Phase 3 (Share Extension + parsing). At this point, articles can be saved from any app into Verso — the core save loop works.

  ## Steps

  ```bash
  git add .
  git commit -m "feat: share extension and parsing — save loop complete"
  git push
  ```

  ## Done when

  * GitHub shows the latest commit
  * `git status` is clean

  ## Completes after

  [FAB-14](https://linear.app/fabiosasseron/issue/FAB-14/parsing-bundle-readabilityjs-in-app), [FAB-15](https://linear.app/fabiosasseron/issue/FAB-15/parsing-implement-swiftsoup-fallback-parser), [FAB-17](https://linear.app/fabiosasseron/issue/FAB-17/share-ext-implement-url-capture-in-share-extension), [FAB-18](https://linear.app/fabiosasseron/issue/FAB-18/share-ext-implement-background-parsing-from-share-extension), [FAB-19](https://linear.app/fabiosasseron/issue/FAB-19/share-ext-implement-share-extension-ui)

- [x] 🟠 **FAB-97** · [WORKFLOW] Push to GitHub — first complete user loop  `Done` `High`
  ## When to do this

  After completing Phase 5 (Reading View). At this point the full core user loop is working: **save article → see it in the list → read it**.

  ## Steps

  ```bash
  git add .
  git commit -m "feat: reading view — first complete user loop (save → list → read)"
  git push
  ```

  ## Done when

  * GitHub shows the latest commit
  * `git status` is clean

  ## Completes after

  [FAB-27](https://linear.app/fabiosasseron/issue/FAB-27/reading-implement-reading-view-container), [FAB-29](https://linear.app/fabiosasseron/issue/FAB-29/reading-implement-markdown-body-renderer), [FAB-28](https://linear.app/fabiosasseron/issue/FAB-28/reading-implement-article-header), [FAB-30](https://linear.app/fabiosasseron/issue/FAB-30/reading-implement-immersive-reading-mode), [FAB-31](https://linear.app/fabiosasseron/issue/FAB-31/reading-implement-bottom-reading-controls), [FAB-32](https://linear.app/fabiosasseron/issue/FAB-32/reading-implement-font-size-control), [FAB-33](https://linear.app/fabiosasseron/issue/FAB-33/reading-implement-font-selection)

- [x] 🟡 **FAB-98** · [WORKFLOW] Push to GitHub — MVP feature-complete  `Done` `Medium`
  ## When to do this

  After completing Phase 10 (Settings). All MVP features are built: themes, TTS, onboarding, settings, and the full reading experience.

  ## Steps

  ```bash
  git add .
  git commit -m "feat: MVP feature-complete — all Phase 1 issues done"
  git push
  ```

  ## Done when

  * GitHub shows the latest commit
  * `git status` is clean

  ## Completes after

  [FAB-47](https://linear.app/fabiosasseron/issue/FAB-47/settings-implement-settings-screen), [FAB-48](https://linear.app/fabiosasseron/issue/FAB-48/settings-implement-folder-management), [FAB-49](https://linear.app/fabiosasseron/issue/FAB-49/settings-implement-about-section)


### Phase 2 — Experience

- [x] 🟡 **FAB-89** · Define analytics strategy and key metrics for UX decision-making  `Done` `Medium`
  ## Overview

  Define what Verso should measure, why, and how — before development begins. The goal is not to implement analytics now, but to lock in the questions we want to answer so that instrumentation can be wired in during development, not bolted on afterward.

  ## Constraints

  Verso has no user accounts and no backend. All analytics must be **on-device and privacy-respecting**. This is consistent with the app's local-first, no-account positioning.

  ## Recommended tooling

  * **Apple App Store Connect** — free baseline: downloads, active devices, sessions, crash rate, retention. No SDK needed.
  * **TelemetryDeck** — privacy-first SDK popular in indie iOS apps. No personal data, no IP addresses, GDPR-compliant. Free up to a meaningful signal volume. Best fit for Verso's ethos.

  ## Key questions to answer (proposed)

  1. Are people returning to read, or is this a save-and-forget app? *(return rate, session frequency)*
  2. Are articles being read or just saved? *(save vs. open vs. read-completion ratio)*
  3. Is the Obsidian/vault integration being used? *(folder setup completion in onboarding)*
  4. Are articles failing to parse at a meaningful rate? *(Readability.js + SwiftSoup failure events)*
  5. Which themes and fonts are actually used? *(feature adoption — informs future simplification)*
  6. Is immersive reading mode being discovered and used? *(feature discoverability)*

  ## Proposed events to track (TelemetryDeck)

  | Event | Purpose |
  | -- | -- |
  | `article.saved` | Core loop starts |
  | `article.opened` | Intent to read |
  | `article.readCompleted` | Core loop fulfilled |
  | `article.parseFailed` | Error detection |
  | `onboarding.stepCompleted` (with step param) | Drop-off analysis |
  | `onboarding.vaultSetupCompleted` | Obsidian integration adoption |
  | `settings.themeChanged` | Feature adoption |
  | `settings.fontChanged` | Feature adoption |
  | `reader.immersiveModeToggled` | Feature discoverability |
  | `shareExtension.used` | Entry point tracking |

  ## Next steps

  - [ ] Confirm analytics are aligned with the app's privacy positioning (decide if opt-in or always-on)
  - [ ] Add TelemetryDeck SDK integration to the dev backlog
  - [ ] Finalize event list before development of each feature begins
  - [ ] Consider surfacing a brief "share anonymous usage data" consent in onboarding

- [x] 🟠 **FAB-120** · Add TelemetryDeck SDK and AnalyticsService  `Done` `High`
  Add the TelemetryDeck Swift SDK and the `AnalyticsService` wrapper that all event instrumentation will go through.

  ## Tasks

  * Add TelemetryDeck to `project.yml` under `packages`:

    ```yaml
    TelemetryClient:
      url: https://github.com/TelemetryDeck/SwiftClient.git
      from: "2.0.0"
    ```
  * Run `xcodegen generate` to regenerate the Xcode project
  * Create `Verso/Sources/Services/AnalyticsService.swift`:
    * Singleton (`AnalyticsService.shared`)
    * `func track(_ event: String, parameters: [String: String] = [:])`
    * Reads `UserDefaults` key `verso.analytics.optIn` before sending
    * Wraps `TelemetryManager.send()`
  * Initialize TelemetryDeck in `VersoApp.swift` on launch (only if opt-in is true)

  ## Reference

  See `docs/ANALYTICS_STRATEGY.md` → Implementation Notes for full details.

- [x] 🟠 **FAB-121** · Add analytics opt-in consent step to onboarding  `Done` `High`
  Add a consent prompt as the final step of onboarding that lets users opt in to anonymous analytics.

  ## UI

  * Headline: "Help make Verso better"
  * Body: "Share anonymous usage data — no personal info, no article content, ever."
  * Primary button: "Sure, why not" → sets `UserDefaults` key `verso.analytics.optIn = true`
  * Secondary button: "No thanks" → leaves key `false` (default)

  ## Placement

  After the folder picker step in `OnboardingView`, before the done/completion screen.

  ## Reference

  See `docs/ANALYTICS_STRATEGY.md` → Consent UI for full details.

- [x] 🟡 **FAB-122** · Add analytics opt-in toggle to Settings screen  `Done` `Medium`
  Add a "Share anonymous data" toggle to the Settings screen so users can change their analytics opt-in preference after onboarding.

  ## Details

  * Label: "Share anonymous data"
  * Sublabel: "No personal info or article content, ever."
  * Bound to `UserDefaults` key `verso.analytics.optIn`
  * Place in a "Privacy" section in `SettingsView`

  ## Reference

  See `docs/ANALYTICS_STRATEGY.md` → Opt-in preference key.

- [x] 🟡 **FAB-123** · Instrument article save/open/read-completed events  `Done` `Medium`
  Wire the core article loop events via `AnalyticsService.shared.track(...)`.

  ## Events

  | Event | Where to call | Parameters |
  | -- | -- | -- |
  | `article.saved` | `ArticleLibraryService` save method | `source: "share_extension" \| "in_app"` |
  | `article.opened` | Article list tap → reading view transition | — |
  | `article.readCompleted` | Scroll-based status → `.read` transition | — |

  ## Reference

  See `docs/ANALYTICS_STRATEGY.md` → Event Catalog.

- [x] 🟡 **FAB-124** · Instrument article parse failure event  `Done` `Medium`
  Wire `article.parseFailed` in `ArticleParserService` when parsing fails.

  ## Event

  | Event | Where | Parameters |
  | -- | -- | -- |
  | `article.parseFailed` | `ArticleParserService` catch/error path | `errorType: String` (from `ArticleParsingError` enum case name) |

  ## Reference

  See `docs/ANALYTICS_STRATEGY.md` → Event Catalog.

- [x] 🟡 **FAB-125** · Instrument onboarding step and vault setup events  `Done` `Medium`
  Wire onboarding analytics events in `OnboardingView`.

  ## Events

  | Event | When | Parameters |
  | -- | -- | -- |
  | `onboarding.stepCompleted` | Each step advances | `step: "welcome" \| "folder_picker" \| "done"` |
  | `onboarding.vaultSetupCompleted` | User selects a folder successfully | — |

  ## Reference

  See `docs/ANALYTICS_STRATEGY.md` → Event Catalog.

- [x] 🔵 **FAB-126** · Instrument theme and font change events  `Done` `Low`
  Wire settings adoption events when the user changes theme or font.

  ## Events

  | Event | Where | Parameters |
  | -- | -- | -- |
  | `settings.themeChanged` | `ThemeManager` theme setter | `theme: "paper" \| "sepia" \| "night" \| "ink"` |
  | `settings.fontChanged` | `ReadingPreferencesService` font setter | `font: String` (font family name) |

  ## Reference

  See `docs/ANALYTICS_STRATEGY.md` → Event Catalog.

- [x] 🔵 **FAB-127** · Instrument immersive mode toggle event  `Done` `Low`
  Wire the immersive mode discoverability event in the reading view.

  ## Event

  | Event | Where | Parameters |
  | -- | -- | -- |
  | `reader.immersiveModeToggled` | Reading view immersive mode toggle action | `enabled: "true" \| "false"` |

  ## Reference

  See `docs/ANALYTICS_STRATEGY.md` → Event Catalog.

- [x] 🔴 **FAB-282** · `L10n.swift` not registered in any Xcode target — localization epic doesn't compile  `Done` `Urgent`
  `Verso/Generated/L10n.swift` was missing from `project.yml` (XcodeGen config) — had zero entries in the generated `.xcodeproj`. Added `- Generated` to both `Verso` and `ShareExtension` target source lists, regenerated with XcodeGen, and verified both targets build clean. Also wired `ShareView.swift` to `L10n.*`, replacing all hardcoded strings.

  **Fix:** `project.yml` → added `Generated` dir to both targets; `ShareView.swift` → replaced 10 hardcoded strings with `L10n.Share.*` and `L10n.AddArticle.savingMessage` accessors.

  **Completed:** 2026-06-20.

- [x] 🟠 **FAB-276** · L10n 1 · Finalize localization strategy & decisions doc  `Done` `High`
  **Foundation — blocks the string/infra work** ([FAB-275](https://linear.app/fabiosasseron/issue/FAB-275/localization-en-ca-fr-ca-pt-br-epic) epic, step 1).

  `docs/LOCALIZATION.md` reviewed and ratified against the acceptance checklist:

  - [x] Locale set confirmed: `en` base, `en-CA` aliases `en`, `fr-CA` + `pt-BR` full. No RTL.
  - [x] CLDR plural categories confirmed (FR: 0 = singular; PT-BR: 0 = plural).
  - [x] Invariant-terms list and the `[Your Name]` iCloud exception locked.
  - [x] Theme-label translations and per-locale font-preview strings confirmed.
  - [x] `WPM = 220` and locale-aware (medium) date policy confirmed — cross-checked against code: `ReadingEstimate.swift` already centralizes `WPM = 220`; `TTSService.swift` already selects voice by content language. One drift found and fixed in the same pass: `ArticleHeader.swift` used `DateFormatter.dateStyle = .long` instead of the spec's `.medium` — corrected.

  **Completed:** 2026-06-17. `docs/LOCALIZATION.md` bumped to v1.1, marked ratified, and its stale "Linear backlog" reference updated to point at `docs/BACKLOG.md` (Linear retired 2026-06-12). Already linked from `docs/HANDOFF.md`.

  ## Unblocks

  Step 3 of the localization epic (shared platform-neutral string source).

- [x] 🟡 **FAB-279** · Rebuild AboutView.swift to match UI_COPY.md §6 spec  `Done` `Medium`
  Restructured AboutView per spec: nav title "About Verso", Version row with `{version} ({build})` sub-label, Open-source acknowledgements row pushing to new `AcknowledgementsView`, View on GitHub row, Privacy policy row, and "Verso {version} · Built with care" footer. Retired the interim keys (`about.navTitle`, `about.brandName`, `about.versionLabel`, `about.description`, `about.githubLinkLabel`, `about.privacyPolicyLinkLabel`). New `AcknowledgementsView.swift` lists SwiftSoup, TelemetryClient, and Readability.js with their licenses.

  **Completed:** 2026-06-21.

- [x] 🔵 **FAB-280** · Add Obsidian tip to OnboardingFolderPickerView  `Done` `Low`
  Added `L10n.Onboarding.folderObsidianTip` below the folder-picker row in `OnboardingFolderPickerView.swift`.

  **Completed:** 2026-06-21.

- [x] 🟡 **FAB-281** · Reconcile QuickTourView.swift with UI_COPY.md §1 OB-4 spec  `Done` `Medium`
  Rebuilt `QuickTourView.swift` as a 3-step TabView carousel with Skip button, step page dots, and per-step SF Symbol illustrations. Wired to spec keys (`onboarding.tour.headline`, `step1`–`step3`, `skip`, `startReading`). Retired the interim illustration keys (`onboarding.tour.illustration*`).

  **Completed:** 2026-06-21.

- [x] 🟢 **FAB-283** · Wire `OnboardingThemePickerView.swift` hardcoded strings to `L10n.*`  `Done` `Low`
  Replaced 3 hardcoded strings (`Text("Choose your theme")`, `Text("You can always change this later in Settings.")`, `Button("Continue")`) with `L10n.Onboarding.themeHeadline`, `themeSubheadline`, `themeContinue`.

  **Completed:** 2026-06-21.

## Phase B — Pseudolocalization & layout flex QA (FAB-275 step 6)

- [x] 🟢 **FAB-275 step 6** · Web pseudo-locale generation script & infrastructure  `Done` `Low`
  Created `docs/copy/codegen/pseudolocalize.py` that transforms `en.json` into `verso-web/messages/pseudo.json` with accented characters, ~30% vowel lengthening, and bracket wrapping for visual truncation detection. ICU MessageFormat plurals are preserved verbatim. Added `"pseudo"` to `SUPPORTED_LOCALES` in `verso-web/i18n/request.ts` and `VersoLocale` type in `LocaleProvider.tsx`. Pseudo-locale is opt-in via setting the `verso-locale=pseudo` cookie — never returned from `navigator.language`. Build verified clean.

  **Completed:** 2026-06-21.

- [x] 🟢 **FAB-275 step 6** · Fix ControlRow label clipping in Web reader controls  `Done` `Low`
  The `ControlRow` component in `verso-web/app/article/[id]/page.tsx` had a hard-coded `width: 52px` on its label span, which clipped pseudo-localized text (e.g. `[Tëëxt sïïzë]` at ~82px). Changed to `minWidth: 52` with `whiteSpace: "nowrap"` so labels expand naturally while preserving minimum alignment for short English labels.

  **Completed:** 2026-06-21.

- [x] 🟢 **FAB-275 step 6** · Document iOS pseudolocalization testing workflow  `Done` `Low`
  Added detailed instructions to `docs/LOCALIZATION.md` §7 covering both Web (cookie-based `pseudo.json`) and iOS (Xcode scheme → Run → Options → Double-Length Pseudolanguage) pseudolocalization workflows. Documents the ControlRow label fix as reference for future truncation audits.

  **Completed:** 2026-06-21.

## Localization — FAB-275 epic closeout

- [x] 🟠 **FAB-275** · Localization: EN-CA, FR-CA, PT-BR (epic)  `Done` `High`
  Shipped Verso in **EN-CA, FR-CA, and PT-BR** across iOS and Web.

  Strategy and all decisions are documented in `docs/LOCALIZATION.md`; English base copy lives in `docs/copy/UI_COPY.md`.

  **Key decisions (**`docs/LOCALIZATION.md`**):** `en-CA` aliases `en` (no separate bundle); plurals via CLDR (FR treats 0 as singular, PT-BR treats 0 as plural); theme *labels* translated but enum keys kept; per-locale font preview; no RTL.

  ---

  ### Ordered backlog (all steps complete)

  - [x] **1 · Strategy & decisions doc** → [FAB-276](#) above. Ratified `docs/LOCALIZATION.md`; linked from `HANDOFF.md`. — **Done 2026-06-17.**
  - [x] **2 · Locale-aware formatting** (dates, reading-time, TTS voice), iOS + Web. `WPM = 220` centralized in `ReadingEstimate.swift`; TTS voice follows content language in `TTSService.swift`; date style corrected `.long` → `.medium` in `ArticleHeader.swift`. — **Done 2026-06-21.**
  - [x] **3 · Shared, platform-neutral string source.** `docs/copy/UI_COPY.md` carries full `en`/`fr-CA`/`pt-BR` columns for all ~262 keys; `docs/copy/codegen/generate.py` generates `Localizable.xcstrings` + `L10n.swift` from it (verified zero drift on regeneration). — **Done 2026-06-21.**
  - [x] **4 · iOS i18n infrastructure.** `Localizable.xcstrings` + `L10n.swift` generated and registered in `project.yml` for `Verso` and `ShareExtension` targets (see FAB-282 above); ~20 views wired to `L10n.*`; CLDR plural variants encoded for the 7 true-plural keys. — **Done 2026-06-21.**
  - [x] **5 · Web i18n infrastructure.** `next-intl` installed (cookie-based locale); `LocaleProvider` mirrors `ThemeProvider`; `generate.py` also emits `verso-web/messages/{en,fr-CA,pt-BR}.json`; all Web components wired to `useTranslations`, zero hardcoded UI strings. Two spots where Web hardcoded `en-CA` for dates regardless of active UI locale (`ArticleCard.tsx`, `article/[id]/page.tsx`) fixed to be locale-aware via `Intl.DateTimeFormat`. `npm run build` verified clean. — **Done 2026-06-21.**
  - [x] **6 · Pseudolocalization + layout flex QA.** See "Phase B — Pseudolocalization & layout flex QA" above. — **Done 2026-06-21.**
  - [x] **7 · FR-CA & PT-BR translation + linguistic/diacritic QA.** Fabio reviewed and approved both `docs/copy/UI_COPY_LINGUISTIC_REVIEW_fr-CA.md` (no corrections) and `..._pt-BR.md` (one correction: `readerSettings.fontSize.xxl` pt-BR abbreviation changed from `EEG` — collided with the medical abbreviation for electroencephalogram — to `GGG`). Applied to `docs/copy/UI_COPY.md`; regenerated `Localizable.xcstrings`/`L10n.swift`/`verso-web/messages/*.json` with zero drift otherwise. — **Done 2026-08-25.**
  - [x] **8 · App Store metadata + Québec/Bill 96.** fr-CA/pt-BR listing text drafted (`docs/APP_STORE_LISTING_LOCALIZED.md`), reviewed and approved by Fabio, and pasted into App Store Connect 2026-08-25. ASC "Name" field decided: `Verso Reader`, everywhere, no per-locale variation. Bill 96 compliance posture decided by Fabio: the existing complete fr-CA in-app translation is treated as sufficient for now — a provisional, risk-accepted call, not a formal legal clearance; revisit if this ever becomes higher-stakes. — **Done 2026-08-25.**

  **Completed:** 2026-08-25. FAB-284 (language picker, a separate follow-up issue — see below) shipped 2026-08-28.

- [x] 🟢 **FAB-284** · Language picker (iOS + Web)  `Done` `Low`
  Explicit override so a user can pick `en` / `fr-CA` / `pt-BR` regardless of device/browser language, instead of relying solely on auto-detection.

  **UX decisions (Fabio, 2026-08-28):** new **General** section in Settings, above Reading (language is app-wide, not reading-specific) — a dedicated section rather than folding it into Reading or pushing to its own screen. Picker style matches the existing Font picker: stacked rows with a filled selection dot, not the Theme picker's swatch style. Includes a 4th **Automatic** option to revert to auto-detection after overriding. Language changes require a restart to take effect (standard "restart to apply" prompt) rather than building a live Bundle-swap layer for a rarely-used setting.

  **iOS:** new `LocaleManager` (`Verso/Sources/Services/LocaleManager.swift`) mirrors `ThemeManager`'s persistence pattern, writing the standard `AppleLanguages` UserDefaults override (Apple's own supported mechanism — no `exit()` call, which risks an App Store review flag). New `SettingsRowType.language` case renders the stacked-row-with-dot style. `SettingsView` gained a General section with the four options; picking one shows an alert ("Restart Verso") rather than force-quitting the app itself.

  **Web:** `LocaleProvider` gained the `setLocale` it was already scaffolded for (see the FAB-275 step 5 comment that named this exact follow-up) — writes the `verso-locale` cookie, or clears it for Automatic (the existing first-visit detection effect already re-runs whenever the cookie is absent, so no separate code path was needed), then `router.refresh()`. New `LanguageSwitcher` sits next to the existing `ThemeSwitcher` on the article list page.

  **Copy:** 9 new keys added to `docs/copy/UI_COPY.md` (`settings.section.general`, `settings.language.*`, `language.*`) and regenerated into `Localizable.xcstrings`/`L10n.swift`/`verso-web/messages/*.json` — 286 keys total, no warnings. The four language names (`language.en/frCA/ptBR`, plus `language.automatic`) are shown as autonyms — each language's own name in its own language, e.g. "Français (Canada)" stays "Français (Canada)" regardless of active UI language — matching the platform convention Apple's own Language & Region picker uses, so a reader scanning in any language recognizes their own. **Not yet through the formal linguistic-review pass** FAB-275 step 7 gave the rest of the file (`UI_COPY_LINGUISTIC_REVIEW_fr-CA.md`/`_pt-BR.md`) — worth a look before relying on the fr-CA/pt-BR restart-prompt wording.

  **Known gap, out of scope for this pass:** the Share Extension target doesn't pick up the override — `AppleLanguages` is set via `UserDefaults.standard`, which is scoped per-target, and the Share Extension is a separate target/process from the main app. It'll keep following the system language until reopened with the override also written to the shared App Group suite. Flagged for a possible fast-follow, not fixed here.

  **Verified:** `xcodebuild` for the `Verso` scheme (Debug, iOS Simulator) — build succeeded, no new warnings. `cd verso-web && npx tsc --noEmit` and `npm run build` — both clean.

  **Completed:** 2026-08-28.

## Repo Admin

- [x] GitHub Issues Housekeeping — Reconcile `whysasse/verso-app` after Linear migration  `Done`
  The Linear→GitHub migration (2026-06-12) had left `whysasse/verso-app` with issues from other, unrelated Linear-migrated projects mixed in, and its open/closed state had drifted from `BACKLOG.md`/`DONE.md`. Reconciled:

  - **98 misplaced issues transferred out** to their correct repos: 45 → `deriva-app`, 5 → `solfa-app`, 25 → `penumbra-app`, 23 → a newly created private `flux-app` (no repo previously existed for this project).
  - **1 stray test issue closed** (non-Linear noise).
  - **7 issues closed** that `DONE.md` already showed as completed (state had never been updated after the work shipped).
  - **1 issue reopened** (`FAB-150`, App Store release checklist) — it had been auto-closed when its step-1 PR merged (a `Closes #NNN` keyword in the PR body), but Store/TestFlight/submission steps remain per `BACKLOG.md`.

  `verso-app` now has 174 issues, all genuinely Verso-scoped, with open/closed state matching `BACKLOG.md`. Reminder: GitHub Issues on `whysasse/verso-app` is a migration artifact, not a second tracker — see `AGENTS.md`.

  **Completed:** 2026-08-03.

