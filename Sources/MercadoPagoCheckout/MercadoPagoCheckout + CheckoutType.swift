//
//  MercadoPagoCheckout + CheckoutType.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 20/02/26.
//

public extension MercadoPagoCheckout {
    /// The type of checkout experience to launch.
    public enum CheckoutType: Sendable {
        /// A card-based payment form.
        ///
        /// - Parameter cardFormConfiguration: Configuration values for the card form, such as amount and payer.
        case cardForm(cardFormConfiguration: CardFormConfiguration)
    }

}
