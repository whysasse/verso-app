import SwiftUI

struct ArticleHeader: View {
    let title: String
    /// Shown after "By …" when non-empty (FAB-144).
    let author: String?
    /// Shown alone when author is unavailable (pretty host fallback comes from Article).
    let publicationFallback: String
    let date: Date
    var readTime: Int? = nil
    var fontFamily: String = ""
    @EnvironmentObject var themeManager: ThemeManager
    private var colors: ThemeColors { themeManager.colors }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private var authorTrimmed: String {
        author?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    private var publicationTrimmed: String {
        publicationFallback.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var hasAttributionLine: Bool {
        !authorTrimmed.isEmpty || !publicationTrimmed.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(VersoTypography.Reading(fontFamily: fontFamily).h1)
                .foregroundColor(colors.textPrimary)

            VStack(alignment: .leading, spacing: 4) {
                if hasAttributionLine {
                    if !authorTrimmed.isEmpty {
                        Text(L10n.Reading.headerByline(author: authorTrimmed))
                            .font(VersoTypography.UI.listSubtitle)
                    } else {
                        Text(publicationTrimmed)
                            .font(VersoTypography.UI.listSubtitle)
                    }
                }

                HStack(spacing: 6) {
                    Text(formattedDate)
                    if let readTime {
                        Text("·")
                            .font(VersoTypography.UI.caption)
                        Text(L10n.ArticleCard.estimatedReadTime(count: readTime))
                            .font(VersoTypography.UI.caption)
                    }
                }
                .font(VersoTypography.UI.caption)
            }
            .foregroundColor(colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ArticleHeader(
        title: "The Quiet Revolution in How We Read Long-Form Content Online",
        author: "Ada Lovelace",
        publicationFallback: "The Atlantic",
        date: Date(),
        readTime: 5
    )
    .padding()
    .environmentObject(ThemeManager())
}
