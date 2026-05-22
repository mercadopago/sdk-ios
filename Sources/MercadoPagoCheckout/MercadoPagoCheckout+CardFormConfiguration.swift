//
//  MercadoPagoCheckout + CardFormConfiguration.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 20/02/26.
//

extension MercadoPagoCheckout {
    public protocol CheckoutTypeConfiguration: Sendable {
        /// The transaction amount to be charged.
        var amount: Double { get }
    }

    /// Configuration specific to the checkout experience.
    public struct Order: CheckoutTypeConfiguration {
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

    struct SavedCardConfiguration: CheckoutTypeConfiguration {
        var amount: Double = 0
    }
}
