import SwiftUI

struct OnboardingThemePickerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let onNext: () -> Void

    private var colors: ThemeColors { themeManager.colors }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: VersoSpacing.xs) {
                Text(L10n.Onboarding.themeHeadline)
                    .font(VersoTypography.UI.screenTitle)
                    .foregroundColor(colors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(L10n.Onboarding.themeSubheadline)
                    .font(VersoTypography.UI.listSubtitle)
                    .foregroundColor(colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, VersoSpacing.xl)
            .padding(.horizontal, VersoSpacing.lg)

            Spacer()

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: VersoSpacing.md) {
                ForEach(VersoTheme.allCases) { theme in
                    let isSelected = themeManager.currentTheme == theme
                    Button {
                        themeManager.currentTheme = theme
                    } label: {
                        ThemeSwatch(theme: theme, isSelected: isSelected, activeColors: colors, height: 120)
                    }
                    .buttonStyle(.plain)
                    .animation(VersoAnimation.fast, value: isSelected)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
            .padding(.horizontal, VersoSpacing.lg)

            Spacer()

            Button(L10n.Onboarding.themeContinue, action: onNext)
                .buttonStyle(VersoButtonStyle(variant: .primary, theme: colors))
                .padding(.horizontal, VersoSpacing.lg)
                .padding(.bottom, VersoSpacing.xl)
        }
    }
}

#Preview {
    struct Preview: View {
        @StateObject private var themeManager = ThemeManager()
        var body: some View {
            OnboardingThemePickerView(onNext: {})
                .environmentObject(themeManager)
                .background(themeManager.colors.background.ignoresSafeArea())
        }
    }
    return Preview()
}
