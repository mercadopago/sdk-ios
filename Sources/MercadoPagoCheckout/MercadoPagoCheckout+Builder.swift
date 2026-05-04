//
//  MercadoPagoCheckout + Builder.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 19/02/26.
//

public extension MercadoPagoCheckout {
    /// A fluent builder for constructing a ``MercadoPagoCheckout`` instance.
    ///
    /// Use `Builder` to configure the checkout step-by-step before calling ``build()``.
    ///
    /// ```swift
    /// let checkout = MercadoPagoCheckout.Builder(
    ///     checkoutType: .cardForm(cardFormConfiguration: .init(amount: 150.0)),
    ///     checkoutAppearance: .init()
    /// )
    /// .setPaymentMethod([.card(cardTypes: [.credit]), .pix])
    /// .build()
    /// ```
    class Builder {
        private var checkoutType: CheckoutType
        private var checkoutAppearance: CheckoutAppearance
        private var paymentMethods: [PaymentMethod]

        /// Creates a new builder with the required checkout type and appearance.
        ///
        /// Payment methods default to ``PaymentMethod/defaults``.
        ///
        /// - Parameters:
        ///   - checkoutType: The type of checkout experience to present.
        ///   - checkoutAppearance: The visual appearance for the checkout flow.
        public init(checkoutType: CheckoutType, checkoutAppearance: CheckoutAppearance) {
            self.checkoutType = checkoutType
            self.checkoutAppearance = checkoutAppearance
            self.paymentMethods = PaymentMethod.defaults
        }

        /// Sets the payment methods available during the checkout flow.
        ///
        /// - Parameter paymentMethods: The payment methods to enable. Defaults to ``PaymentMethod/defaults``.
        /// - Returns: The builder instance for chaining.
        @discardableResult
        public func setPaymentMethods(_ paymentMethods: [PaymentMethod] = PaymentMethod.defaults) -> Builder {
            self.paymentMethods = paymentMethods
            return self
        }

        /// Builds and returns the configured ``MercadoPagoCheckout`` instance.
        ///
        /// - Returns: A fully configured `MercadoPagoCheckout` ready to be presented.
        @MainActor
        public func build() -> MercadoPagoCheckout {
            MercadoPagoCheckout(
                theme: self.checkoutAppearance,
                configuration: .init(
                    type: self.checkoutType,
                    paymentMethod: self.paymentMethods
                )
            )
        }
    }
}
