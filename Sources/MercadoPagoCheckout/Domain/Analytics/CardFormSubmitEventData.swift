import MPAnalytics

struct CardFormSubmitEventData: AnalyticsEventData {
    let cardBrand: String
    let transactionAmount: Double
    let issuer: String
    let paymentType: String?

    func toDictionary() -> [String: any Sendable] {
        var dict: [String: any Sendable] = [
            "card_brand": self.cardBrand,
            "transaction_amount": self.transactionAmount,
            "issuer": self.issuer
        ]
        if let paymentType { dict["payment_type"] = paymentType }
        return dict
    }
}
