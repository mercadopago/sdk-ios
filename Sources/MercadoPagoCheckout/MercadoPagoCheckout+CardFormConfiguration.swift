//
//  MercadoPagoCheckout + CardFormConfiguration.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 20/02/26.
//

public extension MercadoPagoCheckout {
    /// Configuration specific to the card form checkout experience.
    public struct CardFormConfiguration: Sendable {
        /// The transaction amount to be charged. Optional; when `nil` the amount is determined server-side.
        public var amount: Double?
        /// Payer information pre-filled in the form. Optional.
        public var payer: Payer?

        /// Creates a new card form configuration.
        ///
        /// - Parameters:
        ///   - amount: The transaction amount. Defaults to `nil`.
        ///   - payer: Pre-filled payer information. Defaults to `nil`.
        public init(amount: Double? = nil, payer: Payer? = nil) {
            self.amount = amount
            self.payer = payer
        }
    }
}
