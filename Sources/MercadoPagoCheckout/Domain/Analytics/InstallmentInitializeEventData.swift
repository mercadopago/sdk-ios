import Foundation
import MPAnalytics

struct InstallmentInitializeEventData: AnalyticsEventData {
    let checkoutType: String
    let paymentMethodId: String
    let paymentType: String
    let selectionType: String
    let quotasCount: Int
    let transactionAmount: Decimal
    let orderId: String

    func toDictionary() -> [String: any Sendable] {
        [
            "checkout_type": self.checkoutType,
            "payment_method_id": self.paymentMethodId,
            "payment_type": self.paymentType,
            "selection_type": self.selectionType,
            "quotas_count": self.quotasCount,
            "transaction_amount": self.transactionAmount,
            "order_id": self.orderId
        ]
    }
}
