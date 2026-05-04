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
        HStack(alignment: .top, spacing: VersoSpacing.sm) {
            StatusBadge(status: articleStatus)

            VStack(alignment: .leading, spacing: VersoSpacing.xxs) {
                Text(article.title)
                    .font(VersoTypography.UI.listTitle)
                    .foregroundColor(colors.textPrimary)
                    .lineLimit(2)

                HStack(spacing: VersoSpacing.xs) {
                    if !sourceDomain.isEmpty {
                        Text(sourceDomain)
                            .font(VersoTypography.UI.caption)
                            .foregroundColor(colors.textSecondary)
                    }

                    if !sourceDomain.isEmpty {
                        Text("·")
                            .font(VersoTypography.UI.caption)
                            .foregroundColor(colors.textSecondary)
                    }

                    Text(formattedDate)
                        .font(VersoTypography.UI.caption)
                        .foregroundColor(colors.textSecondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(VersoSpacing.md)
        .frame(minHeight: 44)
        .background(colors.surface)
        .cornerRadius(VersoRadius.md)
    }
}

private struct StatusBadge: View {
    let status: ArticleStatus

    var body: some View {
        switch status {
        case .unread:
            Circle()
                .fill(status.color)
                .frame(width: 12, height: 12)
                .padding(.top, 4)

        case .reading, .read:
            Text(status.rawValue)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .frame(height: 16)
                .background(status.color)
                .clipShape(Capsule())
                .padding(.top, 2)
        }
    }
}
