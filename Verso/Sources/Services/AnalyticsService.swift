import Foundation
import TelemetryDeck

final class AnalyticsService {
    static let shared = AnalyticsService()
    private let optInKey = "verso.analytics.optIn"

    private init() {}

    var isOptedIn: Bool {
        get { UserDefaults.standard.bool(forKey: optInKey) }
        set { UserDefaults.standard.set(newValue, forKey: optInKey) }
    }

    func track(_ event: String, parameters: [String: String] = [:]) {
        guard isOptedIn else { return }
        TelemetryDeck.signal(event, parameters: parameters)
    }
}
