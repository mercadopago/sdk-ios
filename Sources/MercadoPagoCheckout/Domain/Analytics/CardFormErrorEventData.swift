import MPAnalytics

struct CardFormErrorEventData: AnalyticsEventData {
    let errorType: String

    func toDictionary() -> [String: any Sendable] {
        ["error_type": self.errorType]
    }
}
