//
//  OrderTransactionParams.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 01/06/26.
//
import Foundation

struct OrderTransactionParams: Encodable, Sendable {
    let amount: Decimal
    let paymentMethodType: PaymentMethodType
    var integrationData: IntegrationData?

    init(amount: Decimal = .zero, paymentMethodType: PaymentMethodType, integrationData: IntegrationData? = nil) {
        self.amount = amount
        self.paymentMethodType = paymentMethodType
        self.integrationData = integrationData
    }

    struct IntegrationData: Encodable, Equatable, Sendable {
        enum Feature: String, Encodable, Sendable {
            case payment
            case cardForm = "cardform"
        }

        let melidataSessionId: String
        let feature: Feature
        let platform = "ios"
        let app: String?

        init(melidataSessionId: String, feature: Feature, app: String?) {
            self.melidataSessionId = melidataSessionId
            self.feature = feature
            self.app = app.flatMap { $0.isEmpty ? nil : $0 }
        }

        enum CodingKeys: String, CodingKey {
            case melidataSessionId = "melidata_session_id"
            case feature, platform, app
        }
    }

    enum PaymentMethodType: Encodable, Equatable, Sendable {
        case creditCard(paymentMethodId: String, paymentTypeId: String, token: String, installments: Int)
        case debitCard(paymentMethodId: String, paymentTypeId: String, token: String)
        case ticket(paymentMethodId: String)

        var installments: Int? {
            guard case let .creditCard(_, _, _, installments) = self else { return nil }
            return installments
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case let .creditCard(paymentMethodId, paymentTypeId, token, installments):
                try container.encode(paymentMethodId, forKey: .paymentMethodId)
                try container.encode(paymentTypeId, forKey: .paymentTypeId)
                try container.encode(token, forKey: .token)
                try container.encode(installments, forKey: .installments)
            case let .debitCard(paymentMethodId, paymentTypeId, token):
                try container.encode(paymentMethodId, forKey: .paymentMethodId)
                try container.encode(paymentTypeId, forKey: .paymentTypeId)
                try container.encode(token, forKey: .token)
            case let .ticket(paymentMethodId):
                try container.encode(paymentMethodId, forKey: .paymentMethodId)
                try container.encode("ticket", forKey: .paymentTypeId)
            }
        }

        enum CodingKeys: String, CodingKey {
            case paymentMethodId = "payment_method_id"
            case paymentTypeId = "payment_method_type"
            case token, installments
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.integrationData, forKey: .integrationData)
        try self.paymentMethodType.encode(to: encoder)
    }

    enum CodingKeys: String, CodingKey {
        case integrationData = "integration_data"
    }
}

extension OrderTransactionParams {
    init?(cardTransaction: MPPaymentData.CardTransaction) {
        let paymentMethodType: PaymentMethodType
        switch MPCardType(paymentTypeId: cardTransaction.paymentTypeId) {
        case .credit:
            guard let installments = cardTransaction.installment, installments > 0 else { return nil }
            paymentMethodType = .creditCard(
                paymentMethodId: cardTransaction.paymentMethodId,
                paymentTypeId: cardTransaction.paymentTypeId,
                token: cardTransaction.token,
                installments: installments
            )
        case .debit, .prepaid:
            paymentMethodType = .debitCard(
                paymentMethodId: cardTransaction.paymentMethodId,
                paymentTypeId: cardTransaction.paymentTypeId,
                token: cardTransaction.token
            )
        case .none:
            return nil
        }
        self.init(amount: cardTransaction.transactionAmount ?? .zero, paymentMethodType: paymentMethodType)
    }
}
