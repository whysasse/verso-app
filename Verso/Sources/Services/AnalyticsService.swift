import Foundation
import TelemetryDeck

final class AnalyticsService {
    static let shared = AnalyticsService()
    private let optInKey = "verso.analytics.optIn"

    private init() {}

    private static let appID: String = Bundle.main.infoDictionary?["TelemetryDeckAppID"] as? String ?? ""

    var isOptedIn: Bool {
        get { UserDefaults.standard.bool(forKey: optInKey) }
        set { UserDefaults.standard.set(newValue, forKey: optInKey) }
    }

    func initializeIfOptedIn() {
        guard isOptedIn else { return }
        TelemetryDeck.initialize(config: .init(appID: Self.appID))
    }

    func optIn() {
        isOptedIn = true
        TelemetryDeck.initialize(config: .init(appID: Self.appID))
    }

    func track(_ event: String, parameters: [String: String] = [:]) {
        guard isOptedIn else { return }
        TelemetryDeck.signal(event, parameters: parameters)
    }
}
