import SwiftUI

/// FAB-334 phase 3: destination for Settings' "Theme" value+chevron row, replacing
/// the inline `ThemeSelector` row (`SettingsRow.theme` case, now deleted). Reuses
/// `ThemeSwatch` (FAB-324's shared component) exactly as `OnboardingThemePickerView`
/// does, just navigated to instead of shown inline.
struct ThemePickerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    private var colors: ThemeColors { themeManager.colors }

    var body: some View {
        Form {
            Section {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: VersoSpacing.md) {
                    ForEach(VersoTheme.allCases) { theme in
                        let isSelected = themeManager.currentTheme == theme
                        Button {
                            themeManager.currentTheme = theme
                        } label: {
                            ThemeSwatch(theme: theme, isSelected: isSelected, activeColors: colors, height: 120)
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(isSelected ? .isSelected : [])
                    }
                }
                .padding(.vertical, VersoSpacing.xs)
            }
        }
        .navigationTitle(L10n.ReaderSettings.themeSectionLabel)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ThemePickerView()
    }
    .environmentObject(ThemeManager())
}
