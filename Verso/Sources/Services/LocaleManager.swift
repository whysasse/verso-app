import Foundation

/// The three shipped UI languages, plus "follow the device" (FAB-284).
///
/// Raw values match the codes Apple's own `AppleLanguages` override expects
/// (see `LocaleManager.apply`), not `docs/copy/UI_COPY.md` key segments.
enum AppLocale: String, CaseIterable, Identifiable {
    case automatic
    case en
    case frCA = "fr-CA"
    case ptBR = "pt-BR"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .automatic: return L10n.Language.automatic
        case .en: return L10n.Language.en
        case .frCA: return L10n.Language.frCA
        case .ptBR: return L10n.Language.ptBR
        }
    }
}

/// Manual UI-language override (FAB-284). Mirrors `ThemeManager`'s persistence
/// pattern, but writing a language choice also has to reach `String(localized:)`,
/// which resolves against the standard `AppleLanguages` override key — the same
/// mechanism Apple's own scheme-editor "Language" option uses. There is no
/// supported way to make already-loaded SwiftUI text re-render in the new
/// language without relaunching, so a change here takes effect on next launch;
/// `SettingsView` prompts the user to close and reopen the app.
final class LocaleManager: ObservableObject {
    @Published var selectedLocale: AppLocale {
        didSet {
            guard selectedLocale != oldValue else { return }
            apply(selectedLocale)
            AnalyticsService.shared.track(
                "settings.languageChanged",
                parameters: ["language": selectedLocale.rawValue]
            )
        }
    }

    init() {
        let saved = UserDefaults.standard.string(forKey: UserDefaultsKeys.selectedLocale)
        self.selectedLocale = saved.flatMap(AppLocale.init(rawValue:)) ?? .automatic
    }

    private func apply(_ locale: AppLocale) {
        switch locale {
        case .automatic:
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.selectedLocale)
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.appleLanguages)
        case .en, .frCA, .ptBR:
            UserDefaults.standard.set(locale.rawValue, forKey: UserDefaultsKeys.selectedLocale)
            UserDefaults.standard.set([locale.rawValue], forKey: UserDefaultsKeys.appleLanguages)
        }
    }
}

private enum UserDefaultsKeys {
    /// Our own record of the explicit choice — distinct from `appleLanguages`
    /// below, since that key always has *some* system-provided value even when
    /// the user never overrode anything.
    static let selectedLocale = "selectedAppLocale"
    /// Apple's own override key; see the type doc comment above.
    static let appleLanguages = "AppleLanguages"
}
