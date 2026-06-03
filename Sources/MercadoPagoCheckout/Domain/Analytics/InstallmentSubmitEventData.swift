import MPAnalytics

struct InstallmentSubmitEventData: AnalyticsEventData {
    let installments: Int
    let installmentAmount: Double
    let totalAmount: Double

    func toDictionary() -> [String: any Sendable] {
        [
            "installments": self.installments,
            "installment_amount": self.installmentAmount,
            "total_amount": self.totalAmount
        ]
    }
}
