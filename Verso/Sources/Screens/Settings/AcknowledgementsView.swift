import SwiftUI

struct AcknowledgementsView: View {
    @EnvironmentObject var themeManager: ThemeManager

    private var colors: ThemeColors { themeManager.colors }

    private let dependencies: [(name: String, license: String, url: String)] = [
        ("SwiftSoup", "MIT License", "https://github.com/scinfu/SwiftSoup"),
        ("TelemetryClient", "Apache 2.0", "https://github.com/TelemetryDeck/SwiftClient"),
        ("Readability.js", "Apache 2.0", "https://github.com/mozilla/readability"),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(dependencies.enumerated()), id: \.offset) { index, dep in
                    VStack(alignment: .leading, spacing: VersoSpacing.xxs) {
                        Text(dep.name)
                            .font(VersoTypography.UI.input)
                            .foregroundColor(colors.textPrimary)

                        Text(dep.license)
                            .font(VersoTypography.UI.caption)
                            .foregroundColor(colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, VersoSpacing.sm)
                    .padding(.horizontal, VersoSpacing.md)

                    if index < dependencies.count - 1 {
                        Rectangle().frame(height: 1).foregroundColor(colors.border).padding(.horizontal, VersoSpacing.md)
                    }
                }
            }
            .padding(.top, VersoSpacing.sm)
        }
        .background(colors.background.ignoresSafeArea())
        .versoNavigationBar(title: L10n.About.acknowledgementsRowLabel)
    }
}

#Preview {
    NavigationStack {
        AcknowledgementsView()
    }
    .environmentObject(ThemeManager())
}
