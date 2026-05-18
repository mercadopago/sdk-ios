import MPAnalytics

struct InstallmentInitializeEventData: AnalyticsEventData {
    let checkoutType: String
    let paymentType: String
    let selectionType: String
    let quotasCount: Int
    let transactionAmount: Double?

    func toDictionary() -> [String: any Sendable] {
        var dict: [String: any Sendable] = [
            "checkout_type": self.checkoutType,
            "payment_type": self.paymentType,
            "selection_type": self.selectionType,
            "quotas_count": self.quotasCount
        ]
        if let transactionAmount { dict["transaction_amount"] = transactionAmount }
        return dict
    }
}
