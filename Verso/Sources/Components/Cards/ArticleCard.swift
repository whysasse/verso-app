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
        switch article.statusEnum {
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

    private var formattedDate: String {
        // Avoid rebuilding DateFormatter on every body pass; guard stale Core Data objects during churn (e.g. theme refresh).
        guard article.managedObjectContext != nil, !article.isDeleted else {
            return "—"
        }
        return article.dateAdded.formatted(date: .abbreviated, time: .omitted)
    }

    private var progressFraction: Double {
        max(0, min(1, article.scrollPosition?.doubleValue ?? 0))
    }

    var body: some View {
        HStack(alignment: .top, spacing: VersoSpacing.md) {
            VStack(alignment: .leading, spacing: VersoSpacing.xxs) {
                Text(article.title)
                    .font(VersoTypography.UI.listTitle)
                    .foregroundColor(colors.textPrimary)
                    .lineLimit(2)
                    .lineSpacing(5) // 1.3× line height for 17pt: 17 × 0.3 ≈ 5

                if !sourceDomain.isEmpty {
                    Text(sourceDomain)
                        .font(VersoTypography.UI.listSubtitle)
                        .foregroundColor(colors.textSecondary)
                        .lineLimit(1)
                        .lineSpacing(6) // 1.4× line height for 15pt: 15 × 0.4 = 6
                }

                if showsProgress {
                    ScrollProgress(progress: progressFraction)
                        .padding(.top, VersoSpacing.xxs)
                    Text(L10n.Home.sectionContinueReadingProgressCaption(count: Int((progressFraction * 100).rounded())))
                        .font(VersoTypography.UI.caption)
                        .foregroundColor(colors.textSecondary)
                } else {
                    Text(formattedDate)
                        .font(VersoTypography.UI.caption)
                        .foregroundColor(colors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            StatusBadge(status: displayStatus)
        }
        .padding(VersoSpacing.md)
        .background(colors.surface)
        .cornerRadius(VersoRadius.md)
    }
}

#Preview {
    let context = CoreDataStackValue.preview.persistentContainer.viewContext
    let unread = Article.create(in: context, filePath: "a", title: "The Future of Reading in a Digital Age", url: URL(string: "https://www.example.com/article"), status: .unread, source: "example.com")
    let reading = Article.create(in: context, filePath: "b", title: "How to Build a Minimalist Reading Habit", url: URL(string: "https://medium.com"), status: .reading, source: "medium.com")
    let read = Article.create(in: context, filePath: "c", title: "Why Paper Still Matters", status: .read, source: "nytimes.com")

    reading.scrollPosition = NSNumber(value: 0.62)

    return VStack(spacing: 12) {
        ArticleCard(article: unread)
        ArticleCard(article: reading, showsProgress: true)
        ArticleCard(article: read)
    }
    .padding()
    .environmentObject(ThemeManager())
}
