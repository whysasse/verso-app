import SwiftUI

private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct ContentHeightKey: PreferenceKey {
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

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var readingPreferences: ReadingPreferencesService
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var colors: ThemeColors { themeManager.colors }

    private var scrollProgress: Double {
        let scrollable = contentHeight - screenHeight
        guard scrollable > 0 else { return 0 }
        return min(1, max(0, Double(scrollOffset / scrollable)))
    }

    private var lineSpacingValue: CGFloat {
        // Compact=1.2, Normal=1.5, Relaxed=1.75, Airy=2.0
        let multipliers: [CGFloat] = [1.2, 1.5, 1.75, 2.0]
        return readingPreferences.fontSize * (multipliers[readingPreferences.lineSpacing] - 1)
    }

    var body: some View {
        ZStack(alignment: .top) {
            colors.background.ignoresSafeArea()

            GeometryReader { geo in
                ScrollView {
                    ZStack(alignment: .top) {
                        GeometryReader { inner in
                            Color.clear.preference(
                                key: ScrollOffsetKey.self,
                                value: -inner.frame(in: .named("scroll")).minY
                            )
                        }
                        .frame(height: 0)

                        VStack(alignment: .leading, spacing: 40) {
                            ArticleHeader(
                                title: article.title,
                                source: article.source ?? "",
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
                        .padding(.bottom, 56 + safeAreaBottom + 24)
                        .background(
                            GeometryReader { content in
                                Color.clear.preference(
                                    key: ContentHeightKey.self,
                                    value: content.size.height
                                )
                            }
                        )
                    }
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetKey.self) { value in
                    scrollOffset = max(0, value)
                    if scrollProgress >= 0.95 {
                        advanceStatus(to: .read)
                    }
                }
                .onPreferenceChange(ContentHeightKey.self) { value in
                    contentHeight = value
                }
                .onTapGesture {
                    if reduceMotion {
                        isChromeVisible.toggle()
                        isPillVisible = !isChromeVisible
                    } else {
                        withAnimation(.easeOut(duration: 0.3)) {
                            isChromeVisible.toggle()
                            isPillVisible = !isChromeVisible
                        }
                    }
                }
                .onAppear {
                    screenHeight = geo.size.height
                }
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
                isVisible: $isChromeVisible
            )
            .frame(height: isChromeVisible ? 56 : 0)
            .clipped()
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .all)
        .sheet(isPresented: $showFontControls) {
            ReadingControls(variant: .font, fontSize: $readingPreferences.fontSize, lineSpacing: $readingPreferences.lineSpacing)
                .presentationDetents([.height(245)])
                .presentationDragIndicator(.hidden)
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showThemeControls) {
            ReadingControls(variant: .theme, fontSize: $readingPreferences.fontSize, lineSpacing: $readingPreferences.lineSpacing)
                .presentationDetents([.height(200)])
                .presentationDragIndicator(.hidden)
                .environmentObject(themeManager)
        }
        .task {
            loadContent()
            advanceStatus(to: .reading)
            relatedArticles = await RelatedArticlesService().related(to: article, in: viewContext)
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
                colors: colors
            )
        }
    }

    private func loadContent() {
        let filePath = article.filePath
        guard !filePath.isEmpty else { return }
        let fileURL = URL(fileURLWithPath: filePath)
        if let parsed = try? MarkdownReader.read(fileURL: fileURL) {
            parsedContent = parsed.contentMarkdown
        }
    }

    private func advanceStatus(to status: Article.Status) {
        let order: [Article.Status] = [.unread, .reading, .read]
        guard let current = order.firstIndex(of: article.statusEnum),
              let target = order.firstIndex(of: status),
              current < target else { return }
        article.statusEnum = status
        try? viewContext.save()
    }

    private func estimatedReadTime(for text: String) -> Int? {
        guard !text.isEmpty else { return nil }
        let wordCount = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        return max(1, wordCount / 200)
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
