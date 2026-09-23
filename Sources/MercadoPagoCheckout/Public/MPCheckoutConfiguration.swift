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
    /// The payment method  configuration for the checkout flow.
    var paymentMethod: [MPPaymentMethodConfig]
    /// The optional screens the integrator opted into, in the order they were configured.
    var screenConfigs: [ScreenConfig]

    init(
        type: MercadoPagoCheckout<T>.CheckoutType,
        paymentMethod: [MPPaymentMethodConfig],
        screenConfigs: [ScreenConfig] = []
    ) {
        self.type = type
        self.paymentMethod = paymentMethod
        self.screenConfigs = screenConfigs
    }
}

extension MPCheckoutConfiguration {
    /// Store details supplied with a payment-capable checkout type, if any.
    var sellerInfo: MPSellerInfo? {
        switch self.type.kind {
        case let .payment(_, sellerInfo), let .cardTransaction(_, sellerInfo):
            return sellerInfo
        case .saveCard:
            return nil
        }
    }

    /// The review and confirm configuration, or `nil` when the integrator did not opt in.
    ///
    /// A `nil` value means the flow processes the order straight away instead of routing through
    /// the review and confirm screen.
    var reviewAndConfirmConfig: ScreenConfig? {
        self.screenConfigs.first { config in
            if case .reviewAndConfirm = config { return true }
            return false
        }
    }
}

extension MPCheckoutConfiguration: Sendable where T: Sendable {}
