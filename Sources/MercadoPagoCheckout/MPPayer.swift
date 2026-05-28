//
//  MPPayer.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 20/02/26.
//

/// Information about the payer initiating the checkout.
public struct MPPayer: Sendable, Decodable {
    /// The payer's email address.
    public var email: String

    /// Creates a new payer with the given email.
    ///
    /// - Parameter email: The payer's email address.
    public init(email: String) {
        self.email = email
    }
}
