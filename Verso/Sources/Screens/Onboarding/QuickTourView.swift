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
                    Text("Save from anywhere")
                        .font(VersoTypography.UI.screenTitle)
                        .foregroundColor(colors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Tap Share in any browser, pick Verso, and your article is saved automatically.")
                        .font(VersoTypography.UI.listSubtitle)
                        .foregroundColor(colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, VersoSpacing.md)
                }
            }

            Spacer()

            Button("Start Reading", action: onComplete)
                .buttonStyle(VersoButtonStyle(variant: .primary, theme: colors))
                .padding(.horizontal, VersoSpacing.lg)
                .padding(.bottom, VersoSpacing.xl)
        }
    }

    private var shareFlowIllustration: some View {
        HStack(spacing: VersoSpacing.sm) {
            IllustrationStep(symbol: "safari", label: "Browser", colors: colors)

            Image(systemName: "chevron.right")
                .foregroundColor(colors.textSecondary)
                .font(.system(size: 14, weight: .semibold))

            IllustrationStep(symbol: "square.and.arrow.up", label: "Share", colors: colors)

            Image(systemName: "chevron.right")
                .foregroundColor(colors.textSecondary)
                .font(.system(size: 14, weight: .semibold))

            IllustrationStep(symbol: "book.closed.fill", label: "Verso", colors: colors)
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
