//
//  MPCheckoutConfiguration.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 09/06/25.
//

/// Internal behavioral configuration carried by ``MercadoPagoCheckout``.
///
/// Built by ``MercadoPagoCheckout/Builder`` from the integrator-supplied
/// ``MercadoPagoCheckout/CheckoutType`` and payment methods.
struct MPCheckoutConfiguration<T: MPPaymentData.Kind> {
    /// The type of checkout experience to present.
    var type: MercadoPagoCheckout<T>.CheckoutType
    /// The payment methods available during the checkout flow.
    var paymentMethod: [MPPaymentMethod]
}
