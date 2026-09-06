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
                    Text(L10n.Onboarding.analyticsConsentHeadline)
                        .font(VersoTypography.UI.screenTitle)
                        .foregroundColor(colors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(L10n.Onboarding.analyticsConsentSubheadline)
                        .font(VersoTypography.UI.listSubtitle)
                        .foregroundColor(colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, VersoSpacing.md)
                }
            }

            Spacer()

            // FAB-328: both buttons are now `.secondary` -- Accept was `.primary` (filled),
            // weighting the answer toward opt-in. Given Law 25/GDPR both lean toward
            // equal-prominence consent, and privacy-first is a real differentiator here,
            // two equal-weight buttons is the safer, more on-brand choice.
            VStack(spacing: VersoSpacing.sm) {
                Button(L10n.Onboarding.analyticsConsentAcceptCta) {
                    AnalyticsService.shared.optIn()
                    onNext()
                }
                .buttonStyle(VersoButtonStyle(variant: .secondary, theme: colors))

                Button(L10n.Onboarding.analyticsConsentDeclineCta, action: onNext)
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
