//
//  OrderTransactionParams.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 01/06/26.
//
import Foundation

struct OrderTransactionParams: Encodable {
    let amount: Decimal
    let paymentMethodId: String
    let paymentMethodType: String
    let token: String
    let installments: Int

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ""
        let amountStr = formatter.string(from: self.amount as NSDecimalNumber) ?? NSDecimalNumber(decimal: self.amount).stringValue
        try container.encode(amountStr, forKey: .amount)
        try container.encode(self.paymentMethodId, forKey: .paymentMethodId)
        try container.encode(self.paymentMethodType, forKey: .paymentMethodType)
        try container.encode(self.token, forKey: .token)
        try container.encode(self.installments, forKey: .installments)
    }

    enum CodingKeys: String, CodingKey {
        case amount
        case paymentMethodId = "payment_method_id"
        case paymentMethodType = "payment_method_type"
        case token
        case installments
    }
}

extension OrderTransactionParams {
    init?(cardTransaction: MPPaymentData.CardTransaction) {
        guard
            let amount = cardTransaction.transactionAmount,
            let installments = cardTransaction.installment
        else { return nil }

        self.init(
            amount: amount,
            paymentMethodId: cardTransaction.paymentMethodId,
            paymentMethodType: cardTransaction.paymentTypeId,
            token: cardTransaction.token,
            installments: installments
        )
    }
}
