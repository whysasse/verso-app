# Verso — UI Copy & Microcopy

All user-visible text strings for the Verso iOS app. Developers should treat this as the source of truth when implementing screens. Each key maps to a future `Localizable.strings` entry.

**Conventions:**
- `{placeholder}` — dynamic value substituted at runtime
- ⚠️ **plural** — needs singular/plural variant (`%lld article` / `%lld articles`)
- Tone: sentence case, no exclamation marks, minimal and warm

---

## 1. Onboarding

### OB-1 · Welcome

| Key | Location | String | Notes |
|-----|----------|--------|-------|
| `onboarding.welcome.headline` | Headline | Your articles. Your files. | — |
| `onboarding.welcome.subheadline` | Subheadline | A quiet place to read. No accounts, no algorithms — just Markdown files in your iCloud Drive. | — |
| `onboarding.welcome.cta` | Primary button | Get started | — |

### OB-2 · Theme Picker

| Key | Location | String | Notes |
|-----|----------|--------|-------|
| `onboarding.theme.headline` | Headline | Choose your reading theme | — |
| `onboarding.theme.subheadline` | Subheadline | You can change this any time from settings. | — |
| `onboarding.theme.continue` | Primary button | Continue | — |
| `theme.paper` | Theme label | Paper | Shared with Settings / Reader Settings |
| `theme.sepia` | Theme label | Sepia | Shared |
| `theme.night` | Theme label | Night | Shared |
| `theme.ink` | Theme label | Ink | Shared |

### OB-3 · Folder Setup

| Key | Location | String | Notes |
|-----|----------|--------|-------|
| `onboarding.folder.headline` | Headline | Where should Verso store your articles? | — |
| `onboarding.folder.subheadline` | Subheadline | Pick a folder in iCloud Drive. Verso saves each article as a Markdown file you can open anywhere. | — |
| `onboarding.folder.chooseCta` | Primary button | Choose folder | — |
| `onboarding.folder.obsidianTip` | Tip text | Using Obsidian? Point Verso to a folder inside your vault and articles will appear there automatically. | — |

### OB-4 · Quick Tour

| Key | Location | String | Notes |
|-----|----------|--------|-------|
| `onboarding.tour.headline` | Headline | Here's how it works | — |
| `onboarding.tour.step1` | Step 1 label | Share any article from Safari or your browser to save it instantly. | — |
| `onboarding.tour.step2` | Step 2 label | Open Verso to read. Your list is always in sync with your files. | — |
| `onboarding.tour.step3` | Step 3 label | Mark articles as read when you're done. They stay in your folder forever. | — |
| `onboarding.tour.skip` | Text button | Skip | — |
| `onboarding.tour.startReading` | Primary button | Start reading | — |

---

## 2. Home · Article List

### Navigation

| Key | Location | String | Notes |
|-----|----------|--------|-------|
| `home.navTitle` | Navigation bar large title | Verso | — |
| `home.settings.accessibilityLabel` | Settings icon button | Settings | — |
| `home.archiveToggle.showArchive` | Archive toggle accessibility label | Show archived articles | — |
| `home.archiveToggle.showLibrary` | Archive toggle accessibility label (active) | Show reading list | — |
| `home.sort.newestFirst` | Sort toggle accessibility label | Sort newest first | — |
| `home.sort.oldestFirst` | Sort toggle accessibility label (active) | Sort oldest first | — |
| `home.pullToRefresh.accessibilityLabel` | Pull-to-refresh | Refresh article list | — |

### Search

| Key | Location | String | Notes |
|-----|----------|--------|-------|
| `home.search.placeholder` | Search bar placeholder | Search titles… | — |
| `home.search.clear.accessibilityLabel` | Clear search button | Clear search | — |
| `home.search.cancel` | Cancel button (keyboard visible) | Cancel | — |

### Filter Chips

| Key | Location | String | Notes |
|-----|----------|--------|-------|
| `filter.all` | Filter chip label | All | — |
| `filter.unread` | Filter chip label | Unread | — |
| `filter.reading` | Filter chip label | Reading | — |
| `filter.read` | Filter chip label | Read | — |
| `filter.all.accessibilityLabel` | VoiceOver label | All articles, {count} total | ⚠️ plural |
| `filter.unread.accessibilityLabel` | VoiceOver label | Unread, {count} articles | ⚠️ plural |
| `filter.reading.accessibilityLabel` | VoiceOver label | Reading, {count} articles | ⚠️ plural |
| `filter.read.accessibilityLabel` | VoiceOver label | Read, {count} articles | ⚠️ plural |
| `filter.chip.selected.hint` | VoiceOver hint (any chip) | Currently selected | — |
| `filter.chip.unselected.hint` | VoiceOver hint (any chip) | Double tap to filter | — |

