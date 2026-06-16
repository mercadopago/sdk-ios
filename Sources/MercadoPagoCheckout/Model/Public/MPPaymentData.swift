//
//  MPPaymentData.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 30/01/26.
//
import Foundation

/// The payment data returned when a checkout flow succeeds.
///
/// You receive one of these in ``MercadoPagoCheckoutResult/success(_:)``. This namespace groups
/// the available variants; the one you actually get is fixed by the
/// ``MercadoPagoCheckout/CheckoutType`` you configured, so you never need to cast:
/// `.cardTransaction(order:)` delivers a ``CardTransaction``, and `.saveCard` delivers a
/// ``CardSave``.
///
/// ## Topics
///
/// ### Variants
///
/// - ``CardTransaction``
/// - ``CardSave``
///
/// ### Supporting Types
///
/// - ``Payer``
/// - ``Kind``
public enum MPPaymentData {
    /// Marker protocol adopted by every payment data variant in this namespace.
    ///
    /// Each variant also declares, via ``Cancellation``, the matching
    /// ``MPUserCancelledContext`` it is paired with — which is why the checkout type that fixes
    /// the success payload also fixes the cancellation context you receive.
    public protocol Kind: Sendable {
        /// The cancellation context delivered if the user cancels this flow instead of completing it.
        associatedtype Cancellation: MPUserCancelledContext.Kind
    }

    /// Payment data returned by the `.saveCard` flow.
    ///
    /// Carries the token for the card the user saved, which you can use to charge the card later.
    public struct CardSave: Kind, Equatable, Codable, Sendable {
        public typealias Cancellation = MPUserCancelledContext.CardSave

        /// The token representing the saved card.
        public let token: String
        /// The identifier of the selected payment method (for example, the card brand).
        public var paymentMethodId: String
        /// The identifier of the payment type (for example, credit or debit).
        public var paymentTypeId: String
        /// The identifier of the card issuer, when available.
        public var issuerId: String?
        /// The payer's identification details, when collected.
        public var payer: Payer?
    }

    /// Payment data returned by the `.cardTransaction(order:)` flow.
    ///
    /// Carries the tokenized card details and the chosen installment plan for the transaction.
    public struct CardTransaction: Kind, Equatable, Codable, Sendable {
        public typealias Cancellation = MPUserCancelledContext.CardTransaction

        /// The amount charged for the transaction.
        public var transactionAmount: Double?
        /// The number of installments the user selected.
        public var installment: Int?
        /// The identifier of the selected payment method (for example, the card brand).
        public var paymentMethodId: String
        /// The identifier of the payment type (for example, credit or debit).
        public var paymentTypeId: String
        /// The identifier of the card issuer, when available.
        public var issuerId: String?
        /// The payer's identification details, when collected.
        public var payer: Payer?
        public var orderId: String
        public var orderStatus: String

        var token: String

        init(
            transactionAmount: Double = .zero,
            token: String = "",
            installment: Int = 1,
            paymentMethodId: String = "",
            paymentTypeId: String = "",
            issuerId: String? = "",
            orderId: String = "",
            orderStatus: String = "",
            payer: Payer? = nil
        ) {
            self.transactionAmount = transactionAmount
            self.token = token
            self.installment = installment
            self.paymentMethodId = paymentMethodId
            self.paymentTypeId = paymentTypeId
            self.issuerId = issuerId
            self.orderId = orderId
            self.orderStatus = orderStatus
            self.payer = payer
        }
    }

    /// The payer's identification details collected during the flow.
    public struct Payer: Equatable, Codable, Sendable {
        /// The type of identification document (for example, the local document code).
        public var documentType: String
        /// The identification document number.
        public var documentNumber: String

        init(documentType: String, documentNumber: String) {
            self.documentType = documentType
            self.documentNumber = documentNumber
        }
    }
}
