import SwiftUI

struct ThemeSelector: View {
    @EnvironmentObject var themeManager: ThemeManager
    private var colors: ThemeColors { themeManager.colors }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(VersoTheme.allCases) { theme in
                let isSelected = themeManager.currentTheme == theme
                Button {
                    themeManager.currentTheme = theme
                } label: {
                    ThemeSwatch(theme: theme, isSelected: isSelected, activeColors: colors, height: 32)
                        .frame(width: 80, height: 100)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }
}

#Preview {
    ThemeSelector()
        .padding()
        .environmentObject(ThemeManager())
}
