import AppMetricaCore

enum AnalyticsService {
    static func report(event: String, screen: String, item: String? = nil) {
        var parameters: [String: Any] = ["event": event, "screen": screen]

        if let item {
            parameters["item"] = item
        }

        AppMetrica.reportEvent(name: "event", parameters: parameters, onFailure: { error in
                print("REPORT ERROR: \(error.localizedDescription)")
            }
        )
    }
}