### Article Card

| Key | Location | String | Notes |
|-----|----------|--------|-------|
| `articleCard.accessibilityLabel` | VoiceOver row label | {title}, {source}, {estimated read time} | Dynamic |
| `articleCard.accessibilityHint` | VoiceOver row hint | Double tap to open | — |
| `articleCard.estimatedReadTime` | Read time label | {N} min read | ⚠️ plural: "1 min read" / "{N} min read" |

### Status Badges

| Key | Location | String | Notes |
|-----|----------|--------|-------|
| `status.unread` | Badge / accessibility | Unread | Also used in filter chips and Reading View |
| `status.reading` | Badge / accessibility | Reading | — |
| `status.read` | Badge / accessibility | Read | — |

### Empty States

| Key | Location | String | Notes |
|-----|----------|--------|-------|
| `home.empty.noArticles.headline` | Empty state headline | No articles yet | — |
| `home.empty.noArticles.subheadline` | Empty state subheadline | Share an article from Safari to get started. | — |
| `home.empty.noResults.headline` | Search empty state headline | No results | — |
| `home.empty.noResults.subheadline` | Search empty state subheadline | Try a different search term. | — |
| `home.empty.archive.headline` | Archive empty state headline | Nothing archived | — |
| `home.empty.archive.subheadline` | Archive empty state subheadline | Articles you archive will appear here. | — |
| `home.loading.accessibilityLabel` | Skeleton loading state | Loading articles | — |

### Swipe Actions

| Key | Location | String | Notes |
|-----|----------|--------|-------|
| `swipe.delete` | Swipe-left action label | Delete | Red |
| `swipe.archive` | Swipe-left action label | Archive | — |
| `swipe.unarchive` | Swipe-left action label (archive view) | Unarchive | — |

### Context Menu

| Key | Location | String | Notes |
|-----|----------|--------|-------|
| `contextMenu.open` | Context menu item | Open | — |
| `contextMenu.archive` | Context menu item | Archive | — |
| `contextMenu.unarchive` | Context menu item | Unarchive | — |
| `contextMenu.markAsRead` | Context menu item | Mark as read | — |
| `contextMenu.markAsUnread` | Context menu item | Mark as unread | — |
| `contextMenu.delete` | Context menu item | Delete | Destructive |

### Delete Confirmation Dialog

| Key | Location | String | Notes |
|-----|----------|--------|-------|
| `dialog.deleteArticle.title` | Dialog title | Delete article? | — |
| `dialog.deleteArticle.message` | Dialog message | This cannot be undone. The file will be permanently removed from your iCloud Drive. | — |
| `dialog.deleteArticle.confirm` | Destructive button | Delete | — |
| `dialog.deleteArticle.cancel` | Cancel button | Cancel | — |

---

## 3. Reading View

### Top Bar

| Key | Location | String | Notes |
|-----|----------|--------|-------|
| `reading.back.accessibilityLabel` | Back button | Back to reading list | — |
| `reading.openExternal.accessibilityLabel` | Open-externally button | Open original article | — |

### Immersive Hint

| Key | Location | String | Notes |
|-----|----------|--------|-------|
| `reading.immersiveHint` | Hint pill (first launch only) | Tap anywhere to reveal controls | Never shown when VoiceOver is active |

### Scroll Progress

| Key | Location | String | Notes |
|-----|----------|--------|-------|
| `reading.progress.accessibilityLabel` | Progress bar | {N} minutes remaining | ⚠️ plural; "Less than a minute remaining" when < 1 min |
| `reading.progress.almostDone` | Progress bar (< 1 min) | Less than a minute remaining | — |

### Bottom Bar (Reading Controls)

