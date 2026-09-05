import SwiftUI
import CoreData

struct ArticleReaderView: View {
    let article: Article
    /// When embedded in `NavigationSplitView` detail, clears selection instead of popping a nonexistent stack frame.
    var onRequestClose: (() -> Void)?
    /// Opens another article from “Related” while staying in the split detail column.
    var onSelectRelatedArticle: ((Article) -> Void)?

    @State private var scrollOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    @State private var screenHeight: CGFloat = UIScreen.main.bounds.height
    @State private var isChromeVisible: Bool = true
    /// FAB-307 / accessibility-specs.md §5.3: chrome must never hide while VoiceOver is running.
    /// Seeded from the live value so a VoiceOver user who deep-links straight into the reader
    /// gets the right behavior on the very first tap, not just after the notification below fires.
    @State private var isVoiceOverRunning: Bool = UIAccessibility.isVoiceOverRunning
    @State private var showFontControls: Bool = false
    @State private var showThemeControls: Bool = false
    @State private var parsedContent: String = ""
    @State private var isPillVisible: Bool = false
    @State private var relatedArticles: [Article] = []
    @State private var isTTSActive: Bool = false
    @StateObject private var ttsService = TTSService()
    /// Leading spacer height to align saved read position (see `scroll_position` frontmatter).
    @State private var restorePadHeight: CGFloat = 0
    @State private var didApplyScrollRestore = false
    @State private var pendingRestoreFraction: Double?
    @State private var scrollSaveTask: Task<Void, Never>?
    @State private var lastPersistedScroll: Double = -1
    @State private var showTagsEditor = false
    @State private var confirmDelete = false

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var readingPreferences: ReadingPreferencesService
    @EnvironmentObject var folderBookmarkService: FolderBookmarkService
    @EnvironmentObject var adoptionNoticeService: AdoptionNoticeService
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var colors: ThemeColors { themeManager.colors }

    private var scrollProgress: Double {
        Self.scrollFraction(offset: scrollOffset, contentHeight: contentHeight, viewportHeight: screenHeight)
    }

    private var lineSpacingValue: CGFloat {
        // Compact=1.2, Normal=1.5, Relaxed=1.75, Airy=2.0
        let multipliers: [CGFloat] = [1.2, 1.5, 1.75, 2.0]
        return readingPreferences.fontSize * (multipliers[readingPreferences.lineSpacing] - 1)
    }

    /// Matches `ReadingBottomBar`: main row 56pt, + TTS divider + controls when active; plus comfort gap below.
    private var readingBottomBarContentHeight: CGFloat {
        let base: CGFloat = isTTSActive ? 101 : 56
        return base + VersoSpacing.xs
    }

    /// FAB-333: the reading column's horizontal padding was a flat 40pt regardless of in-app
    /// font size, so a fixed-width screen gave back proportionally less room as the user sized
    /// text up -- the measure collapsed hardest exactly where it mattered most. Holds today's
    /// 40pt through the default size (`BodySize.md`, 18pt) and below, unchanged, then tapers
    /// linearly down to `VersoSpacing.md` (16pt) as size approaches the top of the scale
    /// (`BodySize.xxl`, 26pt) -- reclaiming real width at the sizes where it was scarcest.
    /// Deliberately size-only, not font-family-aware: OpenDyslexic is visually wider than
    /// Georgia/New York at the same nominal size, but giving it its own mapping means making
    /// `BodySize` per-family (a bigger change) rather than guessing an unverified width
    /// multiplier here. See FAB-333 in docs/DONE.md.
    private var readingHorizontalPadding: CGFloat {
        let base: CGFloat = 40
        let floor: CGFloat = VersoSpacing.md
        let defaultSize = VersoTypography.Reading.BodySize.md.rawValue   // 18
        let maxSize = VersoTypography.Reading.BodySize.xxl.rawValue      // 26
        guard readingPreferences.fontSize > defaultSize else { return base }
        let t = min(1, (readingPreferences.fontSize - defaultSize) / (maxSize - defaultSize))
        return base - (base - floor) * t
    }

