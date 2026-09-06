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

    // FAB-333: keyed off the rendered size, not the raw stored step -- same reasoning as
    // ArticleReaderView's identical computed properties, kept in sync here since this screen
    // renders body text through the same MarkdownBodyView with the same reading preferences.
    private var lineSpacingValue: CGFloat {
        let multipliers: [CGFloat] = [1.2, 1.5, 1.75, 2.0]
        return readingPreferences.effectiveFontSize * (multipliers[readingPreferences.lineSpacing] - 1)
    }

    var body: some View {
        ScrollView {
            MarkdownBodyView(
                nodes: nodes,
                fontFamily: readingPreferences.fontFamily,
                fontSize: readingPreferences.effectiveFontSize,
                lineSpacingValue: lineSpacingValue,
                colors: colors
            )
            .padding(VersoSpacing.md)
        }
        .background(colors.background.ignoresSafeArea())
        .versoNavigationBar(title: L10n.PrivacyPolicy.navTitle)
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