| Key | Location | String | Notes |
|-----|----------|--------|-------|
| `reading.controls.decreaseFontSize` | Icon button accessibility label | Decrease font size | — |
| `reading.controls.increaseFontSize` | Icon button accessibility label | Increase font size | — |
| `reading.controls.lineSpacing` | Icon button accessibility label | Line spacing | — |
| `reading.controls.lineSpacing.hint` | VoiceOver hint | Double tap to open spacing options | — |
| `reading.controls.margins` | Icon button accessibility label | Margins | — |
| `reading.controls.margins.hint` | VoiceOver hint | Double tap to open margin options | — |
| `reading.controls.theme` | Icon button accessibility label | Theme | — |
| `reading.controls.theme.hint` | VoiceOver hint | Double tap to open theme options | — |
| `reading.controls.markAsRead` | Icon button accessibility label | Mark as read | — |
| `reading.controls.markAsUnread` | Icon button accessibility label | Mark as unread | — |
| `reading.controls.tts.play` | TTS button accessibility label | Play text-to-speech | — |
| `reading.controls.tts.pause` | TTS button accessibility label | Pause text-to-speech | — |

### Text-to-Speech (Lock Screen / Now Playing)

| Key | Location | String | Notes |
|-----|----------|--------|-------|
| `tts.nowPlaying.play` | Lock screen control | Play | — |
| `tts.nowPlaying.pause` | Lock screen control | Pause | — |
| `tts.nowPlaying.skipForward` | Lock screen control | Skip forward | — |

### Article Header

> **Format note:** Display date as `MMM d, yyyy` (e.g. "Apr 28, 2025"). No key needed — format is code-level.

---

## 4. Reader Settings (Bottom Sheet)

| Key | Location | String | Notes |
|-----|----------|--------|-------|
| `readerSettings.title` | Sheet title | Reading settings | — |
| `readerSettings.fontSize.sectionLabel` | Section label | Text size | — |
| `readerSettings.fontSize.xs` | Step label | XS | Accessibility label: "Extra small, 14 points" |
| `readerSettings.fontSize.s` | Step label | S | Accessibility label: "Small, 16 points" |
| `readerSettings.fontSize.m` | Step label | M | Accessibility label: "Medium, 18 points, default" |
| `readerSettings.fontSize.l` | Step label | L | Accessibility label: "Large, 20 points" |
| `readerSettings.fontSize.xl` | Step label | XL | Accessibility label: "Extra large, 22 points" |
| `readerSettings.fontSize.xxl` | Step label | XXL | Accessibility label: "Extra extra large, 26 points" |
| `readerSettings.lineSpacing.sectionLabel` | Section label | Line spacing | — |
| `readerSettings.lineSpacing.compact` | Option label | Compact | — |
| `readerSettings.lineSpacing.normal` | Option label | Normal | — |
| `readerSettings.lineSpacing.relaxed` | Option label | Relaxed | Default |
| `readerSettings.lineSpacing.airy` | Option label | Airy | — |
| `readerSettings.theme.sectionLabel` | Section label | Theme | — |
| `readerSettings.theme.selected.hint` | VoiceOver hint | Currently selected | — |
| `readerSettings.margins.sectionLabel` | Section label | Margins | — |

---

## 5. Settings (Modal)

| Key | Location | String | Notes |
|-----|----------|--------|-------|
| `settings.title` | Navigation title | Settings | — |
| `settings.done` | Done button | Done | — |
| `settings.section.folder` | Section header | Folder | — |
| `settings.folder.rowLabel` | Row label | Reading folder | — |
| `settings.folder.emptyValue` | Row sub-label (no folder set) | Not configured | — |
| `settings.folder.currentValue` | Row sub-label (folder set) | {folderName} | Dynamic |
| `settings.section.appearance` | Section header | Appearance | — |
| `settings.appearance.rowLabel` | Row label | Appearance | — |
| `settings.section.about` | Section header | About | — |
| `settings.about.rowLabel` | Row label | About Verso | — |

### Change Folder Dialog

| Key | Location | String | Notes |
|-----|----------|--------|-------|
| `dialog.changeFolder.title` | Dialog title | Move existing articles? | — |
| `dialog.changeFolder.message` | Dialog message | Do you want to move your saved articles to the new folder? Your current folder won't be changed if you choose No. | — |
| `dialog.changeFolder.yes` | Confirm button | Move articles | — |
| `dialog.changeFolder.no` | Secondary button | Don't move | — |
| `dialog.changeFolder.cancel` | Cancel button | Cancel | — |

---

## 6. Appearance (Settings Sub-page)

