import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let onComplete: () -> Void

    @State private var currentPage = 0
    private let pageCount = 5

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

                QuickTourView(onComplete: {
                    AnalyticsService.shared.track("onboarding.stepCompleted", parameters: ["step": "done"])
                    onComplete()
                })
                .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(VersoAnimation.normal, value: currentPage)
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)

            pageDots
                .padding(.bottom, VersoSpacing.md)
        }
    }

    private var pageDots: some View {
        HStack(spacing: VersoSpacing.xs) {
            ForEach(0..<pageCount, id: \.self) { index in
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
