import SwiftUI

/// A single "how it works" tour step (steps 1–3). Flattened directly into
/// `OnboardingFlowView`'s own outer `TabView` as tags 4–6 (FAB-285) — this view
/// no longer owns a `TabView` or page-dot indicator of its own. Nesting a second
/// swipeable `TabView` inside `OnboardingFlowView`'s paging `TabView` meant two
/// horizontally-paging containers stacked on the same axis, which conflicted for
/// the swipe gesture; the outer container, with nowhere further to swipe on its
/// last page, simply absorbed it.
struct QuickTourView: View {
    @EnvironmentObject var themeManager: ThemeManager

    /// 1-indexed step within the 3-step tour.
    let stepNumber: Int
    /// Advances to the next tour step, or finishes onboarding on the final step.
    let onNext: () -> Void
    /// Skips straight to the end of onboarding, regardless of which tour step this is.
    let onSkip: () -> Void

    private var colors: ThemeColors { themeManager.colors }
    private var isLastStep: Bool { stepNumber == 3 }

    private var symbol: String {
        switch stepNumber {
        case 1: return "square.and.arrow.up"
        case 2: return "book.pages"
        default: return "checkmark.circle"
        }
    }

    private var stepText: String {
        switch stepNumber {
        case 1: return L10n.Onboarding.tourStep1
        case 2: return L10n.Onboarding.tourStep2
        default: return L10n.Onboarding.tourStep3
        }
    }

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

                TourStep(
                    symbol: symbol,
                    text: stepText,
                    colors: colors,
                    stepNumber: stepNumber
                )
                .frame(height: 200)
            }
            .padding(.horizontal, VersoSpacing.lg)

            Spacer()

            nextControl
                .padding(.horizontal, VersoSpacing.lg)
                .padding(.bottom, VersoSpacing.xl)
        }
    }

    @ViewBuilder
    private var nextControl: some View {
        if isLastStep {
            Button(L10n.Onboarding.tourStartReading, action: onNext)
                .buttonStyle(VersoButtonStyle(variant: .primary, theme: colors))
        } else {
            Button(action: onNext) {
                HStack(spacing: VersoSpacing.xs) {
                    Text(L10n.Onboarding.tourNext)
                    Image(systemName: "chevron.right")
                }
            }
            .buttonStyle(VersoButtonStyle(variant: .primary, theme: colors))
        }
    }

    private var skipButton: some View {
        Button(L10n.Onboarding.tourSkip) {
            onSkip()
        }
        .font(VersoTypography.UI.input)
        .foregroundColor(colors.textSecondary)
        .buttonStyle(.plain)
        .opacity(isLastStep ? 0 : 1)
        .disabled(isLastStep)
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
            QuickTourView(stepNumber: 1, onNext: {}, onSkip: {})
                .environmentObject(themeManager)
                .background(themeManager.colors.background.ignoresSafeArea())
        }
    }
    return Preview()
}
