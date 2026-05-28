//
//  MPPaymentData.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 30/01/26.
//
import Foundation

/// Payment data produced by the checkout flow.
///
/// Acts as a sealed namespace: each concrete checkout type (`CardSave`, `CardTransaction`)
/// produces its own variant. The variant is determined by the ``CheckoutType`` chosen on the
/// builder and is propagated to ``MercadoPagoCheckoutResult`` at the call site, so consumers
/// access the concrete fields directly — no nested `switch`, no unreachable branches.
public enum MPPaymentData {
    /// Marker protocol adopted by every concrete `MPPaymentData` variant.
    public protocol Kind: Sendable {}

    /// Payment data emitted by the `saveCard` flow.
    public struct CardSave: Kind, Equatable, Codable, Sendable {
        /// The token representing the saved card.
        public let token: String
        public var paymentMethodId: String
        public var paymentTypeId: String
        public var issuerId: String?
        public var payer: Payer?
    }

    /// Payment data emitted by the `cardTransaction` flow.
    public struct CardTransaction: Kind, Equatable, Codable, Sendable {
        public var transactionAmount: Double?
        public var installment: Int?
        public var paymentMethodId: String
        public var paymentTypeId: String
        public var issuerId: String?
        public var payer: Payer?

        var token: String

        init(
            transactionAmount: Double = .zero,
            token: String = "",
            installment: Int = 1,
            paymentMethodId: String = "",
            paymentTypeId: String = "",
            issuerId: String? = "",
            payer: Payer? = nil
        ) {
            self.transactionAmount = transactionAmount
            self.token = token
            self.installment = installment
            self.paymentMethodId = paymentMethodId
            self.paymentTypeId = paymentTypeId
            self.issuerId = issuerId
            self.payer = payer
        }
    }

    public struct PaymentTransaction: Kind, Equatable, Codable, Sendable {
        public var orderId = ""
        public var orderStatus = ""
        public var transactionAmount: Double

        var token = ""
    }

    public struct Payer: Equatable, Codable, Sendable {
        public var documentType: String
        public var documentNumber: String

        init(documentType: String, documentNumber: String) {
            self.documentType = documentType
            self.documentNumber = documentNumber
        }
    }
}
