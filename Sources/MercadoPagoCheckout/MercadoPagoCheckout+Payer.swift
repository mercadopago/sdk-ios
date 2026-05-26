//
//  MercadoPagoCheckout + Payer.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 20/02/26.
//

public extension MercadoPagoCheckout {
    /// Information about the payer initiating the checkout.
    struct Payer: Sendable, Decodable {
        /// The payer's email address.
        public var email: String

        /// Creates a new payer with the given email.
        ///
        /// - Parameter email: The payer's email address.
        public init(email: String) {
            self.email = email
        }
    }
}
