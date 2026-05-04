import SwiftUI

struct ArticleHeader: View {
    let title: String
    let source: String
    let date: Date
    var fontFamily: String = ""
    @EnvironmentObject var themeManager: ThemeManager
    private var colors: ThemeColors { themeManager.colors }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(title)
                .font(VersoTypography.Reading(fontFamily: fontFamily).h1)
                .foregroundColor(colors.textPrimary)

            Text(source)
                .font(VersoTypography.UI.listSubtitle)
                .foregroundColor(colors.textSecondary)

            Text(formattedDate)
                .font(VersoTypography.UI.caption)
                .foregroundColor(colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ArticleHeader(
        title: "The Quiet Revolution in How We Read Long-Form Content Online",
        source: "The Atlantic",
        date: Date()
    )
    .padding()
    .environmentObject(ThemeManager())
}
