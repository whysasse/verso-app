import SwiftUI

struct AnalyticsConsentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let onNext: () -> Void

    private var colors: ThemeColors { themeManager.colors }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: VersoSpacing.lg) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 64))
                    .foregroundColor(colors.accent)

                VStack(spacing: VersoSpacing.sm) {
                    Text("Help make Verso better")
                        .font(VersoTypography.UI.screenTitle)
                        .foregroundColor(colors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Share anonymous usage data — no personal info, no article content, ever.")
                        .font(VersoTypography.UI.listSubtitle)
                        .foregroundColor(colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, VersoSpacing.md)
                }
            }

            Spacer()

            VStack(spacing: VersoSpacing.sm) {
                Button("Sure, why not") {
                    AnalyticsService.shared.optIn()
                    onNext()
                }
                .buttonStyle(VersoButtonStyle(variant: .primary, theme: colors))

                Button("No thanks", action: onNext)
                    .buttonStyle(VersoButtonStyle(variant: .secondary, theme: colors))
            }
            .padding(.horizontal, VersoSpacing.lg)
            .padding(.bottom, VersoSpacing.xl)
        }
    }
}

#Preview {
    struct Preview: View {
        @StateObject private var themeManager = ThemeManager()
        var body: some View {
            AnalyticsConsentView(onNext: {})
                .environmentObject(themeManager)
                .background(themeManager.colors.background.ignoresSafeArea())
        }
    }
    return Preview()
}
