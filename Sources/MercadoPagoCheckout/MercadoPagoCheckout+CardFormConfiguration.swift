//
//  MercadoPagoCheckout + CardFormConfiguration.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 20/02/26.
//

protocol CheckoutTypeConfiguration: Sendable {
    /// The transaction amount to be charged.
    var amount: Double { get }
}

public extension MercadoPagoCheckout {
    /// Configuration specific to the checkout experience.
    struct Order: CheckoutTypeConfiguration {
        /// The transaction amount to be charged. Optional; when `nil` the amount is determined server-side.
        public var amount: Double
        /// Payer information pre-filled in the form. Optional.
        public var payer: Payer

        /// Creates a new card form configuration.
        ///
        /// - Parameters:
        ///   - amount: The transaction amount.
        ///   - payer: Pre-filled payer information.
        public init(amount: Double, payer: Payer) {
            self.amount = amount
            self.payer = payer
        }
    }

    internal struct SavedCardConfiguration: CheckoutTypeConfiguration {
        public var amount: Double = .zero

        init() {}
    }
}
