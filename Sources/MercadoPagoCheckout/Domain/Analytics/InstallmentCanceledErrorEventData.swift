import MPAnalytics

struct InstallmentCanceledErrorEventData: AnalyticsEventData {
    let errorType: String

    func toDictionary() -> [String: any Sendable] {
        ["error_type": self.errorType]
    }
}
