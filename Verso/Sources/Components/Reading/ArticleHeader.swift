import SwiftUI

struct ArticleHeader: View {
    let title: String
    let source: String
    let date: Date
    var readTime: Int? = nil
    var fontFamily: String = ""
    @EnvironmentObject var themeManager: ThemeManager
    private var colors: ThemeColors { themeManager.colors }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(VersoTypography.Reading(fontFamily: fontFamily).h1)
                .foregroundColor(colors.textPrimary)

            HStack(spacing: 6) {
                Text("By \(source)")
                    .font(.system(size: 15))
                Text("·")
                    .font(.system(size: 13))
                Text(formattedDate)
                    .font(.system(size: 13))
                if let readTime {
                    Text("·")
                        .font(.system(size: 13))
                    Text("\(readTime) min read")
                        .font(.system(size: 13))
                }
            }
            .foregroundColor(colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ArticleHeader(
        title: "The Quiet Revolution in How We Read Long-Form Content Online",
        source: "The Atlantic",
        date: Date(),
        readTime: 5
    )
    .padding()
    .environmentObject(ThemeManager())
}
