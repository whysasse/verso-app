import SwiftUI

struct QuickTourView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let onComplete: () -> Void

    @State private var currentStep = 0
    private let stepCount = 3

    private var colors: ThemeColors { themeManager.colors }
    private var isLastStep: Bool { currentStep == stepCount - 1 }

    var body: some View {
        VStack(spacing: 0) {
            skipButton
                .padding(.top, VersoSpacing.md)
                .padding(.trailing, VersoSpacing.md)
                .frame(maxWidth: .infinity, alignment: .trailing)

            Spacer()

            VStack(spacing: VersoSpacing.xl) {
                Text(L10n.Onboarding.tourHeadline)
                    .font(VersoTypography.UI.screenTitle)
                    .foregroundColor(colors.textPrimary)
                    .multilineTextAlignment(.center)

                TabView(selection: $currentStep) {
                    TourStep(
                        symbol: "square.and.arrow.up",
                        text: L10n.Onboarding.tourStep1,
                        colors: colors,
                        stepNumber: 1
                    )
                    .tag(0)

                    TourStep(
                        symbol: "book.pages",
                        text: L10n.Onboarding.tourStep2,
                        colors: colors,
                        stepNumber: 2
                    )
                    .tag(1)

                    TourStep(
                        symbol: "checkmark.circle",
                        text: L10n.Onboarding.tourStep3,
                        colors: colors,
                        stepNumber: 3
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 200)
            }
            .padding(.horizontal, VersoSpacing.lg)

            Spacer()

            VStack(spacing: VersoSpacing.lg) {
                pageDots

                if isLastStep {
                    Button(L10n.Onboarding.tourStartReading, action: onComplete)
                        .buttonStyle(VersoButtonStyle(variant: .primary, theme: colors))
                }
            }
            .padding(.horizontal, VersoSpacing.lg)
            .padding(.bottom, VersoSpacing.xl)
        }
    }

    private var skipButton: some View {
        Button(L10n.Onboarding.tourSkip) {
            onComplete()
        }
        .font(VersoTypography.UI.input)
        .foregroundColor(colors.textSecondary)
        .buttonStyle(.plain)
        .opacity(isLastStep ? 0 : 1)
        .disabled(isLastStep)
    }

    private var pageDots: some View {
        HStack(spacing: VersoSpacing.xs) {
            ForEach(0..<stepCount, id: \.self) { index in
                Capsule()
                    .fill(index == currentStep ? colors.accent : colors.border)
                    .frame(width: index == currentStep ? 20 : 8, height: 8)
                    .animation(VersoAnimation.fast, value: currentStep)
            }
        }
    }
}

private struct TourStep: View {
    let symbol: String
    let text: String
    let colors: ThemeColors
    let stepNumber: Int

    var body: some View {
        VStack(spacing: VersoSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: VersoRadius.lg)
                    .fill(colors.accentSurface)
                    .frame(width: 88, height: 88)

                Image(systemName: symbol)
                    .font(.system(size: 36))
                    .foregroundColor(colors.accent)
            }

            Text(text)
                .font(VersoTypography.UI.listSubtitle)
                .foregroundColor(colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, VersoSpacing.md)
                .fixedSize(horizontal: false, vertical: true)
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
