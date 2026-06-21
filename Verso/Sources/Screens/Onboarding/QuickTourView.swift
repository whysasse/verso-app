import SwiftUI

struct QuickTourView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let onComplete: () -> Void

    private var colors: ThemeColors { themeManager.colors }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: VersoSpacing.xl) {
                shareFlowIllustration

                VStack(spacing: VersoSpacing.sm) {
                    Text(L10n.Onboarding.tourIllustrationHeadline)
                        .font(VersoTypography.UI.screenTitle)
                        .foregroundColor(colors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(L10n.Onboarding.tourIllustrationSubheadline)
                        .font(VersoTypography.UI.listSubtitle)
                        .foregroundColor(colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, VersoSpacing.md)
                }
            }

            Spacer()

            Button(L10n.Onboarding.tourStartReading, action: onComplete)
                .buttonStyle(VersoButtonStyle(variant: .primary, theme: colors))
                .padding(.horizontal, VersoSpacing.lg)
                .padding(.bottom, VersoSpacing.xl)
        }
    }

    private var shareFlowIllustration: some View {
        HStack(spacing: VersoSpacing.sm) {
            IllustrationStep(symbol: "safari", label: L10n.Onboarding.tourIllustrationBrowserLabel, colors: colors)

            Image(systemName: "chevron.right")
                .foregroundColor(colors.textSecondary)
                .font(.system(size: 14, weight: .semibold))

            IllustrationStep(symbol: "square.and.arrow.up", label: L10n.Onboarding.tourIllustrationShareLabel, colors: colors)

            Image(systemName: "chevron.right")
                .foregroundColor(colors.textSecondary)
                .font(.system(size: 14, weight: .semibold))

            IllustrationStep(symbol: "book.closed.fill", label: L10n.Onboarding.tourIllustrationVersoLabel, colors: colors)
        }
        .padding(.horizontal, VersoSpacing.lg)
    }
}

private struct IllustrationStep: View {
    let symbol: String
    let label: String
    let colors: ThemeColors

    var body: some View {
        VStack(spacing: VersoSpacing.xs) {
            ZStack {
                RoundedRectangle(cornerRadius: VersoRadius.md)
                    .fill(colors.accentSurface)
                    .frame(width: 72, height: 72)

                Image(systemName: symbol)
                    .font(.system(size: 30))
                    .foregroundColor(colors.accent)
            }

            Text(label)
                .font(VersoTypography.UI.caption)
                .foregroundColor(colors.textSecondary)
        }
    }
}

#Preview {
    struct Preview: View {
        @StateObject private var themeManager = ThemeManager()
        var body: some View {
            QuickTourView(onComplete: {})
                .environmentObject(themeManager)
                .background(themeManager.colors.background.ignoresSafeArea())
        }
    }
    return Preview()
}
