import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        ZStack {
            themeManager.colors.background
                .ignoresSafeArea()
            if hasCompletedOnboarding {
                NavigationStack {
                    ArticleListView()
                }
            } else {
                OnboardingFlowView(onComplete: { hasCompletedOnboarding = true })
            }
        }
        .preferredColorScheme(themeManager.currentTheme.isDark ? .dark : .light)
    }
}

struct ThemeCard: View {
    let theme: VersoTheme
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        let colors = ThemeColors.colors(for: theme)

        Button {
            themeManager.currentTheme = theme
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(theme.rawValue)
                        .font(.headline)
                        .foregroundColor(colors.textPrimary)

                    Text(colors.background.hex == "000000" ? "#000000" : colors.background.hex)
                        .font(.caption)
                        .foregroundColor(colors.textSecondary)
                }

                Spacer()

                RoundedRectangle(cornerRadius: 4)
                    .fill(colors.background)
                    .frame(width: 40, height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(colors.border, lineWidth: 1)
                    )

                if themeManager.currentTheme == theme {
                    Image(systemName: "checkmark")
                        .foregroundColor(colors.accent)
                }
            }
            .padding()
            .background(colors.surface)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
    }
}

extension Color {
    var hex: String {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return "000000"
        }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "%02X%02X%02X", r, g, b)
    }
}