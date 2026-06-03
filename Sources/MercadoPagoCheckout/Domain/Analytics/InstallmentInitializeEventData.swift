import MPAnalytics

struct InstallmentInitializeEventData: AnalyticsEventData {
    let checkoutType: String
    let paymentMethodId: String
    let paymentType: String
    let selectionType: String
    let quotasCount: Int
    let transactionAmount: Double

    func toDictionary() -> [String: any Sendable] {
        return [
            "checkout_type": self.checkoutType,
            "payment_method_id": self.paymentMethodId,
            "payment_type": self.paymentType,
            "selection_type": self.selectionType,
            "quotas_count": self.quotasCount,
            "transaction_amount": self.transactionAmount
        ]
    }
}
