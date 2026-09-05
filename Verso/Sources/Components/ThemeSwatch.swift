import SwiftUI

/// FAB-324: the one theme-picker swatch, used by Onboarding, Settings, and the
/// reading-view controls sheet — previously three separate implementations
/// (`ThemePreviewCard`, `ThemeChip`, `ThemeChipView`).
///
/// Two of the three drew a flat background-color rectangle as the swatch, which
/// fails badly in the dark themes: Night vs Ink measures ~1.06:1 contrast and
/// Paper vs Sepia ~1.07:1, so the unselected swatch in the non-current theme pair
/// is nearly invisible. What actually distinguishes these themes is the
/// text-on-background relationship, not the background color alone -- so this
/// swatch always renders a miniature page mockup (title + body bars in
/// `textPrimary`/`textSecondary` on `background`), the one treatment of the three
/// that already read correctly in every theme.
///
/// Colors always come from `ThemeColors.colors(for:)` -- never hardcoded hex, which
/// is how the two flat versions silently drifted from the real palette.
struct ThemeSwatch: View {
    let theme: VersoTheme
    let isSelected: Bool
    /// The *currently active* theme's colors -- the label sits outside the swatch,
    /// on the app's real background, so it must read against that, not against
    /// `themeColors` below (same reasoning as `ThemePreviewCard`'s FAB-306 fix).
    let activeColors: ThemeColors
    /// Onboarding uses the full 120pt mockup (title + 3 body bars). Settings and
    /// the reading-controls sheet use a compact 32pt swatch -- at that size, 4 bars
    /// scaled proportionally would shrink past legibility, so this trades bar count
    /// for a still-readable title + single body line instead.
    var height: CGFloat = 120

    private var themeColors: ThemeColors { ThemeColors.colors(for: theme) }
    private var isCompact: Bool { height < 80 }
    private var cornerRadius: CGFloat { isCompact ? 8 : VersoRadius.md }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(themeColors.background)
                    .frame(height: height)

                if isCompact {
                    VStack(alignment: .leading, spacing: 3) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(themeColors.textPrimary)
                            .frame(width: 20, height: 4)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(themeColors.textSecondary)
                            .frame(width: 14, height: 3)
                    }
                    .padding(VersoSpacing.xxs)
                } else {
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
            }
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(isSelected ? themeColors.accent : themeColors.border, lineWidth: isSelected ? 2 : 1)
            )

            Text(theme.displayName)
                .font(VersoTypography.UI.caption)
                .foregroundColor(isSelected ? activeColors.accent : activeColors.textSecondary)
                .padding(.top, VersoSpacing.xs)
        }
    }
}

#Preview {
    struct Preview: View {
        @State private var selected: VersoTheme = .paper
        var body: some View {
            VStack(spacing: VersoSpacing.xl) {
                HStack(spacing: VersoSpacing.md) {
                    ForEach(VersoTheme.allCases) { theme in
                        ThemeSwatch(theme: theme, isSelected: theme == selected, activeColors: .colors(for: selected), height: 120)
                            .onTapGesture { selected = theme }
                    }
                }
                HStack(spacing: 0) {
                    ForEach(VersoTheme.allCases) { theme in
                        ThemeSwatch(theme: theme, isSelected: theme == selected, activeColors: .colors(for: selected), height: 32)
                            .onTapGesture { selected = theme }
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding()
            .background(ThemeColors.colors(for: selected).background.ignoresSafeArea())
        }
    }
    return Preview()
}
