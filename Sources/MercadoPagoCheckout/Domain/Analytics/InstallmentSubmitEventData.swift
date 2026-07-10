import Foundation
import MPAnalytics

struct InstallmentSubmitEventData: AnalyticsEventData {
    let installments: Int
    let installmentAmount: Decimal
    let totalAmount: Decimal

    func toDictionary() -> [String: any Sendable] {
        [
            "installments": self.installments,
            "installment_amount": self.installmentAmount,
            "total_amount": self.totalAmount
        ]
    }
}
