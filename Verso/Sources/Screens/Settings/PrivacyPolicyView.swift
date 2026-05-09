import SwiftUI

struct PrivacyPolicyView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var readingPreferences: ReadingPreferencesService

    private var colors: ThemeColors { themeManager.colors }

    private var nodes: [MarkdownNode] {
        guard let url = Bundle.main.url(forResource: "privacy_policy", withExtension: "md"),
              let text = try? String(contentsOf: url, encoding: .utf8)
        else { return [] }
        return MarkdownParser.parse(text)
    }

    private var lineSpacingValue: CGFloat {
        let multipliers: [CGFloat] = [1.2, 1.5, 1.75, 2.0]
        return readingPreferences.fontSize * (multipliers[readingPreferences.lineSpacing] - 1)
    }

    var body: some View {
        ScrollView {
            MarkdownBodyView(
                nodes: nodes,
                fontFamily: readingPreferences.fontFamily,
                fontSize: readingPreferences.fontSize,
                lineSpacingValue: lineSpacingValue,
                colors: colors
            )
            .padding(VersoSpacing.md)
        }
        .background(colors.background.ignoresSafeArea())
        .versoNavigationBar(title: "Privacy Policy")
    }
}

#Preview {
    struct PreviewWrapper: View {
        var body: some View {
            NavigationStack {
                PrivacyPolicyView()
            }
            .environmentObject(ThemeManager())
            .environmentObject(ReadingPreferencesService())
        }
    }
    return PreviewWrapper()
}
