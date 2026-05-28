//
//  MercadoPagoCheckout + Builder.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 19/02/26.
//

public extension MercadoPagoCheckout {
    /// A fluent builder for constructing a ``MercadoPagoCheckout`` instance.
    ///
    /// The generic parameter `T` of the enclosing ``MercadoPagoCheckout`` is inferred from
    /// the ``CheckoutType`` passed to ``init(checkoutType:checkoutAppearance:)``, so the
    /// type flows naturally into ``MercadoPagoCheckoutResult``.
    ///
    /// ```swift
    /// let checkout = MercadoPagoCheckout.Builder(
    ///     checkoutType: .cardTransaction(order: .init(amount: 150.0, payer: .init(email: "..."))),
    ///     checkoutAppearance: .init()
    /// )
    /// .setPaymentMethods([.card(allowedTypes: [.credit])])
    /// .build()
    /// ```
    final class Builder {
        private var checkoutType: CheckoutType
        private var checkoutAppearance: MPCheckoutAppearance
        private var paymentMethods: [MPPaymentMethod]

        /// Creates a new builder with the required checkout type and appearance.
        ///
        /// Payment methods default to ``MPPaymentMethod/defaults``.
        ///
        /// - Parameters:
        ///   - checkoutType: The type of checkout experience to present.
        ///   - checkoutAppearance: The visual appearance for the checkout flow.
        public init(checkoutType: CheckoutType, checkoutAppearance: MPCheckoutAppearance) {
            self.checkoutType = checkoutType
            self.checkoutAppearance = checkoutAppearance
            self.paymentMethods = MPPaymentMethod.defaults
        }

        /// Sets the payment methods available during the checkout flow.
        ///
        /// - Parameter paymentMethods: The payment methods to enable. Defaults to ``MPPaymentMethod/defaults``.
        /// - Returns: The builder instance for chaining.
        @discardableResult
        public func setPaymentMethods(_ paymentMethods: [MPPaymentMethod] = MPPaymentMethod.defaults) -> Builder {
            self.paymentMethods = paymentMethods
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
                    paymentMethod: self.paymentMethods
                )
            )
        }
    }
}
