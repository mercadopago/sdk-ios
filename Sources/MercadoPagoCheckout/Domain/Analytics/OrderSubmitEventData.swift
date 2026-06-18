import MPAnalytics

struct OrderSubmitEventData: AnalyticsEventData {
    let orderId: String
    let orderStatus: String

    func toDictionary() -> [String: any Sendable] {
        [
            "order_id": self.orderId,
            "order_status": self.orderStatus
        ]
    }
}
