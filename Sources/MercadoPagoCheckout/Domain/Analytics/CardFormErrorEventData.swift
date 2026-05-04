import MPAnalytics

enum CardFormCancelReason {
    case backButton
    case dismissedScreen

    var analyticsValue: String {
        switch self {
        case .backButton: return "user_tapped_back_button"
        case .dismissedScreen: return "user_dismissed_screen"
        }
    }
}

struct CardFormErrorEventData: AnalyticsEventData {
    let errorType: String

    func toDictionary() -> [String: any Sendable] {
        ["error_type": self.errorType]
    }
}
