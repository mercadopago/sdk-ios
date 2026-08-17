//
//  OrderTransactionParams.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 01/06/26.
//
import Foundation

struct OrderTransactionParams: Encodable {
    let amount: Decimal
    let paymentMethodType: PaymentMethodType

    enum PaymentMethodType: Encodable, Equatable {
        case card(paymentMethodId: String, paymentTypeId: String, token: String, installments: Int)
        case ticket(paymentMethodId: String)

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case let .card(paymentMethodId, paymentTypeId, token, installments):
                try container.encode(paymentMethodId, forKey: .paymentMethodId)
                try container.encode(paymentTypeId, forKey: .paymentTypeId)
                try container.encode(token, forKey: .token)
                try container.encode(installments, forKey: .installments)
            case let .ticket(paymentMethodId):
                try container.encode(paymentMethodId, forKey: .paymentMethodId)
                try container.encode("ticket", forKey: .paymentTypeId)
            }
        }

        enum CodingKeys: String, CodingKey {
            case paymentMethodId = "payment_method_id"
            case paymentTypeId = "payment_method_type"
            case token
            case installments
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ""
        let amountStr = formatter.string(from: self.amount as NSDecimalNumber) ?? NSDecimalNumber(decimal: self.amount).stringValue
        try container.encode(amountStr, forKey: .amount)
        try self.paymentMethodType.encode(to: encoder)
    }

    enum CodingKeys: String, CodingKey {
        case amount
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
            paymentMethodType: .card(
                paymentMethodId: cardTransaction.paymentMethodId,
                paymentTypeId: cardTransaction.paymentTypeId,
                token: cardTransaction.token,
                installments: installments
            )
        )
    }
}
