import Foundation

enum AppConstants {
    static let appGroupID = "group.com.fabiosasseron.verso"

    /// FAB-323: `ThemeManager` persists here in the App Group suite (in addition to its
    /// primary `UserDefaults.standard` store, which extensions don't share with the host
    /// app) specifically so the Share Extension can read the user's real theme. Shared
    /// as one constant so both sides can't drift apart on the key string.
    static let selectedThemeKey = "selectedTheme"
}
