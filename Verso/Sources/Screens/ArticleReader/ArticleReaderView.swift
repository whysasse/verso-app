import SwiftUI

/// Offset + full content height from one reading so preference updates stay in sync (avoids bar stuck at 0).
private struct ReaderScrollContentPreference: Equatable {
    var scrollOffsetY: CGFloat
    var contentHeight: CGFloat
}

private struct ReaderScrollContentKey: PreferenceKey {
    static var defaultValue = ReaderScrollContentPreference(scrollOffsetY: 0, contentHeight: 0)
    static func reduce(value: inout ReaderScrollContentPreference, nextValue: () -> ReaderScrollContentPreference) {
        value = nextValue()
    }
}

private struct ViewportHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ArticleReaderView: View {
    let article: Article

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

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var readingPreferences: ReadingPreferencesService
    @EnvironmentObject var folderBookmarkService: FolderBookmarkService
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

    var body: some View {
        ZStack(alignment: .top) {
            colors.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    ArticleHeader(
                        title: article.title,
                        author: article.readerDisplayAuthor,
                        publicationFallback: article.readerPublicationFallback,
                        date: article.dateAdded,
                        readTime: estimatedReadTime(for: parsedContent)
                    )

                    articleBody

                    if !relatedArticles.isEmpty {
                        RelatedArticlesSection(articles: relatedArticles)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 44 + safeAreaTop + 24)
                .padding(.bottom, readingBottomBarContentHeight + safeAreaBottom + 24)
                // Critical: ScrollView proposes unbounded vertical space; without this the background
                // GeometryReader only sees viewport height → scroll progress denominator ≤ 0 and the bar stays empty.
                .fixedSize(horizontal: false, vertical: true)
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(
                                key: ReaderScrollContentKey.self,
                                value: ReaderScrollContentPreference(
                                    scrollOffsetY: max(0, -proxy.frame(in: .named("scroll")).minY),
                                    contentHeight: proxy.size.height
                                )
                            )
                    }
                )
            }
            .coordinateSpace(name: "scroll")
            .background(
                GeometryReader { viewport in
                    Color.clear.preference(key: ViewportHeightKey.self, value: viewport.size.height)
                }
            )
            .onPreferenceChange(ReaderScrollContentKey.self) { metrics in
                let y = max(0, metrics.scrollOffsetY)
                let h = metrics.contentHeight
                scrollOffset = y
                contentHeight = h
                evaluateReadCompletion(scrollFraction: Self.scrollFraction(offset: y, contentHeight: h, viewportHeight: screenHeight))
            }
            .onPreferenceChange(ViewportHeightKey.self) { value in
                guard value > 0, value.isFinite else { return }
                screenHeight = value
                evaluateReadCompletion(scrollFraction: Self.scrollFraction(offset: scrollOffset, contentHeight: contentHeight, viewportHeight: value))
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

            VStack(spacing: 0) {
                ReadingTopBar(
                    title: article.title,
                    onBack: { dismiss() },
                    onOpenExternal: {
                        if let url = article.url {
                            UIApplication.shared.open(url)
                        }
                    },
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
        .task {
            loadContent()
            advanceStatus(to: .reading)
            AnalyticsService.shared.track("article.opened")
            relatedArticles = await RelatedArticlesService().related(to: article, in: viewContext)
        }
        .onDisappear {
            ttsService.stop()
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
            Text("Loading…")
                .font(.custom(readingPreferences.fontFamily, size: readingPreferences.fontSize))
                .foregroundColor(colors.textSecondary)
        } else {
            MarkdownBodyView(
                nodes: parsedNodes,
                fontFamily: readingPreferences.fontFamily,
                fontSize: readingPreferences.fontSize,
                lineSpacingValue: lineSpacingValue,
                colors: colors,
                highlightedParagraphIndex: isTTSActive ? ttsParagraphs[safe: ttsService.currentParagraphIndex]?.index : nil
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

    /// Matches list swipe semantics: YAML is source of truth for rebuilds (`ArticleLibraryService`); keep file in sync.
    private func persistStatusToMarkdownFile(_ status: Article.Status) {
        guard let folderURL = folderBookmarkService.folderURL else { return }
        let path = article.filePath.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !path.isEmpty else { return }
        let accessed = folderURL.startAccessingSecurityScopedResource()
        defer { if accessed { folderURL.stopAccessingSecurityScopedResource() } }
        try? MarkdownWriter.updateStatus(status, for: path)
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
        guard !text.isEmpty else { return nil }
        let wordCount = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        return max(1, wordCount / 200)
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
