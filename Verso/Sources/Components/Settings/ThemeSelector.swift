import SwiftUI

struct ThemeSelector: View {
    @EnvironmentObject var themeManager: ThemeManager
    private var colors: ThemeColors { themeManager.colors }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(VersoTheme.allCases) { theme in
                Button {
                    themeManager.currentTheme = theme
                } label: {
                    ThemeChip(
                        theme: theme,
                        isSelected: themeManager.currentTheme == theme,
                        borderColor: colors.border,
                        accentColor: colors.accent,
                        textColor: colors.textSecondary
                    )
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct ThemeChip: View {
    let theme: VersoTheme
    let isSelected: Bool
    let borderColor: Color
    let accentColor: Color
    let textColor: Color

    var body: some View {
        VStack(spacing: VersoSpacing.xs) {
            RoundedRectangle(cornerRadius: 8)
                .fill(swatchColor)
                .frame(height: 32)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? accentColor : borderColor, lineWidth: isSelected ? 2 : 1)
                )

            Text(theme.rawValue)
                .font(.system(size: 11))
                .foregroundColor(textColor)
        }
        .frame(width: 80, height: 100)
    }

    private var swatchColor: Color {
        switch theme {
        case .paper: return Color(hex: "F5F0E8")
        case .sepia: return Color(hex: "F2E8D5")
        case .night: return Color(hex: "1C1A16")
        case .ink:   return Color(hex: "111418")
        }
    }
}

#Preview {
    ThemeSelector()
        .padding()
        .environmentObject(ThemeManager())
}
