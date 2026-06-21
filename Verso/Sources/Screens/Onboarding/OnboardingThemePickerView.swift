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
                    ThemePreviewCard(
                        theme: theme,
                        isSelected: themeManager.currentTheme == theme
                    ) {
                        themeManager.currentTheme = theme
                    }
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

private struct ThemePreviewCard: View {
    let theme: VersoTheme
    let isSelected: Bool
    let onSelect: () -> Void

    private var themeColors: ThemeColors { ThemeColors.colors(for: theme) }

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: VersoRadius.md)
                        .fill(themeColors.background)
                        .frame(height: 120)

                    VStack(alignment: .leading, spacing: 6) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(themeColors.textPrimary)
                            .frame(width: 80, height: 10)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(themeColors.textSecondary)
                            .frame(width: 60, height: 7)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(themeColors.textSecondary)
                            .frame(width: 70, height: 7)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(themeColors.textSecondary)
                            .frame(width: 50, height: 7)
                    }
                    .padding(VersoSpacing.sm)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: VersoRadius.md)
                        .stroke(isSelected ? themeColors.accent : themeColors.border, lineWidth: isSelected ? 2 : 1)
                )

                Text(theme.displayName)
                    .font(VersoTypography.UI.caption)
                    .foregroundColor(isSelected ? themeColors.accent : themeColors.textSecondary)
                    .padding(.top, VersoSpacing.xs)
            }
        }
        .buttonStyle(.plain)
        .animation(VersoAnimation.fast, value: isSelected)
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
