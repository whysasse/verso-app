import SwiftUI
import CoreData

struct RelatedArticlesSection: View {
    let articles: [Article]
    /// When set (e.g. iPad split root), switches the open article without an inner `NavigationStack`.
    var onSelectArticle: ((Article) -> Void)? = nil

    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.managedObjectContext) private var viewContext

    private var colors: ThemeColors { themeManager.colors }

    var body: some View {
        VStack(alignment: .leading, spacing: VersoSpacing.md) {
            Text(L10n.Reading.relatedArticlesSectionHeader)
                .font(VersoTypography.UI.caption)
                .foregroundColor(colors.textSecondary)
                .textCase(.uppercase)
                .kerning(0.8)

            VStack(spacing: VersoSpacing.xs) {
                ForEach(articles) { article in
                    if let onSelectArticle {
                        Button {
                            onSelectArticle(article)
                        } label: {
                            RelatedArticleRow(article: article, colors: colors)
                        }
                        .buttonStyle(.plain)
                    } else {
                        NavigationLink(destination: ArticleReaderView(article: article)) {
                            RelatedArticleRow(article: article, colors: colors)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct RelatedArticleRow: View {
    let article: Article
    let colors: ThemeColors

    private var sourceDomain: String {
        if let host = article.url?.host {
            return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
        }
        return article.source ?? ""
    }

    var body: some View {
        VStack(alignment: .leading, spacing: VersoSpacing.xxs) {
            Text(article.title)
                .font(VersoTypography.UI.listTitle)
                .foregroundColor(colors.textPrimary)
                .lineLimit(2)

            if !sourceDomain.isEmpty {
                Text(sourceDomain)
                    .font(VersoTypography.UI.caption)
                    .foregroundColor(colors.textSecondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(VersoSpacing.md)
        .background(colors.surface)
        .cornerRadius(VersoRadius.md)
    }
}
