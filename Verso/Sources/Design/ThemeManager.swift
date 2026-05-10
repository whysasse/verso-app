import SwiftUI

final class ThemeManager: ObservableObject {
    @Published var currentTheme: VersoTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: UserDefaultsKeys.selectedTheme)
            AnalyticsService.shared.track("settings.themeChanged", parameters: ["theme": currentTheme.rawValue.lowercased()])
        }
    }

    var colors: ThemeColors {
        ThemeColors.colors(for: currentTheme)
    }

    var semanticColors: SemanticColors {
        SemanticColors.semanticColors(for: currentTheme)
    }

    init() {
        let savedTheme = UserDefaults.standard.string(forKey: UserDefaultsKeys.selectedTheme)
        self.currentTheme = VersoTheme(rawValue: savedTheme ?? "Paper") ?? .paper
    }
}

private enum UserDefaultsKeys {
    static let selectedTheme = "selectedTheme"
}