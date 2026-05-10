import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var articleLibraryService: ArticleLibraryService
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showLaunch = true

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
            if hasCompletedOnboarding && showLaunch {
                LaunchView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .preferredColorScheme(themeManager.currentTheme.isDark ? .dark : .light)
        .onReceive(articleLibraryService.$isRebuilding) { rebuilding in
            guard showLaunch, !rebuilding else { return }
            withAnimation(.easeOut(duration: 0.25)) { showLaunch = false }
        }
        .task {
            // Safety net: dismiss launch view after 1.5s if rebuild never fires
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            guard showLaunch else { return }
            withAnimation(.easeOut(duration: 0.25)) { showLaunch = false }
        }
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