    /// Visible scroll fraction; short articles fit in less than one viewport so we interpolate from drag distance instead.
    private static func scrollFraction(offset: CGFloat, contentHeight: CGFloat, viewportHeight: CGFloat) -> Double {
        let o = max(0, offset)
        guard contentHeight.isFinite, viewportHeight.isFinite else { return 0 }
        let v = max(viewportHeight, 1)
        let c = max(contentHeight, 1)
        let scrollable = c - v
        if scrollable <= 1 {
            let denom = max(v * 0.45, 120)
            return min(1, Double(o / denom))
        }
        return min(1, max(0, Double(o / scrollable)))
    }

    private func evaluateReadCompletion(scrollFraction: Double) {
        if scrollFraction >= 0.95 {
            advanceStatus(to: .read)
        }
    }

    private func applyScrollMetrics(offset: CGFloat, contentH: CGFloat, viewportH: CGFloat) {
        scrollOffset = offset
        contentHeight = contentH
        screenHeight = viewportH
        let frac = Self.scrollFraction(offset: offset, contentHeight: contentH, viewportHeight: viewportH)
        evaluateReadCompletion(scrollFraction: frac)
        scheduleScrollPersist(fraction: frac)
    }

    var body: some View {
        ZStack(alignment: .top) {
            colors.background.ignoresSafeArea()

            ScrollViewReader { proxy in
            ScrollView {
                HStack(alignment: .top, spacing: 0) {
                    Spacer(minLength: 0)
                    VStack(alignment: .leading, spacing: 40) {
                        Color.clear
                            .frame(height: restorePadHeight)
                            .id("verscroll")
                        ArticleHeader(
                            title: article.title,
                            author: article.readerDisplayAuthor,
                            publicationFallback: article.readerPublicationFallback,
                            date: article.dateAdded,
                            readTime: estimatedReadTime(for: parsedContent),
                            fontFamily: readingPreferences.fontFamily
                        )

                        articleBody

                        if !relatedArticles.isEmpty {
                            RelatedArticlesSection(articles: relatedArticles, onSelectArticle: onSelectRelatedArticle)
                        }
                    }
                    .frame(maxWidth: 680, alignment: .leading)
                    .padding(.horizontal, readingHorizontalPadding)
                    // FAB-317: the `44` reserves ReadingTopBar's own height -- only while it's
                    // actually visible. The bar itself fades via `.opacity()` (ReadingChrome.swift)
                    // without ever collapsing its frame, so this is what makes hiding it actually
                    // reclaim the space, mirroring how the bottom bar's height already collapses to
                    // 0 in its `.safeAreaInset`. Animates for free: the tap handler below already
                    // wraps `isChromeVisible.toggle()` in `withAnimation`, and this reads that same
                    // state directly.
                    .padding(.top, (isChromeVisible ? 44 : 0) + safeAreaTop + 24)
                    .padding(.bottom, readingBottomBarContentHeight + safeAreaBottom + 24)
                    // Critical: ScrollView proposes unbounded vertical space; intrinsic height drives backing UIScrollView contentSize.
                    .fixedSize(horizontal: false, vertical: true)
                    .overlay(alignment: .topLeading) {
                        // Non-zero frame so the bridge view stays in the scroll content hierarchy (0×0 can skip layout / break KVO).
                        ScrollViewScrollMetricsTracker(onScrollMetrics: applyScrollMetrics)
                            .frame(width: 1, height: 1)
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                    }
                    Spacer(minLength: 0)
                }
            }
            .onChange(of: contentHeight) { newHeight in
                guard !didApplyScrollRestore,
                      let f = pendingRestoreFraction,
                      newHeight > 0, screenHeight > 0 else { return }
                let scrollable = CGFloat(max(0, newHeight - screenHeight))
                guard scrollable > 1 else {
                    didApplyScrollRestore = true
                    pendingRestoreFraction = nil
                    return
                }
                restorePadHeight = CGFloat(f) * scrollable
            }
            .onChange(of: restorePadHeight) { newPad in
                guard newPad > 0, !didApplyScrollRestore else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                    proxy.scrollTo("verscroll", anchor: .top)
                    didApplyScrollRestore = true
                    pendingRestoreFraction = nil
                }
            }
            .onTapGesture {
                // FAB-307 / accessibility-specs.md §5.3: chrome must never hide while VoiceOver
                // is running -- there's no separate auto-hide timer in this app, the tap gesture
                // is the only thing that ever hides it, so this is the one place to guard.
                guard !isVoiceOverRunning else { return }
                let enteringImmersive = isChromeVisible
                let toggleChrome = {
                    isChromeVisible.toggle()
                    if isChromeVisible {
                        isPillVisible = false
                    } else if !hasShownImmersiveHint {
                        isPillVisible = true
                        markImmersiveHintShown()
                    }
                }
                if reduceMotion {
                    toggleChrome()
                } else {
                    withAnimation(.easeOut(duration: 0.3)) {
                        toggleChrome()
                    }
                }
                AnalyticsService.shared.track("reader.immersiveModeToggled", parameters: ["enabled": enteringImmersive ? "true" : "false"])
            }
            .onReceive(NotificationCenter.default.publisher(for: UIAccessibility.voiceOverStatusDidChangeNotification)) { _ in
                isVoiceOverRunning = UIAccessibility.isVoiceOverRunning
                if isVoiceOverRunning {
                    // VoiceOver just turned on mid-session: bring chrome back immediately rather
                    // than waiting for the next tap.
                    isChromeVisible = true
                    isPillVisible = false
                }
            }
            }

            VStack(spacing: 0) {
                ReadingTopBar(
                    title: article.title,
                    onBack: closeReader,
                    isVisible: $isChromeVisible
                ) {
                    readingMenuContent
                }
                .padding(.top, safeAreaTop)
                Spacer()
            }

            if isPillVisible {
                VStack {
                    Spacer()
                    // FAB-318: was `.padding(.bottom, 80)`, which floated the pill mid-screen
                    // over whatever body text happened to be there -- it only ever shows on
                    // first entering immersive mode, exactly when the bottom bar's own frame
                    // has collapsed to 0, so anchoring it near the true bottom safe area (where
                    // the bar used to sit) keeps it clear of the reading column regardless of
                    // scroll position.
                    ImmersiveHintPill(isVisible: $isPillVisible)
                        .padding(.bottom, safeAreaBottom + VersoSpacing.lg)
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            ReadingBottomBar(
                scrollProgress: scrollProgress,
                onControls: { showFontControls = true },
                onTheme: { showThemeControls = true },
                tts: ttsService,
                isTTSActive: isTTSActive,
                onToggleTTS: toggleTTS,
                isVisible: $isChromeVisible
            )
            .padding(.bottom, VersoSpacing.xs)
            .frame(height: isChromeVisible ? readingBottomBarContentHeight : 0)
            .frame(maxWidth: .infinity)
            // Padded region above must be opaque; extend through home indicator so article text cannot show through.
            .background(colors.background.ignoresSafeArea(edges: .bottom))
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showFontControls) {
            ReadingControls(variant: .font, fontSize: $readingPreferences.fontSize, lineSpacing: $readingPreferences.lineSpacing)
                .presentationDetents([.height(218)])
                .presentationDragIndicator(.hidden)
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showThemeControls) {
            ReadingControls(variant: .theme, fontSize: $readingPreferences.fontSize, lineSpacing: $readingPreferences.lineSpacing)
                .presentationDetents([.height(168)])
                .presentationDragIndicator(.hidden)
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showTagsEditor) {
            ArticleTagsEditorSheet(article: article)
                .environmentObject(themeManager)
                .environmentObject(folderBookmarkService)
                .environment(\.managedObjectContext, viewContext)
        }
        .confirmationDialog(
            L10n.Dialog.deleteArticleTitle(title: article.title),
            isPresented: $confirmDelete,
            titleVisibility: .visible
        ) {
            Button(L10n.Dialog.deleteArticleConfirm, role: .destructive, action: deleteArticleAndClose)
            Button(L10n.Dialog.deleteArticleCancel, role: .cancel) {}
        } message: {
            Text(L10n.Dialog.deleteArticleMessage)
        }
        .task {
            if let s = article.scrollPosition?.doubleValue {
                lastPersistedScroll = s
            }
            pendingRestoreFraction = article.scrollPosition?.doubleValue
            loadContent()
            advanceStatus(to: .reading)
            AnalyticsService.shared.track("article.opened")
            relatedArticles = await RelatedArticlesService().related(to: article, in: viewContext)
        }
        .onDisappear {
            scrollSaveTask?.cancel()
            ttsService.stop()
            persistScrollToDisk(
                Self.scrollFraction(offset: scrollOffset, contentHeight: contentHeight, viewportHeight: screenHeight),
                force: true
            )
        }
    }

    private var safeAreaTop: CGFloat {
        (UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top) ?? 0
    }

    private var safeAreaBottom: CGFloat {
        (UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom) ?? 0
    }

    private var parsedNodes: [MarkdownNode] {
        MarkdownParser.parse(parsedContent)
    }

    private var ttsParagraphs: [(index: Int, text: String)] {
        parsedNodes.enumerated().compactMap { offset, node in
            guard case .paragraph = node else { return nil }
            return (index: offset, text: node.plainText)
        }
    }

    @ViewBuilder
    private var articleBody: some View {
        if parsedContent.isEmpty {
            Text(L10n.Reading.bodyLoading)
                .font(.custom(readingPreferences.fontFamily, size: readingPreferences.fontSize))
                .foregroundColor(colors.textSecondary)
        } else {
            MarkdownBodyView(
                nodes: parsedNodes,
                fontFamily: readingPreferences.fontFamily,
                fontSize: readingPreferences.fontSize,
                lineSpacingValue: lineSpacingValue,
                colors: colors,
                highlightedParagraphIndex: isTTSActive ? ttsParagraphs[safe: ttsService.currentParagraphIndex]?.index : nil,
                baseDirectoryURL: article.filePath.isEmpty ? nil : URL(fileURLWithPath: article.filePath).deletingLastPathComponent(),
                onHighlightAction: applyHighlightChange
            )
        }
    }

    /// Splices one paragraph's updated raw text back into the full in-memory article body and
    /// persists it, replacing exactly the source lines `lineRange` names.
    ///
    /// FAB-303 step 1: replaces FAB-54's original literal-text splice
    /// (`parsedContent.range(of: oldRawText)`), which targeted the wrong paragraph whenever its
    /// exact text repeated elsewhere in the article -- an exact line range can't have that
    /// ambiguity, since `MarkdownParser` reports precisely which source lines it consumed for
    /// this paragraph.
    private func applyHighlightChange(lineRange: ClosedRange<Int>, newRawText: String) {
        var lines = parsedContent.components(separatedBy: "\n")
        guard lineRange.lowerBound >= 0, lineRange.upperBound < lines.count else { return }
        lines.replaceSubrange(lineRange, with: newRawText.components(separatedBy: "\n"))
        let updated = lines.joined(separator: "\n")
        parsedContent = updated
        guard !article.filePath.isEmpty else { return }
        try? MarkdownWriter.updateBody(updated, for: article.filePath)
    }

    private func loadContent() {
        let filePath = article.filePath
        guard !filePath.isEmpty else { return }
        let fileURL = URL(fileURLWithPath: filePath)
        guard let folderURL = folderBookmarkService.folderURL else { return }
        let accessed = folderURL.startAccessingSecurityScopedResource()
        defer { if accessed { folderURL.stopAccessingSecurityScopedResource() } }
        if let parsed = try? MarkdownReader.read(fileURL: fileURL) {
            parsedContent = HTMLToMarkdownConverter.sanitizeMarkdownBody(parsed.contentMarkdown, articleTitle: article.title)
        }
    }

    private func advanceStatus(to status: Article.Status) {
        let order: [Article.Status] = [.unread, .reading, .read]
        guard let current = order.firstIndex(of: article.statusEnum),
              let target = order.firstIndex(of: status),
              current < target else { return }
        article.statusEnum = status
        try? viewContext.save()
        persistStatusToMarkdownFile(status)
        if status == .read {
            AnalyticsService.shared.track("article.readCompleted")
        }
    }

    /// Runs the FAB-290 one-time adoption for `article`'s file if it still needs one (manually
    /// added, no frontmatter or no `title`), updates the in-memory `filePath` to the renamed file,
    /// and surfaces the one-time notice. Call before any frontmatter write-back below.
    private func adoptIfNeeded(folderURL: URL) {
        guard let newURL = try? MarkdownWriter.adoptIfNeeded(fileURL: URL(fileURLWithPath: article.filePath), in: folderURL) else { return }
        article.filePath = newURL.path
        adoptionNoticeService.notify()
    }

    /// Matches list swipe semantics: YAML is source of truth for rebuilds (`ArticleLibraryService`); keep file in sync.
    private func persistStatusToMarkdownFile(_ status: Article.Status) {
        guard let folderURL = folderBookmarkService.folderURL else { return }
        guard !article.filePath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let accessed = folderURL.startAccessingSecurityScopedResource()
        defer { if accessed { folderURL.stopAccessingSecurityScopedResource() } }
        adoptIfNeeded(folderURL: folderURL)
        try? viewContext.save() // durably persist the FAB-290 rename even if adoption is the only change this call makes
        let path = article.filePath.trimmingCharacters(in: .whitespacesAndNewlines)
        try? MarkdownWriter.updateStatus(status, for: path)
    }

    // MARK: - Top bar `⋯` menu (FAB-299)

    @ViewBuilder
    private var readingMenuContent: some View {
        Button(action: toggleReadStatusAndClose) {
            let isRead = article.statusEnum == .read
            Label(
                isRead ? L10n.ContextMenu.markAsUnread : L10n.ContextMenu.markAsRead,
                systemImage: isRead ? "circle" : "checkmark.circle"
            )
        }
        Button {
            showTagsEditor = true
        } label: {
            Label(L10n.ContextMenu.addTags, systemImage: "tag")
        }
        if let url = article.url {
            Button {
                UIApplication.shared.open(url)
            } label: {
                // `openExternalAccessibilityLabel` was pre-authored for this icon button
                // (`reading.openExternal.accessibilityLabel`) but never wired to any actual
                // string in code -- the old ReadingChrome button used a hardcoded, unlocalized
                // "Open in browser". Reused here for both the menu item's visible text and its
                // implicit accessible name, same pattern as FAB-297's unarchive strings.
                Label(L10n.Reading.openExternalAccessibilityLabel, systemImage: "arrow.up.right")
            }
            ShareLink(item: url) {
                Label(L10n.Reading.menuShare, systemImage: "square.and.arrow.up")
            }
        }
        if article.archived {
            Button(action: unarchiveAndClose) {
                Label(L10n.ContextMenu.unarchive, systemImage: "tray.and.arrow.up")
            }
        } else {
            Button(action: archiveAndClose) {
                Label(L10n.ContextMenu.archive, systemImage: "archivebox")
            }
        }
        Divider()
        Button(role: .destructive) {
            confirmDelete = true
        } label: {
            Label(L10n.ContextMenu.delete, systemImage: "trash")
        }
    }

    /// Mirrors the back button's own dismissal: `onRequestClose` when embedded in
    /// `NavigationSplitView` detail (clears selection instead of popping a nonexistent stack
    /// frame), `dismiss()` otherwise. Archive, Delete, and Mark-as-unread all return to the list
    /// after acting (confirmed UX decision) since the article is no longer where the reader is
    /// showing it from.
    private func closeReader() {
        if let onRequestClose {
            onRequestClose()
        } else {
            dismiss()
        }
    }

    /// Toggles read/unread directly (not via `advanceStatus`, which refuses to move backwards by
    /// design) and dismisses. Deliberate even for "mark as read": `advanceStatus` already fires
    /// `.read` at 95% scroll, and dismissing keeps this action's semantics consistent with
    /// "mark as unread" rather than leaving the reader open for scroll to silently re-advance it
    /// (moot here since neither direction can be scroll-reverted, but keeps one mental model for
    /// both directions of this menu item). No race with the `onDisappear` scroll-position write:
    /// that only ever touches `scroll_position`, never `status`.
    private func toggleReadStatusAndClose() {
        if let folderURL = folderBookmarkService.folderURL {
            adoptIfNeeded(folderURL: folderURL)
        }
        let newStatus: Article.Status = article.statusEnum == .read ? .unread : .read
        article.statusEnum = newStatus
        try? viewContext.save()
        try? MarkdownWriter.updateStatus(newStatus, for: article.filePath)
        closeReader()
    }

    /// Reader-scoped mirror of `ArticleListView.archiveArticle` (FAB-297) -- archiving never
    /// touches `status`, read state and archived state are orthogonal.
    private func archiveAndClose() {
        guard let folderURL = folderBookmarkService.folderURL else { return }
        do {
            adoptIfNeeded(folderURL: folderURL)
            let destination = try MarkdownWriter.archive(filePath: article.filePath, in: folderURL)
            let archivedAt = Date()
            try MarkdownWriter.updateArchived(true, archivedAt: archivedAt, for: destination.path)
            article.filePath = destination.path
            article.archived = true
            article.archivedAt = archivedAt
            try viewContext.save()
        } catch {
            // silently ignore — matches ArticleListView.archiveArticle's existing behaviour
        }
        closeReader()
    }

    /// Reader-scoped mirror of `ArticleListView.unarchiveArticle` (FAB-297).
    private func unarchiveAndClose() {
        guard let folderURL = folderBookmarkService.folderURL else { return }
        do {
            adoptIfNeeded(folderURL: folderURL)
            let destination = try MarkdownWriter.unarchive(filePath: article.filePath, in: folderURL)
            try MarkdownWriter.updateArchived(false, archivedAt: nil, for: destination.path)
            article.filePath = destination.path
            article.archived = false
            article.archivedAt = nil
            try viewContext.save()
        } catch {
            // silently ignore — matches archiveAndClose's existing behaviour
        }
        closeReader()
    }

    /// Permanently deletes the article's `.md` file (and `.media` sidecar) plus its Core Data
    /// row in the same transaction, then returns to the list. Only reachable after the
    /// `.confirmationDialog` above -- there is deliberately no undo.
    private func deleteArticleAndClose() {
        try? MarkdownWriter.delete(at: article.filePath)
        viewContext.delete(article)
        try? viewContext.save()
        closeReader()
    }

    private func scheduleScrollPersist(fraction: Double) {
        scrollSaveTask?.cancel()
        scrollSaveTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 450_000_000)
            guard !Task.isCancelled else { return }
            persistScrollToDisk(fraction, force: false)
        }
    }

    private func persistScrollToDisk(_ fraction: Double, force: Bool) {
        if !force, lastPersistedScroll >= 0, abs(fraction - lastPersistedScroll) < 0.02 {
            return
        }
        lastPersistedScroll = fraction
        guard let folderURL = folderBookmarkService.folderURL else { return }
        guard !article.filePath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let accessed = folderURL.startAccessingSecurityScopedResource()
        defer { if accessed { folderURL.stopAccessingSecurityScopedResource() } }
        // Scroll-position auto-save fires moments after opening a file, so this is usually the
        // first write-back a manually-added article sees — the one-time adoption commit (FAB-290).
        adoptIfNeeded(folderURL: folderURL)
        let path = article.filePath.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            try MarkdownWriter.updateScrollPosition(fraction, for: path)
            article.scrollPosition = NSNumber(value: fraction)
            try? viewContext.save()
        } catch {
            // Best-effort; iCloud or sandbox may occasionally fail
        }
    }

    private func toggleTTS() {
        if isTTSActive {
            ttsService.stop()
            isTTSActive = false
        } else {
            isTTSActive = true
            let texts = ttsParagraphs.map(\.text)
            guard !texts.isEmpty else { return }
            ttsService.start(paragraphs: texts, from: 0)
        }
    }

    // MARK: - Immersive hint (FAB-307)

    private static let hasShownImmersiveHintKey = "hasShownImmersiveHint"

    private var hasShownImmersiveHint: Bool {
        UserDefaults.standard.bool(forKey: Self.hasShownImmersiveHintKey)
    }

    /// Only ever called from the non-VoiceOver branch of the tap gesture above, so this
    /// structurally satisfies accessibility-specs.md §5.3's "must not be written during a
    /// VoiceOver session" -- there's no path here while `isVoiceOverRunning` is true.
    private func markImmersiveHintShown() {
        UserDefaults.standard.set(true, forKey: Self.hasShownImmersiveHintKey)
    }

    private func estimatedReadTime(for text: String) -> Int? {
        // Centralized in ReadingEstimate (WPM = 220, content-language word count). See docs/LOCALIZATION.md §3.
        ReadingEstimate.minutes(for: text)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    struct PreviewWrapper: View {
        var body: some View {
            let context = CoreDataStackValue.preview.persistentContainer.viewContext
            let article = Article(context: context)
            article.id = UUID()
            article.title = "The Quiet Revolution in How We Read Long-Form Content Online"
            article.source = "The Atlantic"
            article.dateAdded = Date()
            article.filePath = ""
            article.status = "unread"
            return ArticleReaderView(article: article)
                .environmentObject(ThemeManager())
                .environmentObject(ReadingPreferencesService())
                .environment(\.managedObjectContext, context)
        }
    }
    return PreviewWrapper()
}
