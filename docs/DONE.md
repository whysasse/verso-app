# Verso — Completed Issues

> Archive of all completed issues. See [BACKLOG.md](BACKLOG.md) for open work.

**164 completed issues.**

## iOS

### Phase 1 — Foundation

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

## Repo Admin

- [x] GitHub Issues Housekeeping — Reconcile `whysasse/verso-app` after Linear migration  `Done`
  The Linear→GitHub migration (2026-06-12) had left `whysasse/verso-app` with issues from other, unrelated Linear-migrated projects mixed in, and its open/closed state had drifted from `BACKLOG.md`/`DONE.md`. Reconciled:

  - **98 misplaced issues transferred out** to their correct repos: 45 → `deriva-app`, 5 → `solfa-app`, 25 → `penumbra-app`, 23 → a newly created private `flux-app` (no repo previously existed for this project).
  - **1 stray test issue closed** (non-Linear noise).
  - **7 issues closed** that `DONE.md` already showed as completed (state had never been updated after the work shipped).
  - **1 issue reopened** (`FAB-150`, App Store release checklist) — it had been auto-closed when its step-1 PR merged (a `Closes #NNN` keyword in the PR body), but Store/TestFlight/submission steps remain per `BACKLOG.md`.

  `verso-app` now has 174 issues, all genuinely Verso-scoped, with open/closed state matching `BACKLOG.md`. Reminder: GitHub Issues on `whysasse/verso-app` is a migration artifact, not a second tracker — see `AGENTS.md`.

  **Completed:** 2026-08-03.

