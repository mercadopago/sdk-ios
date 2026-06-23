//
//  MPPaymentData.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 30/01/26.
//
import Foundation

/// The result data you receive when a checkout flow completes successfully.
///
/// Each checkout type produces a specific variant — you do not need to cast or inspect the type at
/// runtime. Handle results directly in the ``MercadoPagoCheckoutResult/success(_:)`` case:
///
/// ```swift
/// checkout.show { result in
///     switch result {
///     case .success(let data):
///         // data is typed to the variant you configured:
///         //   .payment(order:)        → MPPaymentData.Payment
///         //   .cardTransaction(order:) → MPPaymentData.CardTransaction
///         //   .saveCard               → MPPaymentData.CardSave
///         break
///     case .userCancelled:
///         break
///     case .failure(let error):
///         break
///     }
/// }
/// ```
///
/// ## Topics
///
/// ### Checkout results
///
/// - ``Payment``
/// - ``CardTransaction``
/// - ``CardSave``
public enum MPPaymentData {
    public protocol Kind: Sendable {
        associatedtype Cancellation: MPUserCancelledContext.Kind
    }

    /// Result of a `.saveCard` checkout.
    ///
    /// Use the card `token` to charge the saved card later without requiring the user to re-enter
    /// their card details.
    public struct CardSave: Kind, Equatable, Codable, Sendable {
        public typealias Cancellation = MPUserCancelledContext.CardSave

        /// Token representing the saved card. Pass this to your payment API to charge the card.
        public let token: String
        /// Payment method identifier (e.g. `"visa"`, `"master"`).
        public var paymentMethodId: String
        /// Payment type identifier (e.g. `"credit_card"`, `"debit_card"`).
        public var paymentTypeId: String
        /// Card issuer identifier, when available.
        public var issuerId: String?
        /// Payer identification collected during the flow, when available.
        public var payer: Payer?
    }

    /// Result of a `.cardTransaction(order:)` checkout.
    ///
    /// Use `orderId` and `orderStatus` to check the transaction outcome on your side.
    public struct CardTransaction: Kind, Equatable, Codable, Sendable {
        public typealias Cancellation = MPUserCancelledContext.CardTransaction

        /// Amount charged for the transaction.
        public var transactionAmount: Decimal?
        /// Number of installments the user selected.
        public var installment: Int?
        /// Payment method identifier (e.g. `"visa"`, `"master"`).
        public var paymentMethodId: String
        /// Payment type identifier (e.g. `"credit_card"`, `"debit_card"`).
        public var paymentTypeId: String
        /// Card issuer identifier, when available.
        public var issuerId: String?
        /// Payer identification collected during the flow, when available.
        public var payer: Payer?
        /// Order identifier. Use this to look up the transaction on your side.
        public var orderId: String
        /// Order status returned by the Orders API.
        public var orderStatus: String

        var token: String

        init(
            transactionAmount: Decimal = .zero,
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

    /// Result of a `.payment(order:)` checkout.
    ///
    /// Use `orderId` and `orderStatus` to check the payment outcome on your side.
    public struct Payment: Kind, Equatable, Codable, Sendable {
        public typealias Cancellation = MPUserCancelledContext.Payment

        /// Order identifier. Use this to look up the payment on your side.
        public var orderId: String
        /// Order status returned by the Orders API.
        public var orderStatus = ""
        /// Amount charged for the transaction.
        public var transactionAmount: Decimal
    }

    /// Payer identification collected during the checkout flow.
    public struct Payer: Equatable, Codable, Sendable {
        /// Document type (e.g. `"CPF"`, `"DNI"`).
        public var documentType: String
        /// Document number.
        public var documentNumber: String

        init(documentType: String, documentNumber: String) {
            self.documentType = documentType
            self.documentNumber = documentNumber
        }
    }
}
