//
//  MPOrder.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 20/02/26.
//

protocol CheckoutTypeConfiguration: Sendable {
    /// The transaction amount to be charged.
    var amount: Double { get }
}

/// Configuration specific to the checkout experience.
public struct MPOrder: CheckoutTypeConfiguration {
    /// The transaction amount to be charged. Optional; when `nil` the amount is determined server-side.
    public var amount: Double
    /// Payer information pre-filled in the form. Optional.
    public var payer: MPPayer
    /// The identifier of the order associated with this transaction.
    public var orderId: String

    /// Creates a new card form configuration.
    ///
    /// - Parameters:
    ///   - amount: The transaction amount.
    ///   - payer: Pre-filled payer information.
    ///   - orderId: The transaction order id.
    public init(amount: Double, payer: MPPayer, orderId: String) {
        self.amount = amount
        self.payer = payer
        self.orderId = orderId
    }
}

struct SavedCardConfiguration: CheckoutTypeConfiguration {
    var amount: Double = .zero

    init() {}
}
