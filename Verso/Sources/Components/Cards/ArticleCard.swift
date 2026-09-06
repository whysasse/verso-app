import SwiftUI

struct ArticleCard: View {
    @ObservedObject var article: Article
    /// FAB-292: Continue Reading section cards show saved scroll progress instead of the date line.
    var showsProgress: Bool = false
    @EnvironmentObject var themeManager: ThemeManager
    private var colors: ThemeColors { themeManager.colors }

    private var displayStatus: ArticleStatus {
        // FAB-297: archived is now orthogonal to status (was itself a status case before the
        // split). Preserves the pre-split visual behavior -- an archived article always showed
        // a "read"-colored badge regardless of its actual read state.
        if article.archived { return .read }
        // FAB-331: a `.reading` article with no saved progress displays as unread.
        switch article.displayStatusEnum {
        case .unread:    return .unread
        case .reading:   return .reading
        case .read:      return .read
        }
    }

    private var sourceDomain: String {
        if let host = article.url?.host {
            return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
        }
        return article.source ?? ""
    }

    private var progressFraction: Double {
        max(0, min(1, article.scrollPosition?.doubleValue ?? 0))
    }

    private var progressPercent: Int {
        Int((progressFraction * 100).rounded())
    }

    /// FAB-321: decision-support for choosing what to read next, so it belongs on the
    /// card, not just inside the article (`ArticleHeader`) after the user has already
    /// committed. `searchableBody` is the plain-text cache every `ArticleLibraryService`
    /// rebuild already populates -- no per-row file I/O in the list. `nil` here (a
    /// not-yet-rebuilt object, or truly empty content) degrades the line to source-only,
    /// same spirit as the old `formattedDate`'s guard for stale Core Data objects.
    private var readTimeMinutes: Int? {
        ReadingEstimate.minutes(for: article.searchableBody ?? "")
    }

    private var readTimeText: String? {
        readTimeMinutes.map { L10n.ArticleCard.estimatedReadTime(count: $0) }
    }

    /// The non-progress card's one-liner, replacing the old separate source + date
    /// lines: `theatlantic.com · 12 min read`. FAB-322: falls back to an em dash rather
    /// than an empty string when both source and read time are genuinely absent (e.g. a
    /// manually-added file with no URL, before its `searchableBody` cache is rebuilt) --
    /// omitting the line entirely gave that card a shorter height than its neighbors.
    private var sourceAndReadTimeLine: String {
        guard let readTimeText else { return sourceDomain.isEmpty ? "—" : sourceDomain }
        return sourceDomain.isEmpty ? readTimeText : "\(sourceDomain) · \(readTimeText)"
    }

    private func joinedAccessibilityLabel(_ parts: String?...) -> String {
        parts.compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: ", ")
    }

    /// docs/accessibility-specs.md §5.1: "[title], [source], [estimated read time]".
    /// Continue Reading cards substitute the visible progress caption for read time,
    /// so what's announced matches what's shown, since the spec predates that variant.
    private var accessibilityRowLabel: String {
        if showsProgress {
            let progressCaption = L10n.Home.sectionContinueReadingProgressCaption(count: progressPercent)
            return joinedAccessibilityLabel(article.title, sourceDomain, progressCaption)
        }
        if !sourceDomain.isEmpty, let readTimeText {
            return L10n.A11y.articleRowLabel(title: article.title, source: sourceDomain, estimatedReadTime: readTimeText)
        }
        return joinedAccessibilityLabel(article.title, sourceDomain, readTimeText)
    }

    var body: some View {
        HStack(alignment: .top, spacing: VersoSpacing.md) {
            VStack(alignment: .leading, spacing: VersoSpacing.xxs) {
                Text(article.title)
                    .font(VersoTypography.UI.listTitle)
                    .foregroundColor(colors.textPrimary)
                    .lineLimit(2)
                    .lineSpacing(5) // 1.3× line height for 17pt: 17 × 0.3 ≈ 5

                if showsProgress {
                    // FAB-322: always render this line, even with no source -- omitting
                    // it entirely (the old behavior) gave the card a shorter height than
                    // its neighbors in the Continue Reading row.
                    Text(sourceDomain.isEmpty ? "—" : sourceDomain)
                        .font(VersoTypography.UI.listSubtitle)
                        .foregroundColor(colors.textSecondary)
                        .lineLimit(1)
                        .lineSpacing(6) // 1.4× line height for 15pt: 15 × 0.4 = 6
                    ScrollProgress(progress: progressFraction)
                        .padding(.top, VersoSpacing.xxs)
                    Text(L10n.Home.sectionContinueReadingProgressCaption(count: progressPercent))
                        .font(VersoTypography.UI.caption)
                        .foregroundColor(colors.textSecondary)
                } else {
                    // FAB-321: replaces the old separate source + date-added lines --
                    // read time is decision-support, the date isn't (it still shows
                    // inside the article itself, in ArticleHeader).
                    Text(sourceAndReadTimeLine)
                        .font(VersoTypography.UI.listSubtitle)
                        .foregroundColor(colors.textSecondary)
                        .lineLimit(1)
                        .lineSpacing(6)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityRowLabel)
            .accessibilityHint(L10n.A11y.articleRowHint)

            StatusBadge(status: displayStatus)
        }
        .padding(VersoSpacing.md)
        .background(colors.surface)
        .cornerRadius(VersoRadius.md)
    }
}

#Preview {
    // FAB-321: seeded so the preview actually shows the read-time line, not an
    // empty one -- ReadingEstimate.minutes(for:) needs real word count.
    func sampleBody(words: Int) -> String {
        Array(repeating: "word", count: words).joined(separator: " ")
    }

    let context = CoreDataStackValue.preview.persistentContainer.viewContext
    let unread = Article.create(in: context, filePath: "a", title: "The Future of Reading in a Digital Age", url: URL(string: "https://www.example.com/article"), status: .unread, source: "example.com", searchableBody: sampleBody(words: 900))
    let reading = Article.create(in: context, filePath: "b", title: "How to Build a Minimalist Reading Habit", url: URL(string: "https://medium.com"), status: .reading, source: "medium.com", searchableBody: sampleBody(words: 1200))
    let read = Article.create(in: context, filePath: "c", title: "Why Paper Still Matters", status: .read, source: "nytimes.com", searchableBody: sampleBody(words: 2640))
    // FAB-322: no url and no source -- demonstrates the em-dash fallback rather than a
    // shorter, collapsed card.
    let noSource = Article.create(in: context, filePath: "d", title: "Notes From a Manually Added File", status: .unread)

    reading.scrollPosition = NSNumber(value: 0.62)

    return VStack(spacing: 12) {
        ArticleCard(article: unread)
        ArticleCard(article: reading, showsProgress: true)
        ArticleCard(article: read)
        ArticleCard(article: noSource)
    }
    .padding()
    .environmentObject(ThemeManager())
}
