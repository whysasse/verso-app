// GENERATED FILE -- do not edit by hand.
// Source of truth: docs/copy/UI_COPY.md
// Regenerate with: python3 docs/copy/codegen/generate.py
// (keys, English strings, and fr-CA/pt-BR translations all come from that file)

import Foundation

/// Typed accessors for every localized string key in `docs/copy/UI_COPY.md`.
/// Each accessor reads from `Localizable.xcstrings` via the key, falling back to
/// the English text below if a translation is missing.
enum L10n {
    enum A11y {
        /// "Archive article" -- Swipe-archive action
        static var archiveAction: String {
            String(localized: "a11y.archiveAction", defaultValue: "Archive article", comment: "Swipe-archive action")
        }
        /// "Double tap to open" -- Article list row hint
        static var articleRowHint: String {
            String(localized: "a11y.articleRow.hint", defaultValue: "Double tap to open", comment: "Article list row hint")
        }
        /// "{title}, {source}, {estimatedReadTime}" -- Dynamic — composed from already-translated fragments, no literal text to translate
        static func articleRowLabel(title: String, source: String, estimatedReadTime: String) -> String {
            String(localized: "a11y.articleRow.label", defaultValue: "\(title), \(source), \(estimatedReadTime)", comment: "Dynamic — composed from already-translated fragments, no literal text to translate")
        }
        /// "Delete article" -- Swipe-delete action
        static var deleteAction: String {
            String(localized: "a11y.deleteAction", defaultValue: "Delete article", comment: "Swipe-delete action")
        }
        /// "Currently selected" -- Selected filter chip hint
        static var filterChipSelected: String {
            String(localized: "a11y.filterChip.selected", defaultValue: "Currently selected", comment: "Selected filter chip hint")
        }
        /// "Double tap to filter" -- Unselected filter chip hint
        static var filterChipUnselected: String {
            String(localized: "a11y.filterChip.unselected", defaultValue: "Double tap to filter", comment: "Unselected filter chip hint")
        }
        /// "{fontName}, selected" -- Selected font option announcement
        static func fontOptionSelected(fontName: String) -> String {
            String(localized: "a11y.fontOption.selected", defaultValue: "\(fontName), selected", comment: "Selected font option announcement")
        }
        /// "{fontName}" -- Font names are invariant
        static func fontOptionUnselected(fontName: String) -> String {
            String(localized: "a11y.fontOption.unselected", defaultValue: "\(fontName)", comment: "Font names are invariant")
        }
        /// "{label}, {points} points, default" -- e.g. 'Medium, 18 points, default'
        static func fontSizeDefault(label: String, points: Int) -> String {
            String(localized: "a11y.fontSize.default", defaultValue: "\(label), \(points) points, default", comment: "e.g. 'Medium, 18 points, default'")
        }
        /// "{label}, {points} points" -- e.g. 'Medium, 18 points' → 'Moyen, 18 points' → 'Médio, 18 pontos'. `{label}` is the full-word size name (Extra small/Small/Medium/…), not the XS/S/M abbreviation — see §4 Reader Settings open question
        static func fontSizeLabel(label: String, points: Int) -> String {
            String(localized: "a11y.fontSize.label", defaultValue: "\(label), \(points) points", comment: "e.g. 'Medium, 18 points' → 'Moyen, 18 points' → 'Médio, 18 pontos'. `{label}` is the full-word size name (Extra small/Small/Medium/…), not the XS/S/M abbreviation — see §4 Reader Settings open question")
        }
        /// "Reading progress" -- Scroll progress bar
        static var progressLabel: String {
            String(localized: "a11y.progress.label", defaultValue: "Reading progress", comment: "Scroll progress bar")
        }
        /// "{N} percent" -- Corrected during step 4 view-wiring pass: doc previously specified '{N} minutes remaining' with full plural handling, but shipped code reads out scroll percentage, not estimated time remaining. 'Percent' doesn't inflect by count in en/fr-CA/pt-BR, so no plural variant needed. Wiring ScrollProgress.swift to a real time-remaining announcement is a possible future enhancement — see docs/BACKLOG.md.
        static func progressValue(count: Int) -> String {
            String(localized: "a11y.progress.value", defaultValue: "\(count) percent", comment: "Corrected during step 4 view-wiring pass: doc previously specified '{N} minutes remaining' with full plural handling, but shipped code reads out scroll percentage, not estimated time remaining. 'Percent' doesn't inflect by count in en/fr-CA/pt-BR, so no plural variant needed. Wiring ScrollProgress.swift to a real time-remaining announcement is a possible future enhancement — see docs/BACKLOG.md.")
        }
        /// "Loading articles" -- Skeleton list
        static var skeletonLoading: String {
            String(localized: "a11y.skeletonLoading", defaultValue: "Loading articles", comment: "Skeleton list")
        }
        /// "Currently selected" -- Selected theme chip hint
        static var themeChipSelected: String {
            String(localized: "a11y.themeChip.selected", defaultValue: "Currently selected", comment: "Selected theme chip hint")
        }
        /// "Double tap to select" -- Unselected theme chip hint
        static var themeChipUnselected: String {
            String(localized: "a11y.themeChip.unselected", defaultValue: "Double tap to select", comment: "Unselected theme chip hint")
        }
        /// "Unarchive article" -- Swipe-unarchive action
        static var unarchiveAction: String {
            String(localized: "a11y.unarchiveAction", defaultValue: "Unarchive article", comment: "Swipe-unarchive action")
        }
    }
    enum About {
        /// "Open-source acknowledgements" -- Row label
        static var acknowledgementsRowLabel: String {
            String(localized: "about.acknowledgements.rowLabel", defaultValue: "Open-source acknowledgements", comment: "Row label")
        }
        /// "Verso {version} · Built with care" -- `Verso` invariant
        static func footer(version: String) -> String {
            String(localized: "about.footer", defaultValue: "Verso \(version) · Built with care", comment: "`Verso` invariant")
        }
        /// "View on GitHub" -- `GitHub` invariant
        static var githubRowLabel: String {
            String(localized: "about.github.rowLabel", defaultValue: "View on GitHub", comment: "`GitHub` invariant")
        }
        /// "Privacy policy" -- Row label
        static var privacyPolicyRowLabel: String {
            String(localized: "about.privacyPolicy.rowLabel", defaultValue: "Privacy policy", comment: "Row label")
        }
        /// "About Verso" -- Page title
        static var title: String {
            String(localized: "about.title", defaultValue: "About Verso", comment: "Page title")
        }
        /// "Version" -- Sub-label: `{version} ({build})` (digits/format unchanged across locales)
        static var versionRowLabel: String {
            String(localized: "about.version.rowLabel", defaultValue: "Version", comment: "Sub-label: `{version} ({build})` (digits/format unchanged across locales)")
        }
    }
    enum AddArticle {
        /// "Dismiss add article sheet" -- Close button VoiceOver hint
        static var closeAccessibilityHint: String {
            String(localized: "addArticle.close.accessibilityHint", defaultValue: "Dismiss add article sheet", comment: "Close button VoiceOver hint")
        }
        /// "Close" -- Close (X) toolbar button
        static var closeAccessibilityLabel: String {
            String(localized: "addArticle.close.accessibilityLabel", defaultValue: "Close", comment: "Close (X) toolbar button")
        }
        /// "No library folder selected." -- Edge case — folder bookmark missing mid-flow
        static var errorNoLibraryFolder: String {
            String(localized: "addArticle.error.noLibraryFolder", defaultValue: "No library folder selected.", comment: "Edge case — folder bookmark missing mid-flow")
        }
        /// "Could not save article" -- Failure state headline
        static var failureHeadline: String {
            String(localized: "addArticle.failure.headline", defaultValue: "Could not save article", comment: "Failure state headline")
        }
        /// "Try Again" -- Failure state primary button
        static var failureTryAgain: String {
            String(localized: "addArticle.failure.tryAgain", defaultValue: "Try Again", comment: "Failure state primary button")
        }
        /// "Paste a link to save an article to your library." -- Idle state body copy
        static var idleInstructions: String {
            String(localized: "addArticle.idle.instructions", defaultValue: "Paste a link to save an article to your library.", comment: "Idle state body copy")
        }
        /// "Paste a link…" -- URL text field placeholder
        static var idlePlaceholder: String {
            String(localized: "addArticle.idle.placeholder", defaultValue: "Paste a link…", comment: "URL text field placeholder")
        }
        /// "Save" -- Primary button
        static var idleSave: String {
            String(localized: "addArticle.idle.save", defaultValue: "Save", comment: "Primary button")
        }
        /// "Add Article" -- Sheet nav bar title
        static var navTitle: String {
            String(localized: "addArticle.navTitle", defaultValue: "Add Article", comment: "Sheet nav bar title")
        }
        /// "Saving article…" -- In-progress state
        static var savingMessage: String {
            String(localized: "addArticle.saving.message", defaultValue: "Saving article…", comment: "In-progress state")
        }
        /// "Article saved!" -- Success state headline
        static var successHeadline: String {
            String(localized: "addArticle.success.headline", defaultValue: "Article saved!", comment: "Success state headline")
        }
        /// "It will appear in your library shortly." -- Success state subheadline
        static var successSubheadline: String {
            String(localized: "addArticle.success.subheadline", defaultValue: "It will appear in your library shortly.", comment: "Success state subheadline")
        }
    }
    enum ArticleCard {
        /// "Double tap to open" -- VoiceOver row hint
        static var accessibilityHint: String {
            String(localized: "articleCard.accessibilityHint", defaultValue: "Double tap to open", comment: "VoiceOver row hint")
        }
        /// "{title}, {source}, {estimated read time}" -- Dynamic — template only, no literal text to translate
        static func accessibilityLabel(title: String, source: String, estimatedReadTime: String) -> String {
            String(localized: "articleCard.accessibilityLabel", defaultValue: "\(title), \(source), \(estimatedReadTime)", comment: "Dynamic — template only, no literal text to translate")
        }
        /// "{N} min read" -- ⚠️ plural: '1 min read' / '{N} min read'. `{N}` = ⌈wordCount ÷ WPM⌉. Use a single documented constant **WPM = 220** for MVP. Word count is derived from the **article's** content language, not the UI language. fr-CA/pt-BR: 'min' is already an invariant abbreviation in both languages, no plural variant needed.
        static func estimatedReadTime(count: Int) -> String {
            String(localized: "articleCard.estimatedReadTime", defaultValue: "\(count) min read", comment: "⚠️ plural: '1 min read' / '{N} min read'. `{N}` = ⌈wordCount ÷ WPM⌉. Use a single documented constant **WPM = 220** for MVP. Word count is derived from the **article's** content language, not the UI language. fr-CA/pt-BR: 'min' is already an invariant abbreviation in both languages, no plural variant needed.")
        }
    }
    enum ContextMenu {
        /// "Archive" -- Context menu item
        static var archive: String {
            String(localized: "contextMenu.archive", defaultValue: "Archive", comment: "Context menu item")
        }
        /// "Delete" -- Destructive
        static var delete: String {
            String(localized: "contextMenu.delete", defaultValue: "Delete", comment: "Destructive")
        }
        /// "Mark as read" -- Context menu item
        static var markAsRead: String {
            String(localized: "contextMenu.markAsRead", defaultValue: "Mark as read", comment: "Context menu item")
        }
        /// "Mark as unread" -- Context menu item
        static var markAsUnread: String {
            String(localized: "contextMenu.markAsUnread", defaultValue: "Mark as unread", comment: "Context menu item")
        }
        /// "Open" -- Context menu item
        static var open: String {
            String(localized: "contextMenu.open", defaultValue: "Open", comment: "Context menu item")
        }
        /// "Unarchive" -- Context menu item
        static var unarchive: String {
            String(localized: "contextMenu.unarchive", defaultValue: "Unarchive", comment: "Context menu item")
        }
    }
    enum Dialog {
        /// "Delete {count} articles?" -- ⚠️ plural (this row shows the 'other'/plural form; singular 'one' form authored directly in codegen, same pattern as the other ⚠️-flagged keys). Confirm/Cancel buttons reuse `dialog.deleteArticle.confirm` / `dialog.deleteArticle.cancel` (identical wording, no new key needed).
        static func bulkDeleteTitle(count: Int) -> String {
            String(localized: "dialog.bulkDelete.title", defaultValue: "Delete \(count) articles?", comment: "⚠️ plural (this row shows the 'other'/plural form; singular 'one' form authored directly in codegen, same pattern as the other ⚠️-flagged keys). Confirm/Cancel buttons reuse `dialog.deleteArticle.confirm` / `dialog.deleteArticle.cancel` (identical wording, no new key needed).")
        }
        /// "Cancel" -- Cancel button
        static var changeFolderCancel: String {
            String(localized: "dialog.changeFolder.cancel", defaultValue: "Cancel", comment: "Cancel button")
        }
        /// "Your old folder won't be touched if you choose No." -- Corrected to match shipped copy.
        static var changeFolderMessage: String {
            String(localized: "dialog.changeFolder.message", defaultValue: "Your old folder won't be touched if you choose No.", comment: "Corrected to match shipped copy.")
        }
        /// "Keep in Old Folder" -- Corrected to match shipped copy.
        static var changeFolderNo: String {
            String(localized: "dialog.changeFolder.no", defaultValue: "Keep in Old Folder", comment: "Corrected to match shipped copy.")
        }
        /// "Move your existing articles to the new folder?" -- Corrected to match shipped copy.
        static var changeFolderTitle: String {
            String(localized: "dialog.changeFolder.title", defaultValue: "Move your existing articles to the new folder?", comment: "Corrected to match shipped copy.")
        }
        /// "Move Articles" -- Corrected to match shipped copy (Title Case).
        static var changeFolderYes: String {
            String(localized: "dialog.changeFolder.yes", defaultValue: "Move Articles", comment: "Corrected to match shipped copy (Title Case).")
        }
        /// "Cancel" -- Cancel button
        static var deleteArticleCancel: String {
            String(localized: "dialog.deleteArticle.cancel", defaultValue: "Cancel", comment: "Cancel button")
        }
        /// "Delete" -- Destructive button
        static var deleteArticleConfirm: String {
            String(localized: "dialog.deleteArticle.confirm", defaultValue: "Delete", comment: "Destructive button")
        }
        /// "This cannot be undone. The file will be permanently removed from your iCloud Drive." -- Dialog message
        static var deleteArticleMessage: String {
            String(localized: "dialog.deleteArticle.message", defaultValue: "This cannot be undone. The file will be permanently removed from your iCloud Drive.", comment: "Dialog message")
        }
        /// "Delete article?" -- Dialog title
        static var deleteArticleTitle: String {
            String(localized: "dialog.deleteArticle.title", defaultValue: "Delete article?", comment: "Dialog title")
        }
    }
    enum Error {
        /// "Open original" -- Opens sourceURL in Safari
        static var fileReadCta: String {
            String(localized: "error.fileRead.cta", defaultValue: "Open original", comment: "Opens sourceURL in Safari")
        }
        /// "This article couldn't be loaded." -- Inline reading view
        static var fileReadHeadline: String {
            String(localized: "error.fileRead.headline", defaultValue: "This article couldn't be loaded.", comment: "Inline reading view")
        }
        /// "Couldn't save article." -- 3s auto-dismiss
        static var fileWriteMessage: String {
            String(localized: "error.fileWrite.message", defaultValue: "Couldn't save article.", comment: "3s auto-dismiss")
        }
        /// "Check that your folder is accessible and try again." -- Toast subtext
        static var fileWriteSubtext: String {
            String(localized: "error.fileWrite.subtext", defaultValue: "Check that your folder is accessible and try again.", comment: "Toast subtext")
        }
        /// "Choose new folder" -- CTA button
        static var folderMissingCta: String {
            String(localized: "error.folderMissing.cta", defaultValue: "Choose new folder", comment: "CTA button")
        }
        /// "Folder not found." -- Full-screen error headline
        static var folderMissingHeadline: String {
            String(localized: "error.folderMissing.headline", defaultValue: "Folder not found.", comment: "Full-screen error headline")
        }
        /// "The folder may have been moved or deleted. Choose a new one to continue." -- Full-screen error subheadline
        static var folderMissingSubheadline: String {
            String(localized: "error.folderMissing.subheadline", defaultValue: "The folder may have been moved or deleted. Choose a new one to continue.", comment: "Full-screen error subheadline")
        }
        /// "Something went wrong. Please try again." -- Last-resort fallback
        static var generic: String {
            String(localized: "error.generic", defaultValue: "Something went wrong. Please try again.", comment: "Last-resort fallback")
        }
        /// "iCloud Drive is unavailable." -- `iCloud Drive` invariant
        static var iCloudUnavailableHeadline: String {
            String(localized: "error.iCloudUnavailable.headline", defaultValue: "iCloud Drive is unavailable.", comment: "`iCloud Drive` invariant")
        }
        /// "Go to Settings → [Your Name] → iCloud to re-enable it." -- `[Your Name]` is **intentional** in all locales — it matches Apple's on-screen label for the device-owner row in iOS Settings. Keep the placeholder; do not insert a real name. Translators should match Apple's localized Settings path wording for 'Réglages'/'Configurações' once confirmed against an fr-CA/pt-BR device — flag for step 7 QA.
        static var iCloudUnavailableSubheadline: String {
            String(localized: "error.iCloudUnavailable.subheadline", defaultValue: "Go to Settings → [Your Name] → iCloud to re-enable it.", comment: "`[Your Name]` is **intentional** in all locales — it matches Apple's on-screen label for the device-owner row in iOS Settings. Keep the placeholder; do not insert a real name. Translators should match Apple's localized Settings path wording for 'Réglages'/'Configurações' once confirmed against an fr-CA/pt-BR device — flag for step 7 QA.")
        }
        /// "Choose folder" -- CTA button
        static var noFolderCta: String {
            String(localized: "error.noFolder.cta", defaultValue: "Choose folder", comment: "CTA button")
        }
        /// "No folder selected." -- Full-screen error headline
        static var noFolderHeadline: String {
            String(localized: "error.noFolder.headline", defaultValue: "No folder selected.", comment: "Full-screen error headline")
        }
        /// "Choose a folder in iCloud Drive to start saving articles." -- Full-screen error subheadline
        static var noFolderSubheadline: String {
            String(localized: "error.noFolder.subheadline", defaultValue: "Choose a folder in iCloud Drive to start saving articles.", comment: "Full-screen error subheadline")
        }
        /// "Not available offline." -- Greyed-out row only
        static var offlineArticleUnavailable: String {
            String(localized: "error.offline.articleUnavailable", defaultValue: "Not available offline.", comment: "Greyed-out row only")
        }
        /// "You're offline." -- Inline banner headline
        static var offlineBannerHeadline: String {
            String(localized: "error.offline.banner.headline", defaultValue: "You're offline.", comment: "Inline banner headline")
        }
        /// "Saved articles are still available." -- Inline banner subheadline
        static var offlineBannerSubheadline: String {
            String(localized: "error.offline.banner.subheadline", defaultValue: "Saved articles are still available.", comment: "Inline banner subheadline")
        }
        /// "Dismiss" -- Secondary CTA
        static var parsingDismiss: String {
            String(localized: "error.parsing.dismiss", defaultValue: "Dismiss", comment: "Secondary CTA")
        }
        /// "Couldn't read this article." -- Bottom sheet headline
        static var parsingHeadline: String {
            String(localized: "error.parsing.headline", defaultValue: "Couldn't read this article.", comment: "Bottom sheet headline")
        }
        /// "Open in Safari" -- Accent fill; `Safari` invariant
        static var parsingOpenInSafari: String {
            String(localized: "error.parsing.openInSafari", defaultValue: "Open in Safari", comment: "Accent fill; `Safari` invariant")
        }
        /// "The page may be behind a paywall or require a login." -- Bottom sheet subheadline
        static var parsingSubheadline: String {
            String(localized: "error.parsing.subheadline", defaultValue: "The page may be behind a paywall or require a login.", comment: "Bottom sheet subheadline")
        }
    }
    enum Filter {
        /// "All" -- Filter chip label
        static var all: String {
            String(localized: "filter.all", defaultValue: "All", comment: "Filter chip label")
        }
        /// "All articles, {count} total" -- ⚠️ plural
        static func allAccessibilityLabel(count: Int) -> String {
            String(localized: "filter.all.accessibilityLabel", defaultValue: "All articles, \(count) total", comment: "⚠️ plural")
        }
        /// "Archived" -- Added during step 4 view-wiring pass — `FilterChipBar.swift` renders a chip for every `ArticleStatus` case, including `.archived`, which the original audit missed.
        static var archived: String {
            String(localized: "filter.archived", defaultValue: "Archived", comment: "Added during step 4 view-wiring pass — `FilterChipBar.swift` renders a chip for every `ArticleStatus` case, including `.archived`, which the original audit missed.")
        }
        /// "Archived, {count} articles" -- ⚠️ plural. Added during step 4 view-wiring pass — see note on `filter.archived`.
        static func archivedAccessibilityLabel(count: Int) -> String {
            String(localized: "filter.archived.accessibilityLabel", defaultValue: "Archived, \(count) articles", comment: "⚠️ plural. Added during step 4 view-wiring pass — see note on `filter.archived`.")
        }
        /// "Currently selected" -- VoiceOver hint (any chip)
        static var chipSelectedHint: String {
            String(localized: "filter.chip.selected.hint", defaultValue: "Currently selected", comment: "VoiceOver hint (any chip)")
        }
        /// "Double tap to filter" -- VoiceOver hint (any chip)
        static var chipUnselectedHint: String {
            String(localized: "filter.chip.unselected.hint", defaultValue: "Double tap to filter", comment: "VoiceOver hint (any chip)")
        }
        /// "Read" -- Filter chip label
        static var read: String {
            String(localized: "filter.read", defaultValue: "Read", comment: "Filter chip label")
        }
        /// "Read, {count} articles" -- ⚠️ plural
        static func readAccessibilityLabel(count: Int) -> String {
            String(localized: "filter.read.accessibilityLabel", defaultValue: "Read, \(count) articles", comment: "⚠️ plural")
        }
        /// "Reading" -- Filter chip label
        static var reading: String {
            String(localized: "filter.reading", defaultValue: "Reading", comment: "Filter chip label")
        }
        /// "Reading, {count} articles" -- ⚠️ plural
        static func readingAccessibilityLabel(count: Int) -> String {
            String(localized: "filter.reading.accessibilityLabel", defaultValue: "Reading, \(count) articles", comment: "⚠️ plural")
        }
        /// "Unread" -- Filter chip label
        static var unread: String {
            String(localized: "filter.unread", defaultValue: "Unread", comment: "Filter chip label")
        }
        /// "Unread, {count} articles" -- ⚠️ plural
        static func unreadAccessibilityLabel(count: Int) -> String {
            String(localized: "filter.unread.accessibilityLabel", defaultValue: "Unread, \(count) articles", comment: "⚠️ plural")
        }
    }
    enum Home {
        /// "Show archived articles" -- Archive toggle accessibility label
        static var archiveToggleShowArchive: String {
            String(localized: "home.archiveToggle.showArchive", defaultValue: "Show archived articles", comment: "Archive toggle accessibility label")
        }
        /// "Show reading list" -- Archive toggle accessibility label (active)
        static var archiveToggleShowLibrary: String {
            String(localized: "home.archiveToggle.showLibrary", defaultValue: "Show reading list", comment: "Archive toggle accessibility label (active)")
        }
        /// "Cancel" -- Toolbar button — exits bulk-select mode
        static var bulkSelectCancel: String {
            String(localized: "home.bulkSelect.cancel", defaultValue: "Cancel", comment: "Toolbar button — exits bulk-select mode")
        }
        /// "Delete" -- Destructive
        static var bulkSelectDelete: String {
            String(localized: "home.bulkSelect.delete", defaultValue: "Delete", comment: "Destructive")
        }
        /// "Mark read" -- Bottom bar action (selection non-empty)
        static var bulkSelectMarkRead: String {
            String(localized: "home.bulkSelect.markRead", defaultValue: "Mark read", comment: "Bottom bar action (selection non-empty)")
        }
        /// "Select" -- Added during step 4 view-wiring pass — bulk select postdates the original audit.
        static var bulkSelectSelect: String {
            String(localized: "home.bulkSelect.select", defaultValue: "Select", comment: "Added during step 4 view-wiring pass — bulk select postdates the original audit.")
        }
        /// "Any time" -- Date-range menu option
        static var dateFilterAny: String {
            String(localized: "home.dateFilter.any", defaultValue: "Any time", comment: "Date-range menu option")
        }
        /// "Added" -- Added during step 4 view-wiring pass — missed in the original audit (date-range filter postdates it).
        static var dateFilterLabel: String {
            String(localized: "home.dateFilter.label", defaultValue: "Added", comment: "Added during step 4 view-wiring pass — missed in the original audit (date-range filter postdates it).")
        }
        /// "Past month" -- Date-range menu option
        static var dateFilterMonth: String {
            String(localized: "home.dateFilter.month", defaultValue: "Past month", comment: "Date-range menu option")
        }
        /// "Past week" -- Date-range menu option
        static var dateFilterWeek: String {
            String(localized: "home.dateFilter.week", defaultValue: "Past week", comment: "Date-range menu option")
        }
        /// "Past year" -- Date-range menu option
        static var dateFilterYear: String {
            String(localized: "home.dateFilter.year", defaultValue: "Past year", comment: "Date-range menu option")
        }
        /// "Nothing archived" -- Archive empty state headline
        static var emptyArchiveHeadline: String {
            String(localized: "home.empty.archive.headline", defaultValue: "Nothing archived", comment: "Archive empty state headline")
        }
        /// "Articles you archive will appear here." -- Archive empty state subheadline
        static var emptyArchiveSubheadline: String {
            String(localized: "home.empty.archive.subheadline", defaultValue: "Articles you archive will appear here.", comment: "Archive empty state subheadline")
        }
        /// "No articles yet" -- Empty state headline
        static var emptyNoArticlesHeadline: String {
            String(localized: "home.empty.noArticles.headline", defaultValue: "No articles yet", comment: "Empty state headline")
        }
        /// "Share an article from Safari to get started." -- Empty state subheadline
        static var emptyNoArticlesSubheadline: String {
            String(localized: "home.empty.noArticles.subheadline", defaultValue: "Share an article from Safari to get started.", comment: "Empty state subheadline")
        }
        /// "Nothing read yet" -- Added during step 5 web-wiring pass — same as `home.empty.noUnread.headline`. needs_review.
        static var emptyNoReadHeadline: String {
            String(localized: "home.empty.noRead.headline", defaultValue: "Nothing read yet", comment: "Added during step 5 web-wiring pass — same as `home.empty.noUnread.headline`. needs_review.")
        }
        /// "Articles you finish reading will appear here." -- needs_review.
        static var emptyNoReadSubheadline: String {
            String(localized: "home.empty.noRead.subheadline", defaultValue: "Articles you finish reading will appear here.", comment: "needs_review.")
        }
        /// "Nothing in progress" -- Added during step 5 web-wiring pass — same as `home.empty.noUnread.headline`. needs_review.
        static var emptyNoReadingHeadline: String {
            String(localized: "home.empty.noReading.headline", defaultValue: "Nothing in progress", comment: "Added during step 5 web-wiring pass — same as `home.empty.noUnread.headline`. needs_review.")
        }
        /// "Articles you're currently reading will appear here." -- needs_review.
        static var emptyNoReadingSubheadline: String {
            String(localized: "home.empty.noReading.subheadline", defaultValue: "Articles you're currently reading will appear here.", comment: "needs_review.")
        }
        /// "No results" -- Search empty state headline
        static var emptyNoResultsHeadline: String {
            String(localized: "home.empty.noResults.headline", defaultValue: "No results", comment: "Search empty state headline")
        }
        /// "Try a different search term." -- Search empty state subheadline
        static var emptyNoResultsSubheadline: String {
            String(localized: "home.empty.noResults.subheadline", defaultValue: "Try a different search term.", comment: "Search empty state subheadline")
        }
        /// "Nothing unread" -- Added during step 5 web-wiring pass — Web has a per-filter empty state with no iOS equivalent (iOS doesn't filter the list by read status the same way). needs_review.
        static var emptyNoUnreadHeadline: String {
            String(localized: "home.empty.noUnread.headline", defaultValue: "Nothing unread", comment: "Added during step 5 web-wiring pass — Web has a per-filter empty state with no iOS equivalent (iOS doesn't filter the list by read status the same way). needs_review.")
        }
        /// "Articles you haven't read yet will appear here." -- needs_review.
        static var emptyNoUnreadSubheadline: String {
            String(localized: "home.empty.noUnread.subheadline", defaultValue: "Articles you haven't read yet will appear here.", comment: "needs_review.")
        }
        /// "Loading articles" -- Skeleton loading state
        static var loadingAccessibilityLabel: String {
            String(localized: "home.loading.accessibilityLabel", defaultValue: "Loading articles", comment: "Skeleton loading state")
        }
        /// "Verso" -- Invariant — brand name
        static var navTitle: String {
            String(localized: "home.navTitle", defaultValue: "Verso", comment: "Invariant — brand name")
        }
        /// "Refresh article list" -- Pull-to-refresh
        static var pullToRefreshAccessibilityLabel: String {
            String(localized: "home.pullToRefresh.accessibilityLabel", defaultValue: "Refresh article list", comment: "Pull-to-refresh")
        }
        /// "Cancel" -- Cancel button (keyboard visible)
        static var searchCancel: String {
            String(localized: "home.search.cancel", defaultValue: "Cancel", comment: "Cancel button (keyboard visible)")
        }
        /// "Clear search" -- Clear search button
        static var searchClearAccessibilityLabel: String {
            String(localized: "home.search.clear.accessibilityLabel", defaultValue: "Clear search", comment: "Clear search button")
        }
        /// "Search titles, text, or site…" -- Updated during step 4 view-wiring pass — code's placeholder is more specific than the doc's original 'Search titles…' (search now also matches body text and site name), value corrected to match shipped behaviour.
        static var searchPlaceholder: String {
            String(localized: "home.search.placeholder", defaultValue: "Search titles, text, or site…", comment: "Updated during step 4 view-wiring pass — code's placeholder is more specific than the doc's original 'Search titles…' (search now also matches body text and site name), value corrected to match shipped behaviour.")
        }
        /// "Settings" -- Settings icon button
        static var settingsAccessibilityLabel: String {
            String(localized: "home.settings.accessibilityLabel", defaultValue: "Settings", comment: "Settings icon button")
        }
        /// "Sort newest first" -- Sort toggle accessibility label
        static var sortNewestFirst: String {
            String(localized: "home.sort.newestFirst", defaultValue: "Sort newest first", comment: "Sort toggle accessibility label")
        }
        /// "Sort oldest first" -- Sort toggle accessibility label (active)
        static var sortOldestFirst: String {
            String(localized: "home.sort.oldestFirst", defaultValue: "Sort oldest first", comment: "Sort toggle accessibility label (active)")
        }
        /// "All tags" -- Row that clears the tag selection
        static var tagFilterAllTags: String {
            String(localized: "home.tagFilter.allTags", defaultValue: "All tags", comment: "Row that clears the tag selection")
        }
        /// "Filter by tags" -- Added during step 4 view-wiring pass — tag filtering postdates the original audit. 'Tag' rendered as étiquette/etiqueta (standard software term), not a literal 'mot-clé'/'marcador'.
        static var tagFilterButtonAccessibilityLabel: String {
            String(localized: "home.tagFilter.button.accessibilityLabel", defaultValue: "Filter by tags", comment: "Added during step 4 view-wiring pass — tag filtering postdates the original audit. 'Tag' rendered as étiquette/etiqueta (standard software term), not a literal 'mot-clé'/'marcador'.")
        }
        /// "Close tag filter" -- Close (X) button
        static var tagFilterCloseAccessibilityLabel: String {
            String(localized: "home.tagFilter.close.accessibilityLabel", defaultValue: "Close tag filter", comment: "Close (X) button")
        }
        /// "No matching tags" -- Empty state inside the panel
        static var tagFilterNoMatches: String {
            String(localized: "home.tagFilter.noMatches", defaultValue: "No matching tags", comment: "Empty state inside the panel")
        }
        /// "Search tags…" -- Side panel search field
        static var tagFilterSearchPlaceholder: String {
            String(localized: "home.tagFilter.searchPlaceholder", defaultValue: "Search tags…", comment: "Side panel search field")
        }
        /// "Tags" -- Side panel header
        static var tagFilterTitle: String {
            String(localized: "home.tagFilter.title", defaultValue: "Tags", comment: "Side panel header")
        }
    }
    enum Import {
        /// "Dismiss import sheet" -- Close (X) button itself reuses `addArticle.close.accessibilityLabel` ('Close') — identical wording/affordance across sheets.
        static var closeAccessibilityHint: String {
            String(localized: "import.close.accessibilityHint", defaultValue: "Dismiss import sheet", comment: "Close (X) button itself reuses `addArticle.close.accessibilityLabel` ('Close') — identical wording/affordance across sheets.")
        }
        /// "Done" -- Done state primary button
        static var doneDoneButton: String {
            String(localized: "import.done.doneButton", defaultValue: "Done", comment: "Done state primary button")
        }
        /// "Import Complete" -- Done state headline
        static var doneHeadline: String {
            String(localized: "import.done.headline", defaultValue: "Import Complete", comment: "Done state headline")
        }
        /// "Import Another File" -- Done state secondary button
        static var doneImportAnotherButton: String {
            String(localized: "import.done.importAnotherButton", defaultValue: "Import Another File", comment: "Done state secondary button")
        }
        /// ", {count} skipped" -- ⚠️ plural; see `import.done.summary`.
        static func doneSkippedSuffix(count: Int) -> String {
            String(localized: "import.done.skippedSuffix", defaultValue: ", \(count) skipped", comment: "⚠️ plural; see `import.done.summary`.")
        }
        /// "{count} articles imported" -- ⚠️ plural (this row shows the 'other'/plural form; singular 'one' form authored directly in codegen, same pattern as the other ⚠️-flagged keys). Shipped code composes this with an optional `import.done.skippedSuffix` clause, then a literal '.' — both pieces need independent plural handling since 'imported' and 'skipped' each agree with their own count.
        static func doneSummary(count: Int) -> String {
            String(localized: "import.done.summary", defaultValue: "\(count) articles imported", comment: "⚠️ plural (this row shows the 'other'/plural form; singular 'one' form authored directly in codegen, same pattern as the other ⚠️-flagged keys). Shipped code composes this with an optional `import.done.skippedSuffix` clause, then a literal '.' — both pieces need independent plural handling since 'imported' and 'skipped' each agree with their own count.")
        }
        /// "Import Failed" -- Failed state headline
        static var failedHeadline: String {
            String(localized: "import.failed.headline", defaultValue: "Import Failed", comment: "Failed state headline")
        }
        /// "Import Articles" -- Coincidentally matches `settings.import.rowLabel`'s wording today, but kept as a separate key — a settings row label and a screen headline are different copy slots that could diverge independently.
        static var idleHeadline: String {
            String(localized: "import.idle.headline", defaultValue: "Import Articles", comment: "Coincidentally matches `settings.import.rowLabel`'s wording today, but kept as a separate key — a settings row label and a screen headline are different copy slots that could diverge independently.")
        }
        /// "Set your articles folder in Storage settings before importing." -- Idle state warning, shown only when no articles folder is set
        static var idleNoFolderWarning: String {
            String(localized: "import.idle.noFolderWarning", defaultValue: "Set your articles folder in Storage settings before importing.", comment: "Idle state warning, shown only when no articles folder is set")
        }
        /// "Select Export File" -- Idle state primary CTA
        static var idleSelectFileButton: String {
            String(localized: "import.idle.selectFileButton", defaultValue: "Select Export File", comment: "Idle state primary CTA")
        }
        /// "Import your reading list from GoodLinks, Instapaper, Pocket, Readwise Reader, or Matter." -- Third-party product names invariant.
        static var idleSubtitle: String {
            String(localized: "import.idle.subtitle", defaultValue: "Import your reading list from GoodLinks, Instapaper, Pocket, Readwise Reader, or Matter.", comment: "Third-party product names invariant.")
        }
        /// "Reading file…" -- Parsing state message
        static var parsingMessage: String {
            String(localized: "import.parsing.message", defaultValue: "Reading file…", comment: "Parsing state message")
        }
        /// "Importing articles…" -- Writing state message
        static var writingMessage: String {
            String(localized: "import.writing.message", defaultValue: "Importing articles…", comment: "Writing state message")
        }
    }
    enum Launch {
        /// "Verso" -- Invariant — brand name. Added during step 4 view-wiring pass — `LaunchView.swift` had no UI_COPY entry yet.
        static var brandName: String {
            String(localized: "launch.brandName", defaultValue: "Verso", comment: "Invariant — brand name. Added during step 4 view-wiring pass — `LaunchView.swift` had no UI_COPY entry yet.")
        }
    }
    enum Onboarding {
        /// "Sure, why not" -- Primary button
        static var analyticsConsentAcceptCta: String {
            String(localized: "onboarding.analyticsConsent.acceptCta", defaultValue: "Sure, why not", comment: "Primary button")
        }
        /// "No thanks" -- Secondary button
        static var analyticsConsentDeclineCta: String {
            String(localized: "onboarding.analyticsConsent.declineCta", defaultValue: "No thanks", comment: "Secondary button")
        }
        /// "Help make Verso better" -- Added during step 4 view-wiring pass — missed in the original audit.
        static var analyticsConsentHeadline: String {
            String(localized: "onboarding.analyticsConsent.headline", defaultValue: "Help make Verso better", comment: "Added during step 4 view-wiring pass — missed in the original audit.")
        }
        /// "Share anonymous usage data — no personal info, no article content, ever." -- Subheadline
        static var analyticsConsentSubheadline: String {
            String(localized: "onboarding.analyticsConsent.subheadline", defaultValue: "Share anonymous usage data — no personal info, no article content, ever.", comment: "Subheadline")
        }
        /// "Choose folder…" -- Added ellipsis during step 4 view-wiring pass to match the row-placeholder treatment shipped in code (not a standalone button as the original 'Primary button' location implied).
        static var folderChooseCta: String {
            String(localized: "onboarding.folder.chooseCta", defaultValue: "Choose folder…", comment: "Added ellipsis during step 4 view-wiring pass to match the row-placeholder treatment shipped in code (not a standalone button as the original 'Primary button' location implied).")
        }
        /// "Continue" -- Added during step 4 view-wiring pass — missed in the original audit.
        static var folderContinueCta: String {
            String(localized: "onboarding.folder.continueCta", defaultValue: "Continue", comment: "Added during step 4 view-wiring pass — missed in the original audit.")
        }
        /// "Where should Verso save your articles?" -- Corrected 'store' → 'save' during step 4 view-wiring pass to match shipped code — fr-CA/pt-BR already said 'save' (enregistrer/guardar), so en was the stale one.
        static var folderHeadline: String {
            String(localized: "onboarding.folder.headline", defaultValue: "Where should Verso save your articles?", comment: "Corrected 'store' → 'save' during step 4 view-wiring pass to match shipped code — fr-CA/pt-BR already said 'save' (enregistrer/guardar), so en was the stale one.")
        }
        /// "Using Obsidian? Point Verso to a folder inside your vault and articles will appear there automatically." -- Documented but not yet shown in `OnboardingFolderPickerView.swift` — adding it is a UI change, not just a wiring fix. Tracked as FAB-280, see docs/BACKLOG.md.
        static var folderObsidianTip: String {
            String(localized: "onboarding.folder.obsidianTip", defaultValue: "Using Obsidian? Point Verso to a folder inside your vault and articles will appear there automatically.", comment: "Documented but not yet shown in `OnboardingFolderPickerView.swift` — adding it is a UI change, not just a wiring fix. Tracked as FAB-280, see docs/BACKLOG.md.")
        }
        /// "Verso never uploads your files. They live in your iCloud Drive." -- Added during step 4 view-wiring pass — missed in the original audit.
        static var folderPrivacyNote: String {
            String(localized: "onboarding.folder.privacyNote", defaultValue: "Verso never uploads your files. They live in your iCloud Drive.", comment: "Added during step 4 view-wiring pass — missed in the original audit.")
        }
        /// "Pick a folder in iCloud Drive. Verso saves each article as a Markdown file you can open anywhere." -- Code previously had different wording ('Articles are saved as Markdown files — yours to keep.'); switched to this canonical copy during step 4 view-wiring pass since fr-CA/pt-BR were already translated against it.
        static var folderSubheadline: String {
            String(localized: "onboarding.folder.subheadline", defaultValue: "Pick a folder in iCloud Drive. Verso saves each article as a Markdown file you can open anywhere.", comment: "Code previously had different wording ('Articles are saved as Markdown files — yours to keep.'); switched to this canonical copy during step 4 view-wiring pass since fr-CA/pt-BR were already translated against it.")
        }
        /// "Continue" -- Primary button
        static var themeContinue: String {
            String(localized: "onboarding.theme.continue", defaultValue: "Continue", comment: "Primary button")
        }
        /// "Choose your reading theme" -- Headline
        static var themeHeadline: String {
            String(localized: "onboarding.theme.headline", defaultValue: "Choose your reading theme", comment: "Headline")
        }
        /// "You can change this any time from settings." -- Subheadline
        static var themeSubheadline: String {
            String(localized: "onboarding.theme.subheadline", defaultValue: "You can change this any time from settings.", comment: "Subheadline")
        }
        /// "Here's how it works" -- Headline
        static var tourHeadline: String {
            String(localized: "onboarding.tour.headline", defaultValue: "Here's how it works", comment: "Headline")
        }
        /// "Skip" -- Text button
        static var tourSkip: String {
            String(localized: "onboarding.tour.skip", defaultValue: "Skip", comment: "Text button")
        }
        /// "Start reading" -- Primary button
        static var tourStartReading: String {
            String(localized: "onboarding.tour.startReading", defaultValue: "Start reading", comment: "Primary button")
        }
        /// "Share any article from Safari or your browser to save it instantly." -- Step 1 label
        static var tourStep1: String {
            String(localized: "onboarding.tour.step1", defaultValue: "Share any article from Safari or your browser to save it instantly.", comment: "Step 1 label")
        }
        /// "Open Verso to read. Your list is always in sync with your files." -- Step 2 label
        static var tourStep2: String {
            String(localized: "onboarding.tour.step2", defaultValue: "Open Verso to read. Your list is always in sync with your files.", comment: "Step 2 label")
        }
        /// "Mark articles as read when you're done. They stay in your folder forever." -- Step 3 label
        static var tourStep3: String {
            String(localized: "onboarding.tour.step3", defaultValue: "Mark articles as read when you're done. They stay in your folder forever.", comment: "Step 3 label")
        }
        /// "Get started" -- Primary button
        static var welcomeCta: String {
            String(localized: "onboarding.welcome.cta", defaultValue: "Get started", comment: "Primary button")
        }
        /// "Your articles. Your files." -- Headline
        static var welcomeHeadline: String {
            String(localized: "onboarding.welcome.headline", defaultValue: "Your articles. Your files.", comment: "Headline")
        }
        /// "A quiet place to read. No accounts, no algorithms — just Markdown files in your iCloud Drive." -- Subheadline
        static var welcomeSubheadline: String {
            String(localized: "onboarding.welcome.subheadline", defaultValue: "A quiet place to read. No accounts, no algorithms — just Markdown files in your iCloud Drive.", comment: "Subheadline")
        }
    }
    enum PrivacyPolicy {
        /// "Privacy Policy" -- Same text as `settings.privacyPolicy.rowLabel`, kept as a separate key since a nav title and a row label are different copy slots.
        static var navTitle: String {
            String(localized: "privacyPolicy.navTitle", defaultValue: "Privacy Policy", comment: "Same text as `settings.privacyPolicy.rowLabel`, kept as a separate key since a nav title and a row label are different copy slots.")
        }
    }
    enum ReaderSettings {
        /// "L" -- Accessibility label: 'Large, 20 points' → fr-CA 'Grand, 20 points' / pt-BR 'Grande, 20 pontos'
        static var fontSizeL: String {
            String(localized: "readerSettings.fontSize.l", defaultValue: "L", comment: "Accessibility label: 'Large, 20 points' → fr-CA 'Grand, 20 points' / pt-BR 'Grande, 20 pontos'")
        }
        /// "M" -- Accessibility label: 'Medium, 18 points, default' → fr-CA 'Moyen, 18 points, par défaut' / pt-BR 'Médio, 18 pontos, padrão'
        static var fontSizeM: String {
            String(localized: "readerSettings.fontSize.m", defaultValue: "M", comment: "Accessibility label: 'Medium, 18 points, default' → fr-CA 'Moyen, 18 points, par défaut' / pt-BR 'Médio, 18 pontos, padrão'")
        }
        /// "S" -- Accessibility label: 'Small, 16 points' → fr-CA 'Petit, 16 points' / pt-BR 'Pequeno, 16 pontos'
        static var fontSizeS: String {
            String(localized: "readerSettings.fontSize.s", defaultValue: "S", comment: "Accessibility label: 'Small, 16 points' → fr-CA 'Petit, 16 points' / pt-BR 'Pequeno, 16 pontos'")
        }
        /// "Text size" -- Section label
        static var fontSizeSectionLabel: String {
            String(localized: "readerSettings.fontSize.sectionLabel", defaultValue: "Text size", comment: "Section label")
        }
        /// "XL" -- Accessibility label: 'Extra large, 22 points' → fr-CA 'Très grand, 22 points' / pt-BR 'Extragrande, 22 pontos'
        static var fontSizeXl: String {
            String(localized: "readerSettings.fontSize.xl", defaultValue: "XL", comment: "Accessibility label: 'Extra large, 22 points' → fr-CA 'Très grand, 22 points' / pt-BR 'Extragrande, 22 pontos'")
        }
        /// "XS" -- Abbreviations translated per locale (FR: Très Petit, PT: Super Pequeno). Accessibility label translates regardless: 'Extra small, 14 points' → fr-CA 'Très petit, 14 points' / pt-BR 'Extrapequeno, 14 pontos'
        static var fontSizeXs: String {
            String(localized: "readerSettings.fontSize.xs", defaultValue: "XS", comment: "Abbreviations translated per locale (FR: Très Petit, PT: Super Pequeno). Accessibility label translates regardless: 'Extra small, 14 points' → fr-CA 'Très petit, 14 points' / pt-BR 'Extrapequeno, 14 pontos'")
        }
        /// "XXL" -- Accessibility label: 'Extra extra large, 26 points' → fr-CA 'Très très grand, 26 points' / pt-BR 'Extra extragrande, 26 pontos'
        static var fontSizeXxl: String {
            String(localized: "readerSettings.fontSize.xxl", defaultValue: "XXL", comment: "Accessibility label: 'Extra extra large, 26 points' → fr-CA 'Très très grand, 26 points' / pt-BR 'Extra extragrande, 26 pontos'")
        }
        /// "Airy" -- Option label
        static var lineSpacingAiry: String {
            String(localized: "readerSettings.lineSpacing.airy", defaultValue: "Airy", comment: "Option label")
        }
        /// "Compact" -- Option label
        static var lineSpacingCompact: String {
            String(localized: "readerSettings.lineSpacing.compact", defaultValue: "Compact", comment: "Option label")
        }
        /// "Normal" -- Option label
        static var lineSpacingNormal: String {
            String(localized: "readerSettings.lineSpacing.normal", defaultValue: "Normal", comment: "Option label")
        }
        /// "Relaxed" -- Default
        static var lineSpacingRelaxed: String {
            String(localized: "readerSettings.lineSpacing.relaxed", defaultValue: "Relaxed", comment: "Default")
        }
        /// "Line spacing" -- Section label
        static var lineSpacingSectionLabel: String {
            String(localized: "readerSettings.lineSpacing.sectionLabel", defaultValue: "Line spacing", comment: "Section label")
        }
        /// "Margins" -- Section label
        static var marginsSectionLabel: String {
            String(localized: "readerSettings.margins.sectionLabel", defaultValue: "Margins", comment: "Section label")
        }
        /// "Theme" -- Section label
        static var themeSectionLabel: String {
            String(localized: "readerSettings.theme.sectionLabel", defaultValue: "Theme", comment: "Section label")
        }
        /// "Currently selected" -- VoiceOver hint
        static var themeSelectedHint: String {
            String(localized: "readerSettings.theme.selected.hint", defaultValue: "Currently selected", comment: "VoiceOver hint")
        }
        /// "Reading settings" -- Sheet title
        static var title: String {
            String(localized: "readerSettings.title", defaultValue: "Reading settings", comment: "Sheet title")
        }
    }
    enum Reading {
        /// "Back to reading list" -- Back button
        static var backAccessibilityLabel: String {
            String(localized: "reading.back.accessibilityLabel", defaultValue: "Back to reading list", comment: "Back button")
        }
        /// "Image" -- Added during step 4 view-wiring pass — generic fallback when an article image has no alt text.
        static var bodyImageAccessibilityLabel: String {
            String(localized: "reading.body.image.accessibilityLabel", defaultValue: "Image", comment: "Added during step 4 view-wiring pass — generic fallback when an article image has no alt text.")
        }
        /// "Loading…" -- Added during step 4 view-wiring pass — missed in the original audit.
        static var bodyLoading: String {
            String(localized: "reading.body.loading", defaultValue: "Loading…", comment: "Added during step 4 view-wiring pass — missed in the original audit.")
        }
        /// "Decrease font size" -- Icon button accessibility label
        static var controlsDecreaseFontSize: String {
            String(localized: "reading.controls.decreaseFontSize", defaultValue: "Decrease font size", comment: "Icon button accessibility label")
        }
        /// "Increase font size" -- Icon button accessibility label
        static var controlsIncreaseFontSize: String {
            String(localized: "reading.controls.increaseFontSize", defaultValue: "Increase font size", comment: "Icon button accessibility label")
        }
        /// "Line spacing" -- Icon button accessibility label
        static var controlsLineSpacing: String {
            String(localized: "reading.controls.lineSpacing", defaultValue: "Line spacing", comment: "Icon button accessibility label")
        }
        /// "Double tap to open spacing options" -- VoiceOver hint
        static var controlsLineSpacingHint: String {
            String(localized: "reading.controls.lineSpacing.hint", defaultValue: "Double tap to open spacing options", comment: "VoiceOver hint")
        }
        /// "Margins" -- Icon button accessibility label
        static var controlsMargins: String {
            String(localized: "reading.controls.margins", defaultValue: "Margins", comment: "Icon button accessibility label")
        }
        /// "Double tap to open margin options" -- VoiceOver hint
        static var controlsMarginsHint: String {
            String(localized: "reading.controls.margins.hint", defaultValue: "Double tap to open margin options", comment: "VoiceOver hint")
        }
        /// "Mark as read" -- Icon button accessibility label
        static var controlsMarkAsRead: String {
            String(localized: "reading.controls.markAsRead", defaultValue: "Mark as read", comment: "Icon button accessibility label")
        }
        /// "Mark as unread" -- Icon button accessibility label
        static var controlsMarkAsUnread: String {
            String(localized: "reading.controls.markAsUnread", defaultValue: "Mark as unread", comment: "Icon button accessibility label")
        }
        /// "Dismiss controls" -- Close (X) button itself reuses `addArticle.close.accessibilityLabel` ('Close') — identical wording/affordance across sheets.
        static var controlsSheetCloseAccessibilityHint: String {
            String(localized: "reading.controlsSheet.closeAccessibilityHint", defaultValue: "Dismiss controls", comment: "Close (X) button itself reuses `addArticle.close.accessibilityLabel` ('Close') — identical wording/affordance across sheets.")
        }
        /// "Font size" -- Font-size row label
        static var controlsSheetFontSizeLabel: String {
            String(localized: "reading.controlsSheet.fontSizeLabel", defaultValue: "Font size", comment: "Font-size row label")
        }
        /// "Line spacing" -- Line-spacing row label
        static var controlsSheetLineSpacingLabel: String {
            String(localized: "reading.controlsSheet.lineSpacingLabel", defaultValue: "Line spacing", comment: "Line-spacing row label")
        }
        /// "Theme" -- Icon button accessibility label
        static var controlsTheme: String {
            String(localized: "reading.controls.theme", defaultValue: "Theme", comment: "Icon button accessibility label")
        }
        /// "Double tap to open theme options" -- VoiceOver hint
        static var controlsThemeHint: String {
            String(localized: "reading.controls.theme.hint", defaultValue: "Double tap to open theme options", comment: "VoiceOver hint")
        }
        /// "Pause text-to-speech" -- TTS button accessibility label
        static var controlsTtsPause: String {
            String(localized: "reading.controls.tts.pause", defaultValue: "Pause text-to-speech", comment: "TTS button accessibility label")
        }
        /// "Play text-to-speech" -- TTS button accessibility label
        static var controlsTtsPlay: String {
            String(localized: "reading.controls.tts.play", defaultValue: "Play text-to-speech", comment: "TTS button accessibility label")
        }
        /// "By {author}" -- Added during step 4 view-wiring pass — missed in the original audit. `{author}` is the article's author name as-is (not translated); falls back to `publicationFallback` (source name, also not translated) when author is unavailable, with no 'By'/'Par'/'Por' prefix in that case.
        static func headerByline(author: String) -> String {
            String(localized: "reading.header.byline", defaultValue: "By \(author)", comment: "Added during step 4 view-wiring pass — missed in the original audit. `{author}` is the article's author name as-is (not translated); falls back to `publicationFallback` (source name, also not translated) when author is unavailable, with no 'By'/'Par'/'Por' prefix in that case.")
        }
        /// "Tap anywhere to reveal controls" -- Never shown when VoiceOver is active
        static var immersiveHint: String {
            String(localized: "reading.immersiveHint", defaultValue: "Tap anywhere to reveal controls", comment: "Never shown when VoiceOver is active")
        }
        /// "Open original article" -- Open-externally button
        static var openExternalAccessibilityLabel: String {
            String(localized: "reading.openExternal.accessibilityLabel", defaultValue: "Open original article", comment: "Open-externally button")
        }
        /// "Related" -- Added during step 4 view-wiring pass — missed in the original audit.
        static var relatedArticlesSectionHeader: String {
            String(localized: "reading.relatedArticles.sectionHeader", defaultValue: "Related", comment: "Added during step 4 view-wiring pass — missed in the original audit.")
        }
        /// "No article selected" -- Same placeholder, combined accessibility element
        static var splitViewPlaceholderAccessibilityLabel: String {
            String(localized: "reading.splitView.placeholder.accessibilityLabel", defaultValue: "No article selected", comment: "Same placeholder, combined accessibility element")
        }
        /// "Select an article" -- Added during step 4 view-wiring pass — iPad split view postdates the original audit.
        static var splitViewPlaceholderHeadline: String {
            String(localized: "reading.splitView.placeholder.headline", defaultValue: "Select an article", comment: "Added during step 4 view-wiring pass — iPad split view postdates the original audit.")
        }
    }
    enum Settings {
        /// "Version {version}" -- Row label (links to About page)
        static func aboutVersionRowLabel(version: String) -> String {
            String(localized: "settings.about.versionRowLabel", defaultValue: "Version \(version)", comment: "Row label (links to About page)")
        }
        /// "Share anonymous data" -- Row label, analytics toggle
        static var analyticsRowLabel: String {
            String(localized: "settings.analytics.rowLabel", defaultValue: "Share anonymous data", comment: "Row label, analytics toggle")
        }
        /// "No personal info or article content, ever." -- Row sub-label, analytics toggle
        static var analyticsSubtitle: String {
            String(localized: "settings.analytics.subtitle", defaultValue: "No personal info or article content, ever.", comment: "Row sub-label, analytics toggle")
        }
        /// "Not set" -- Corrected from 'Not configured' to match shipped copy.
        static var folderEmptyValue: String {
            String(localized: "settings.folder.emptyValue", defaultValue: "Not set", comment: "Corrected from 'Not configured' to match shipped copy.")
        }
        /// "Articles folder" -- Corrected from 'Reading folder' to match shipped copy.
        static var folderRowLabel: String {
            String(localized: "settings.folder.rowLabel", defaultValue: "Articles folder", comment: "Corrected from 'Reading folder' to match shipped copy.")
        }
        /// "The quick brown fox jumps over the lazy dog" -- Locale-appropriate pangram, not a literal translation — each locale uses its own classic pangram so every letterform is previewed.
        static var fontPreview: String {
            String(localized: "settings.font.preview", defaultValue: "The quick brown fox jumps over the lazy dog", comment: "Locale-appropriate pangram, not a literal translation — each locale uses its own classic pangram so every letterform is previewed.")
        }
        /// "Font" -- Section label above font list
        static var fontSectionLabel: String {
            String(localized: "settings.font.sectionLabel", defaultValue: "Font", comment: "Section label above font list")
        }
        /// "Size" -- Section label, stepper row
        static var fontSizeSectionLabel: String {
            String(localized: "settings.fontSize.sectionLabel", defaultValue: "Size", comment: "Section label, stepper row")
        }
        /// "{size}pt" -- 'pt' is a standard typographic abbreviation, invariant across locales.
        static func fontSizeValueLabel(size: Int) -> String {
            String(localized: "settings.fontSize.valueLabel", defaultValue: "\(size)pt", comment: "'pt' is a standard typographic abbreviation, invariant across locales.")
        }
        /// "Import Articles" -- Row label
        static var importRowLabel: String {
            String(localized: "settings.import.rowLabel", defaultValue: "Import Articles", comment: "Row label")
        }
        /// "Privacy Policy" -- Distinct row/casing from `about.privacyPolicy.rowLabel` ('Privacy policy') — same destination, surfaced directly in Settings as well as inside the About sub-page; not deduplicated since they're different controls authored independently.
        static var privacyPolicyRowLabel: String {
            String(localized: "settings.privacyPolicy.rowLabel", defaultValue: "Privacy Policy", comment: "Distinct row/casing from `about.privacyPolicy.rowLabel` ('Privacy policy') — same destination, surfaced directly in Settings as well as inside the About sub-page; not deduplicated since they're different controls authored independently.")
        }
        /// "About" -- Section header
        static var sectionAbout: String {
            String(localized: "settings.section.about", defaultValue: "About", comment: "Section header")
        }
        /// "Privacy" -- Section header
        static var sectionPrivacy: String {
            String(localized: "settings.section.privacy", defaultValue: "Privacy", comment: "Section header")
        }
        /// "Reading" -- Corrected — net-new section, didn't exist in original audit.
        static var sectionReading: String {
            String(localized: "settings.section.reading", defaultValue: "Reading", comment: "Corrected — net-new section, didn't exist in original audit.")
        }
        /// "Storage" -- Section header
        static var sectionStorage: String {
            String(localized: "settings.section.storage", defaultValue: "Storage", comment: "Section header")
        }
        /// "Settings" -- Navigation title
        static var title: String {
            String(localized: "settings.title", defaultValue: "Settings", comment: "Navigation title")
        }
    }
    enum Share {
        /// "Cancel" -- Cancel button
        static var cancel: String {
            String(localized: "share.cancel", defaultValue: "Cancel", comment: "Cancel button")
        }
        /// "Cancel" -- Completes extension without writing pending JSON
        static var duplicateCancel: String {
            String(localized: "share.duplicate.cancel", defaultValue: "Cancel", comment: "Completes extension without writing pending JSON")
        }
        /// "Article already saved" -- Share sheet duplicate state
        static var duplicateHeadline: String {
            String(localized: "share.duplicate.headline", defaultValue: "Article already saved", comment: "Share sheet duplicate state")
        }
        /// "Save as copy" -- Appends ` (Copy)` to title (or ` 2` after existing ` (Copy)`) — fr-CA/pt-BR suffix wording TBD in step 7 (e.g. ` (Copie)` / ` (Cópia)`)
        static var duplicateSaveCopy: String {
            String(localized: "share.duplicate.saveCopy", defaultValue: "Save as copy", comment: "Appends ` (Copy)` to title (or ` 2` after existing ` (Copy)`) — fr-CA/pt-BR suffix wording TBD in step 7 (e.g. ` (Copie)` / ` (Cópia)`)")
        }
        /// "This link is already in your library as "{existingTitle}"." -- `{existingTitle}` from existing file frontmatter; fr-CA uses guillemets « » per Québec French convention
        static func duplicateSubheadline(existingTitle: String) -> String {
            String(localized: "share.duplicate.subheadline", defaultValue: "This link is already in your library as \"\(existingTitle)\".", comment: "`{existingTitle}` from existing file frontmatter; fr-CA uses guillemets « » per Québec French convention")
        }
        /// "Saved" -- New file
        static var duplicateSuccessSaved: String {
            String(localized: "share.duplicate.success.saved", defaultValue: "Saved", comment: "New file")
        }
        /// "Updated" -- Replaced existing file
        static var duplicateSuccessUpdated: String {
            String(localized: "share.duplicate.success.updated", defaultValue: "Updated", comment: "Replaced existing file")
        }
        /// "Update existing" -- Primary button
        static var duplicateUpdateExisting: String {
            String(localized: "share.duplicate.updateExisting", defaultValue: "Update existing", comment: "Primary button")
        }
        /// "Dismiss" -- Secondary CTA
        static var errorDismiss: String {
            String(localized: "share.error.dismiss", defaultValue: "Dismiss", comment: "Secondary CTA")
        }
        /// "Couldn't save this article." -- Replaces §8 `share.error.couldNotParse`
        static var errorHeadline: String {
            String(localized: "share.error.headline", defaultValue: "Couldn't save this article.", comment: "Replaces §8 `share.error.couldNotParse`")
        }
        /// "Open Verso to finish setup" -- `Verso` invariant
        static var errorNoFolderCta: String {
            String(localized: "share.error.noFolder.cta", defaultValue: "Open Verso to finish setup", comment: "`Verso` invariant")
        }
        /// "Folder not configured." -- No-folder-configured message
        static var errorNoFolderMessage: String {
            String(localized: "share.error.noFolder.message", defaultValue: "Folder not configured.", comment: "No-folder-configured message")
        }
        /// "Open in Safari" -- Accent color
        static var errorOpenInSafari: String {
            String(localized: "share.error.openInSafari", defaultValue: "Open in Safari", comment: "Accent color")
        }
        /// "The page couldn't be read. You can open it directly in Safari." -- `Safari` invariant
        static var errorSubheadline: String {
            String(localized: "share.error.subheadline", defaultValue: "The page couldn't be read. You can open it directly in Safari.", comment: "`Safari` invariant")
        }
        /// "Loading article preview" -- Loading shimmer
        static var previewLoadingAccessibilityLabel: String {
            String(localized: "share.preview.loading.accessibilityLabel", defaultValue: "Loading article preview", comment: "Loading shimmer")
        }
        /// "Save" -- Save button
        static var saveDefault: String {
            String(localized: "share.save.default", defaultValue: "Save", comment: "Save button")
        }
        /// "Try again" -- Save button (failed)
        static var saveError: String {
            String(localized: "share.save.error", defaultValue: "Try again", comment: "Save button (failed)")
        }
        /// "Saving…" -- Save button (in progress)
        static var saveLoading: String {
            String(localized: "share.save.loading", defaultValue: "Saving…", comment: "Save button (in progress)")
        }
        /// "Saved" -- Save button (done)
        static var saveSuccess: String {
            String(localized: "share.save.success", defaultValue: "Saved", comment: "Save button (done)")
        }
        /// "Save to Verso" -- `Verso` invariant
        static var title: String {
            String(localized: "share.title", defaultValue: "Save to Verso", comment: "`Verso` invariant")
        }
    }
    enum Status {
        /// "Read" -- Badge / accessibility
        static var read: String {
            String(localized: "status.read", defaultValue: "Read", comment: "Badge / accessibility")
        }
        /// "Reading" -- Badge / accessibility
        static var reading: String {
            String(localized: "status.reading", defaultValue: "Reading", comment: "Badge / accessibility")
        }
        /// "Unread" -- Singular agreement (describes one article); also used in filter chips and Reading View
        static var unread: String {
            String(localized: "status.unread", defaultValue: "Unread", comment: "Singular agreement (describes one article); also used in filter chips and Reading View")
        }
    }
    enum Swipe {
        /// "Archive" -- Swipe-left action label
        static var archive: String {
            String(localized: "swipe.archive", defaultValue: "Archive", comment: "Swipe-left action label")
        }
        /// "Delete" -- Red
        static var delete: String {
            String(localized: "swipe.delete", defaultValue: "Delete", comment: "Red")
        }
        /// "Mark Read" -- Added during step 4 view-wiring pass. Distinct copy/casing from `contextMenu.markAsRead` ('Mark as read') — same action, different control, intentionally not deduplicated since the two surfaces were authored with different wording independently.
        static var markRead: String {
            String(localized: "swipe.markRead", defaultValue: "Mark Read", comment: "Added during step 4 view-wiring pass. Distinct copy/casing from `contextMenu.markAsRead` ('Mark as read') — same action, different control, intentionally not deduplicated since the two surfaces were authored with different wording independently.")
        }
        /// "Mark Unread" -- Added during step 4 view-wiring pass. See note on `swipe.markRead`.
        static var markUnread: String {
            String(localized: "swipe.markUnread", defaultValue: "Mark Unread", comment: "Added during step 4 view-wiring pass. See note on `swipe.markRead`.")
        }
        /// "Unarchive" -- Swipe-left action label (archive view)
        static var unarchive: String {
            String(localized: "swipe.unarchive", defaultValue: "Unarchive", comment: "Swipe-left action label (archive view)")
        }
    }
    enum TagsEditor {
        /// "Cancel" -- Toolbar button
        static var cancel: String {
            String(localized: "tagsEditor.cancel", defaultValue: "Cancel", comment: "Toolbar button")
        }
        /// "Comma-separated tags. Stored in the article's YAML so they work with Obsidian." -- `Obsidian` invariant
        static var instructions: String {
            String(localized: "tagsEditor.instructions", defaultValue: "Comma-separated tags. Stored in the article's YAML so they work with Obsidian.", comment: "`Obsidian` invariant")
        }
        /// "e.g. research, design" -- Text field placeholder
        static var placeholder: String {
            String(localized: "tagsEditor.placeholder", defaultValue: "e.g. research, design", comment: "Text field placeholder")
        }
        /// "Save" -- Toolbar button
        static var save: String {
            String(localized: "tagsEditor.save", defaultValue: "Save", comment: "Toolbar button")
        }
        /// "Check folder access or disk space, then try again." -- Alert message
        static var saveFailedMessage: String {
            String(localized: "tagsEditor.saveFailed.message", defaultValue: "Check folder access or disk space, then try again.", comment: "Alert message")
        }
        /// "OK" -- Invariant — standard alert acknowledgement across all three locales
        static var saveFailedOk: String {
            String(localized: "tagsEditor.saveFailed.ok", defaultValue: "OK", comment: "Invariant — standard alert acknowledgement across all three locales")
        }
        /// "Couldn't save tags" -- Alert title
        static var saveFailedTitle: String {
            String(localized: "tagsEditor.saveFailed.title", defaultValue: "Couldn't save tags", comment: "Alert title")
        }
    }
    enum Theme {
        /// "Ink" -- Shared
        static var ink: String {
            String(localized: "theme.ink", defaultValue: "Ink", comment: "Shared")
        }
        /// "Night" -- Shared
        static var night: String {
            String(localized: "theme.night", defaultValue: "Night", comment: "Shared")
        }
        /// "Paper" -- Shared with Settings / Reader Settings
        static var paper: String {
            String(localized: "theme.paper", defaultValue: "Paper", comment: "Shared with Settings / Reader Settings")
        }
        /// "Sepia" -- Shared
        static var sepia: String {
            String(localized: "theme.sepia", defaultValue: "Sepia", comment: "Shared")
        }
    }
    enum Tts {
        /// "Pause" -- Lock screen control
        static var nowPlayingPause: String {
            String(localized: "tts.nowPlaying.pause", defaultValue: "Pause", comment: "Lock screen control")
        }
        /// "Play" -- Lock screen control
        static var nowPlayingPlay: String {
            String(localized: "tts.nowPlaying.play", defaultValue: "Play", comment: "Lock screen control")
        }
        /// "Skip forward" -- Lock screen control
        static var nowPlayingSkipForward: String {
            String(localized: "tts.nowPlaying.skipForward", defaultValue: "Skip forward", comment: "Lock screen control")
        }
    }
    enum Web {
        /// "Change folder" -- Link below the article list to re-pick the library folder
        static var changeFolderLabel: String {
            String(localized: "web.changeFolder.label", defaultValue: "Change folder", comment: "Link below the article list to re-pick the library folder")
        }
        /// "OpenDyslexic" -- Invariant — brand name (see `docs/LOCALIZATION.md` §4). Renamed from the shipped 'Dyslexic' to the actual font name.
        static var fontFamilyDyslexic: String {
            String(localized: "web.fontFamily.dyslexic", defaultValue: "OpenDyslexic", comment: "Invariant — brand name (see `docs/LOCALIZATION.md` §4). Renamed from the shipped 'Dyslexic' to the actual font name.")
        }
        /// "Georgia" -- Invariant — font name.
        static var fontFamilyGeorgia: String {
            String(localized: "web.fontFamily.georgia", defaultValue: "Georgia", comment: "Invariant — font name.")
        }
        /// "Mono" -- Font-family option label
        static var fontFamilyMono: String {
            String(localized: "web.fontFamily.mono", defaultValue: "Mono", comment: "Font-family option label")
        }
        /// "System" -- Font-family option label
        static var fontFamilySystem: String {
            String(localized: "web.fontFamily.system", defaultValue: "System", comment: "Font-family option label")
        }
        /// "Library" -- Reader-screen back link (visible text, the '←' glyph is decorative and not part of the translated string)
        static var readerBackButtonLabel: String {
            String(localized: "web.reader.backButton.label", defaultValue: "Library", comment: "Reader-screen back link (visible text, the '←' glyph is decorative and not part of the translated string)")
        }
        /// "Back to library" -- Link shown alongside the reader-screen error state (the '←' glyph is decorative)
        static var readerBackToLibraryLabel: String {
            String(localized: "web.reader.backToLibrary.label", defaultValue: "Back to library", comment: "Link shown alongside the reader-screen error state (the '←' glyph is decorative)")
        }
        /// "Article not found: {filename}" -- `{filename}` not translated.
        static func readerErrorArticleNotFound(filename: String) -> String {
            String(localized: "web.reader.error.articleNotFound", defaultValue: "Article not found: \(filename)", comment: "`{filename}` not translated.")
        }
        /// "Article not found." -- Reader-screen fallback when article is missing with no specific error
        static var readerErrorFallback: String {
            String(localized: "web.reader.error.fallback", defaultValue: "Article not found.", comment: "Reader-screen fallback when article is missing with no specific error")
        }
        /// "Failed to load article" -- Reader-screen generic load failure (caught exception, no specific message)
        static var readerErrorLoadFailed: String {
            String(localized: "web.reader.error.loadFailed", defaultValue: "Failed to load article", comment: "Reader-screen generic load failure (caught exception, no specific message)")
        }
        /// "No folder selected. Go back and choose your library folder." -- Distinct from `error.noFolder.*` (home-screen full error view, headline/subheadline/cta) — this is a single inline string on the reader page.
        static var readerErrorNoFolder: String {
            String(localized: "web.reader.error.noFolder", defaultValue: "No folder selected. Go back and choose your library folder.", comment: "Distinct from `error.noFolder.*` (home-screen full error view, headline/subheadline/cta) — this is a single inline string on the reader page.")
        }
        /// "Folder permission denied. Go back and re-select your library." -- Reader-screen error when folder permission was revoked
        static var readerErrorPermissionDenied: String {
            String(localized: "web.reader.error.permissionDenied", defaultValue: "Folder permission denied. Go back and re-select your library.", comment: "Reader-screen error when folder permission was revoked")
        }
        /// "Hide controls" -- Reader-screen 'Aa' button tooltip when controls are visible
        static var readerToggleControlsHide: String {
            String(localized: "web.reader.toggleControls.hide", defaultValue: "Hide controls", comment: "Reader-screen 'Aa' button tooltip when controls are visible")
        }
        /// "Show controls" -- Reader-screen 'Aa' button tooltip when controls are hidden
        static var readerToggleControlsShow: String {
            String(localized: "web.reader.toggleControls.show", defaultValue: "Show controls", comment: "Reader-screen 'Aa' button tooltip when controls are hidden")
        }
        /// "Browser not supported" -- Full-screen notice when File System Access API is unavailable
        static var unsupportedBrowserHeadline: String {
            String(localized: "web.unsupportedBrowser.headline", defaultValue: "Browser not supported", comment: "Full-screen notice when File System Access API is unavailable")
        }
        /// "Verso Web uses the File System Access API, which requires Chrome or Edge 86+. Please open this page in a supported browser." -- `Verso Web`, `File System Access API`, `Chrome`, `Edge` invariant.
        static var unsupportedBrowserSubheadline: String {
            String(localized: "web.unsupportedBrowser.subheadline", defaultValue: "Verso Web uses the File System Access API, which requires Chrome or Edge 86+. Please open this page in a supported browser.", comment: "`Verso Web`, `File System Access API`, `Chrome`, `Edge` invariant.")
        }
    }
}
