//
//  MercadoPagoCheckout + Builder.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 19/02/26.
//

public extension MercadoPagoCheckout {
    /// A fluent builder for constructing a ``MercadoPagoCheckout`` instance.
    ///
    /// Create a builder with the ``CheckoutType`` and appearance you want, chain optional
    /// configuration such as ``setPaymentMethodConfiguration(_:)``, then call ``build()``. The
    /// checkout type you pass determines the type of ``MercadoPagoCheckoutResult`` the resulting
    /// checkout delivers, so you do not specify the generic parameter yourself.
    ///
    /// ```swift
    /// let checkout = MercadoPagoCheckout.Builder(
    ///     checkoutType: .cardTransaction(order: .init(amount: 150.0, payer: .init(email: "..."))),
    ///     checkoutAppearance: .init()
    /// )
    /// .setPaymentMethodConfiguration([.card(excludedTypes: [.prepaid])])
    /// .build()
    /// ```
    final class Builder {
        private var checkoutType: CheckoutType
        private var checkoutAppearance: MPCheckoutAppearance
        private var paymentMethodConfigs: [MPPaymentMethodConfig]

        /// Creates a new builder with the required checkout type and appearance.
        ///
        /// - Parameters:
        ///   - checkoutType: The type of checkout experience to present.
        ///   - checkoutAppearance: The visual appearance for the checkout flow.
        public init(checkoutType: CheckoutType, checkoutAppearance: MPCheckoutAppearance) {
            self.checkoutType = checkoutType
            self.checkoutAppearance = checkoutAppearance
            self.paymentMethodConfigs = MPPaymentMethodConfig.defaults
        }

        /// Sets the payment method exclusion configuration for the checkout flow.
        ///
        /// - Parameter paymentMethodConfigs: The payment method configurations to apply. Defaults to `[]` (no exclusions).
        /// - Returns: The builder instance for chaining.
        @discardableResult
        public func setPaymentMethodConfiguration(_ paymentMethodConfigs: [MPPaymentMethodConfig] = []) -> Builder {
            self.paymentMethodConfigs = paymentMethodConfigs
            return self
        }

        /// Builds and returns the configured ``MercadoPagoCheckout`` instance.
        ///
        /// - Returns: A fully configured `MercadoPagoCheckout` ready to be presented.
        @MainActor
        public func build() -> MercadoPagoCheckout<T> {
            MercadoPagoCheckout<T>(
                theme: self.checkoutAppearance,
                configuration: .init(
                    type: self.checkoutType,
                    paymentMethod: self.paymentMethodConfigs
                )
            )
        }
    }
}
