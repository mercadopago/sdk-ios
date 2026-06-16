import MPAnalytics

struct OrderErrorEventData: AnalyticsEventData {
    let errorType: String
    let orderId: String

    func toDictionary() -> [String: any Sendable] {
        [
            "error_type": self.errorType,
            "order_id": self.orderId
        ]
    }
}
