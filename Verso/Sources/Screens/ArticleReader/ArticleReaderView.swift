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
                            readTime: estimatedReadTime(for: parsedContent)
                        )

                        articleBody

                        if !relatedArticles.isEmpty {
                            RelatedArticlesSection(articles: relatedArticles, onSelectArticle: onSelectRelatedArticle)
                        }
                    }
                    .frame(maxWidth: 680, alignment: .leading)
                    .padding(.horizontal, 40)
                    .padding(.top, 44 + safeAreaTop + 24)
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
                let enteringImmersive = isChromeVisible
                if reduceMotion {
                    isChromeVisible.toggle()
                    isPillVisible = !isChromeVisible
                } else {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isChromeVisible.toggle()
                        isPillVisible = !isChromeVisible
                    }
                }
                AnalyticsService.shared.track("reader.immersiveModeToggled", parameters: ["enabled": enteringImmersive ? "true" : "false"])
            }
            }

            VStack(spacing: 0) {
                ReadingTopBar(
                    title: article.title,
                    onBack: {
                        if let onRequestClose {
                            onRequestClose()
                        } else {
                            dismiss()
                        }
                    },
                    onOpenExternal: {
                        if let url = article.url {
                            UIApplication.shared.open(url)
                        }
                    },
                    onEditTags: { showTagsEditor = true },
                    isVisible: $isChromeVisible
                )
                .padding(.top, safeAreaTop)
                Spacer()
            }

            if isPillVisible {
                VStack {
                    Spacer()
                    ImmersiveHintPill(isVisible: $isPillVisible)
                        .padding(.bottom, 80)
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
                baseDirectoryURL: article.filePath.isEmpty ? nil : URL(fileURLWithPath: article.filePath).deletingLastPathComponent()
            )
        }
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
