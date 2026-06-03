//
//  TransactionOrderParams.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 01/06/26.
//

struct OrderTransactionParams: Encodable {
    let amount: Double
    let paymentMethodId: String
    let paymentMethodType: String
    let token: String
    let installments: Int

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(String(format: "%.2f", amount), forKey: .amount)
        try container.encode(paymentMethodId, forKey: .paymentMethodId)
        try container.encode(paymentMethodType, forKey: .paymentMethodType)
        try container.encode(token, forKey: .token)
        try container.encode(installments, forKey: .installments)
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
