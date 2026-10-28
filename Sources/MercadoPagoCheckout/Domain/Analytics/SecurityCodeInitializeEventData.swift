import MPAnalytics

struct SecurityCodeInitializeEventData: AnalyticsEventData {
    let paymentMethodId: String
    let paymentTypeId: String
    let issuerId: Int
    let cardId: String

    func toDictionary() -> [String: any Sendable] {
        [
            "payment_method_id": self.paymentMethodId,
            "payment_type_id": self.paymentTypeId,
            "issuer_id": self.issuerId,
            "card_id": self.cardId
        ]
    }
}
