import SwiftUI

final class ThemeManager: ObservableObject {
    @Published var currentTheme: VersoTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: UserDefaultsKeys.selectedTheme)
            mirrorToAppGroup()
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
        // FAB-323: backfill the App Group mirror on every launch, not just on the next
        // theme change -- otherwise someone who already picked a theme before this
        // shipped would see the Share Extension guess Paper until they touch the
        // selector again.
        mirrorToAppGroup()
    }

    /// FAB-323: `.standard` isn't shared with the Share Extension, so this mirrors the
    /// selection into the App Group suite purely for the extension to read. `.standard`
    /// stays the source of truth for the app itself -- this is additive, not a migration.
    private func mirrorToAppGroup() {
        UserDefaults(suiteName: AppConstants.appGroupID)?.set(currentTheme.rawValue, forKey: AppConstants.selectedThemeKey)
    }
}

private enum UserDefaultsKeys {
    static let selectedTheme = "selectedTheme"
}