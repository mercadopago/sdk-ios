//
//  MercadoPagoCheckout + CardType.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 20/02/26.
//

public extension MercadoPagoCheckout {
    /// The card network or product type accepted by a payment method.
    public enum CardType: Sendable {
        /// A credit card.
        case credit
        /// A debit card.
        case debit
        /// A prepaid card.
        case prepaid
    }
}
