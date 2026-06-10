import MPAnalytics

struct InstallmentSelectedEventData: AnalyticsEventData {
    let installments: Int

    func toDictionary() -> [String: any Sendable] {
        ["installments": self.installments]
    }
}
