//
//  ReviewConfirmPaymentMethodEventData.swift
//  MercadoPagoSDK
//

import Foundation
import MPAnalytics

struct ReviewConfirmPaymentMethodEventData: AnalyticsEventData {
    let type: String
    let paymentMethodId: String
    let paymentTypeId: String
    let issuerId: String
    let cardId: String
    let transactionAmount: Decimal
    let installments: Int

    func toDictionary() -> [String: any Sendable] {
        [
            "type": self.type,
            "payment_method_id": self.paymentMethodId,
            "payment_type_id": self.paymentTypeId,
            "issuer_id": self.issuerId,
            "card_id": self.cardId,
            "transaction_amount": self.transactionAmount,
            "installments": self.installments
        ]
    }
}