| Key | Location | String | Notes |
|-----|----------|--------|-------|
| `appearance.title` | Page title | Appearance | — |
| `appearance.section.theme` | Section label | Default theme | — |
| `appearance.section.font` | Section label | Default font | — |
| `appearance.font.newYork` | Font option label | New York | — |
| `appearance.font.georgia` | Font option label | Georgia | — |
| `appearance.font.sfPro` | Font option label | SF Pro | — |
| `appearance.font.openDyslexic` | Font option label | OpenDyslexic | — |
| `appearance.font.preview` | Font preview sample text | The verso is the left-hand page. | Invariant — do not localise |
| `appearance.section.textSize` | Section label | Default text size | — |

---

## 7. About (Settings Sub-page)

| Key | Location | String | Notes |
|-----|----------|--------|-------|
| `about.title` | Page title | About Verso | — |
| `about.version.rowLabel` | Row label | Version | Sub-label: `{version} ({build})` |
| `about.acknowledgements.rowLabel` | Row label | Open-source acknowledgements | — |
| `about.github.rowLabel` | Row label | View on GitHub | — |
| `about.privacyPolicy.rowLabel` | Row label | Privacy policy | — |
| `about.footer` | Copyright footer | Verso {version} · Built with care | — |

---

## 8. Share Extension

| Key | Location | String | Notes |
|-----|----------|--------|-------|
| `share.title` | Sheet title | Save to Verso | — |
| `share.preview.loading.accessibilityLabel` | Loading shimmer | Loading article preview | — |
| `share.save.default` | Save button | Save | — |
| `share.save.loading` | Save button (in progress) | Saving… | — |
| `share.save.success` | Save button (done) | Saved | — |
| `share.save.error` | Save button (failed) | Try again | — |
| `share.cancel` | Cancel button | Cancel | — |
| `share.error.couldNotParse` | Error message | Could not extract article. | — |
| `share.error.openInSafari` | Error link text | Open in Safari | — |
| `share.error.noFolder.message` | No-folder-configured message | Folder not configured. | — |
| `share.error.noFolder.cta` | No-folder-configured link | Open Verso to finish setup | — |

---

## 9. Error & System Messages

| Key | Location | String | Notes |
|-----|----------|--------|-------|
| `error.couldNotSave` | Share extension / import error | Could not save article. | — |
| `error.couldNotParse` | Parse failure | Could not parse article. | Matches PRD wording exactly |
| `error.fileWrite` | File system error | Could not write file. | — |
| `error.iCloudUnavailable` | iCloud error banner | iCloud Drive is unavailable. Check Settings → [Your Name] → iCloud. | — |
| `error.offline.banner` | Offline banner | You're offline. Saved articles are still available. | — |
| `error.offline.articleUnavailable` | Article unavailable offline | Not available offline. | Shown on greyed-out article row |
| `error.generic` | Generic fallback | Something went wrong. Please try again. | — |

---

## 10. Accessibility-Only Labels (VoiceOver)

These strings are never visible on screen. They are set via `.accessibilityLabel` / `.accessibilityHint` in code.

| Key | Location | String | Notes |
|-----|----------|--------|-------|
| `a11y.articleRow.hint` | Article list row hint | Double tap to open | — |
| `a11y.articleRow.label` | Article list row label | {title}, {source}, {estimatedReadTime} | Dynamic |
| `a11y.filterChip.selected` | Selected filter chip hint | Currently selected | — |
| `a11y.filterChip.unselected` | Unselected filter chip hint | Double tap to filter | — |
| `a11y.themeChip.selected` | Selected theme chip hint | Currently selected | — |
| `a11y.themeChip.unselected` | Unselected theme chip hint | Double tap to select | — |
| `a11y.fontOption.selected` | Selected font option announcement | {fontName}, selected | — |
| `a11y.fontOption.unselected` | Unselected font option | {fontName} | — |
| `a11y.fontSize.label` | Font size step label | {label}, {points} points | e.g. "Medium, 18 points" |
| `a11y.fontSize.default` | Default size annotation | {label}, {points} points, default | e.g. "Medium, 18 points, default" |
| `a11y.progress.label` | Scroll progress bar | Reading progress | — |
| `a11y.progress.value` | Scroll progress bar value | {N} minutes remaining | ⚠️ plural; use `reading.progress.almostDone` < 1 min |
| `a11y.skeletonLoading` | Skeleton list | Loading articles | — |
| `a11y.deleteAction` | Swipe-delete action | Delete article | — |
| `a11y.archiveAction` | Swipe-archive action | Archive article | — |
| `a11y.unarchiveAction` | Swipe-unarchive action | Unarchive article | — |
