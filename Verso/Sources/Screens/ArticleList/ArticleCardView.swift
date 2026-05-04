import SwiftUI

struct ArticleCardView: View {
    let article: Article
    @EnvironmentObject var themeManager: ThemeManager

    private var colors: ThemeColors { themeManager.colors }

    private var articleStatus: ArticleStatus {
        switch article.statusEnum {
        case .unread:  return .unread
        case .reading: return .reading
        case .read:    return .read
        }
    }

    private var sourceDomain: String {
        if let host = article.url?.host {
            return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
        }
        return article.source ?? ""
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: article.dateAdded)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Card content — right padding leaves room for the badge
            VStack(alignment: .leading, spacing: VersoSpacing.xxs) {
                Text(article.title)
                    .font(VersoTypography.UI.listTitle)
                    .foregroundColor(colors.textPrimary)
                    .lineLimit(2)

                if !sourceDomain.isEmpty {
                    Text(sourceDomain)
                        .font(VersoTypography.UI.listSubtitle)
                        .foregroundColor(colors.textSecondary)
                        .lineLimit(1)
                }

                Text(formattedDate)
                    .font(VersoTypography.UI.caption)
                    .foregroundColor(colors.textSecondary)
            }
            .padding(.top, VersoSpacing.md)
            .padding(.bottom, VersoSpacing.md)
            .padding(.leading, VersoSpacing.md)
            .padding(.trailing, 56)
            .frame(maxWidth: .infinity, minHeight: 122, alignment: .leading)
            .background(colors.surface)
            .cornerRadius(VersoRadius.md)

            // Status badge — 28×28pt circle, absolute top-right
            StatusBadge(status: articleStatus)
                .padding(.top, VersoSpacing.md)
                .padding(.trailing, VersoSpacing.md)
        }
    }
}

private struct StatusBadge: View {
    let status: ArticleStatus

    var body: some View {
        Circle()
            .fill(status.color)
            .frame(width: 28, height: 28)
            .overlay(
                Image(systemName: status.icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            )
    }
}
