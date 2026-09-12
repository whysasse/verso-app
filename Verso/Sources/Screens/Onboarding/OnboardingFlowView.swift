import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let onComplete: () -> Void

    @State private var currentPage = 0
    // FAB-348: cut from 7 screens to 2 -- Welcome + Folder. Folder is the only
    // functionally required screen; Theme, Analytics Consent and the 3-step Quick
    // Tour all moved elsewhere (see OnboardingFolderPickerView's call site in
    // VersoMainSplitView.swift for the analytics-consent sheet, and
    // ArticleReaderView.swift for the theme hint pointer). The tour's teaching
    // moves into the welcome article (FAB-338) instead of being rebuilt here.
    private let pageCount = 2

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

                OnboardingFolderPickerView(onNext: finishOnboarding)
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(VersoAnimation.normal, value: currentPage)
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)

            pageDots
                .padding(.bottom, VersoSpacing.md)
        }
        // FAB-327 (minimum fix, kept through the FAB-348 cut): Skip is global chrome
        // over every page rather than living inside a single step. Hidden with `if`,
        // not `.opacity()/.disabled()`, on the last page so a redundant control isn't
        // left sitting in the accessibility tree once "Continue" is the only way
        // forward.
        .overlay(alignment: .topTrailing) {
            if currentPage < pageCount - 1 {
                skipButton
                    .padding(.top, VersoSpacing.md)
                    .padding(.trailing, VersoSpacing.md)
            }
        }
    }

    private var skipButton: some View {
        Button(L10n.Onboarding.tourSkip, action: finishOnboarding)
            .font(VersoTypography.UI.input)
            .foregroundColor(colors.textSecondary)
            .buttonStyle(.plain)
    }

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

    /// Ends onboarding, whether reached by Folder's Continue or the global Skip overlay.
    private func finishOnboarding() {
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
