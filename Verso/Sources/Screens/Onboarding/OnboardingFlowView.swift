import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let onComplete: () -> Void

    @State private var currentPage = 0
    private let pageCount = 7

    private var colors: ThemeColors { themeManager.colors }

    var body: some View {
        ZStack(alignment: .bottom) {
            colors.background.ignoresSafeArea()

            TabView(selection: $currentPage) {
                WelcomeView(onNext: {
                    AnalyticsService.shared.track("onboarding.stepCompleted", parameters: ["step": "welcome"])
                    advance()
                })
                .tag(0)

                OnboardingThemePickerView(onNext: {
                    AnalyticsService.shared.track("onboarding.stepCompleted", parameters: ["step": "theme_picker"])
                    advance()
                })
                .tag(1)

                OnboardingFolderPickerView(onNext: { advance() })
                    .tag(2)

                AnalyticsConsentView(onNext: { advance() })
                    .tag(3)

                // Tour steps 4–6: flattened directly into this outer TabView rather than nested
                // inside QuickTourView's own TabView — see the comment atop QuickTourView.swift.
                // FAB-327: Skip is now global chrome (see the `.overlay` below), so QuickTourView
                // no longer takes its own onSkip.
                QuickTourView(stepNumber: 1, onNext: advance)
                    .tag(4)

                QuickTourView(stepNumber: 2, onNext: advance)
                    .tag(5)

                QuickTourView(stepNumber: 3, onNext: finishTour)
                    .tag(6)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(VersoAnimation.normal, value: currentPage)
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)

            pageDots
                .padding(.bottom, VersoSpacing.md)
        }
        // FAB-327 (minimum fix): Skip used to live inside QuickTourView, so it only
        // existed on tour steps 5-7 -- Welcome, Theme, Folder and Analytics consent
        // could only be answered forward. Hoisting it here makes it global chrome
        // over every page, mirroring pageDots as a bottom overlay on the same ZStack.
        // Hidden with `if`, not `.opacity()/.disabled()`, on the last page so a
        // redundant control isn't left sitting in the accessibility tree once
        // "Start reading" is the only way forward -- folds in FAB-328's last
        // remaining bullet, which flagged exactly that gap in the old skip button.
        .overlay(alignment: .topTrailing) {
            if currentPage < pageCount - 1 {
                skipButton
                    .padding(.top, VersoSpacing.md)
                    .padding(.trailing, VersoSpacing.md)
            }
        }
    }

    private var skipButton: some View {
        Button(L10n.Onboarding.tourSkip, action: finishTour)
            .font(VersoTypography.UI.input)
            .foregroundColor(colors.textSecondary)
            .buttonStyle(.plain)
    }

    // FAB-327: dots only ever show the current page plus what's ahead, so the row
    // shrinks from 7 down to 1 as the user advances instead of staying at a constant
    // 7 with the highlight moving along it.
    private var pageDots: some View {
        HStack(spacing: VersoSpacing.xs) {
            ForEach(currentPage..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? colors.accent : colors.border)
                    .frame(width: index == currentPage ? 20 : 8, height: 8)
                    .animation(VersoAnimation.fast, value: currentPage)
            }
        }
    }

    private func advance() {
        withAnimation(VersoAnimation.normal) {
            currentPage = min(currentPage + 1, pageCount - 1)
        }
    }

    /// Ends onboarding, whether reached by "Start reading" on the final step or the global
    /// Skip overlay from any earlier page.
    private func finishTour() {
        AnalyticsService.shared.track("onboarding.stepCompleted", parameters: ["step": "done"])
        onComplete()
    }
}

#Preview {
    struct Preview: View {
        @StateObject private var themeManager = ThemeManager()
        var body: some View {
            OnboardingFlowView(onComplete: {})
                .environmentObject(themeManager)
        }
    }
    return Preview()
}
