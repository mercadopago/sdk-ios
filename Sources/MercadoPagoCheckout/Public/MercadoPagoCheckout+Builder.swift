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
    /// configuration such as ``setPaymentMethodConfiguration(_:)`` or ``withStatusScreen()``, then
    /// call ``build()``. The
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
        private var screenConfigs: [ScreenConfig]

        /// Creates a new builder with the required checkout type and appearance.
        ///
        /// - Parameters:
        ///   - checkoutType: The type of checkout experience to present.
        ///   - checkoutAppearance: The visual appearance for the checkout flow.
        public init(checkoutType: CheckoutType, checkoutAppearance: MPCheckoutAppearance) {
            self.checkoutType = checkoutType
            self.checkoutAppearance = checkoutAppearance
            self.paymentMethodConfigs = MPPaymentMethodConfig.defaults
            self.screenConfigs = []
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
                    paymentMethod: self.paymentMethodConfigs,
                    screenConfigs: self.screenConfigs
                )
            )
        }
    }
}

extension MercadoPagoCheckout.Builder {
    /// Replaces any previously configured review and confirm screen with a new one.
    ///
    /// Shared by the `withReviewAndConfirm` overloads exposed on the flows that process a payment.
    private func setReviewAndConfirm(
        onEmailChangeRequested: (@MainActor @Sendable () -> Void)?
    ) {
        self.screenConfigs.removeAll { config in
            if case .reviewAndConfirm = config { return true }
            return false
        }
        self.screenConfigs.append(
            .reviewAndConfirm(
                onEmailChangeRequested: onEmailChangeRequested
            )
        )
    }

    /// Adds the Status Screen configuration once while preserving its original position.
    private func enableStatusScreen() {
        guard !self.screenConfigs.contains(where: { config in
            if case .statusScreen = config { return true }
            return false
        }) else { return }
        self.screenConfigs.append(.statusScreen)
    }
}

public extension MercadoPagoCheckout.Builder where T == MPPaymentData.Payment {
    /// Shows Status Screen after the payment reaches its successful end state.
    ///
    /// Status Screen is disabled unless you call this method. Calling it more than once keeps a
    /// single configuration. Completion through the existing user-close lifecycle is delivered as
    /// ``MercadoPagoCheckoutResult/exit`` through the checkout's existing result callback.
    ///
    /// ```swift
    /// let checkout = MercadoPagoCheckout.Builder(
    ///     checkoutType: .payment(order: order, sellerInfo: sellerInfo),
    ///     checkoutAppearance: .init()
    /// )
    /// .withStatusScreen()
    /// .build()
    /// ```
    ///
    /// - Returns: The builder instance for chaining.
    @discardableResult
    func withStatusScreen() -> Self {
        self.enableStatusScreen()
        return self
    }

    /// Shows a review and confirm screen before the payment is processed.
    ///
    /// Without this call the checkout processes the order as soon as the buyer finishes selecting a
    /// payment method.
    ///
    /// Calling this more than once keeps only the last configuration.
    ///
    /// ```swift
    /// let checkout = MercadoPagoCheckout.Builder(
    ///     checkoutType: .payment(
    ///         order: order,
    ///         sellerInfo: MPSellerInfo(name: "Adidas Store", logoUrl: "https://...")
    ///     ),
    ///     checkoutAppearance: .init()
    /// )
    /// .withReviewAndConfirm()
    /// .build()
    /// ```
    ///
    /// - Parameters:
    ///   - onEmailChangeRequested: Called when the buyer asks to change the email shown on the
    ///     screen. The checkout closes and hands control back to you without reporting a
    ///     cancellation, so you can collect the new email and start a new order. When `nil` the
    ///     email is read-only.
    /// - Returns: The builder instance for chaining.
    @discardableResult
    func withReviewAndConfirm(
        onEmailChangeRequested: (@MainActor @Sendable () -> Void)? = nil
    ) -> Self {
        self.setReviewAndConfirm(onEmailChangeRequested: onEmailChangeRequested)
        return self
    }
}

public extension MercadoPagoCheckout.Builder where T == MPPaymentData.CardTransaction {
    /// Shows Status Screen after the card transaction reaches its successful end state.
    ///
    /// Status Screen is disabled unless you call this method. Calling it more than once keeps a
    /// single configuration. Completion through the existing user-close lifecycle is delivered as
    /// ``MercadoPagoCheckoutResult/exit`` through the checkout's existing result callback.
    ///
    /// ```swift
    /// let checkout = MercadoPagoCheckout.Builder(
    ///     checkoutType: .cardTransaction(order: order, sellerInfo: sellerInfo),
    ///     checkoutAppearance: .init()
    /// )
    /// .withStatusScreen()
    /// .build()
    /// ```
    ///
    /// - Returns: The builder instance for chaining.
    @discardableResult
    func withStatusScreen() -> Self {
        self.enableStatusScreen()
        return self
    }

    /// Shows a review and confirm screen before the card transaction is processed.
    ///
    /// Without this call the checkout processes the order as soon as the buyer finishes the card
    /// form.
    ///
    /// Calling this more than once keeps only the last configuration.
    ///
    /// ```swift
    /// let checkout = MercadoPagoCheckout.Builder(
    ///     checkoutType: .cardTransaction(
    ///         order: order,
    ///         sellerInfo: MPSellerInfo(name: "Adidas Store", logoUrl: "https://...")
    ///     ),
    ///     checkoutAppearance: .init()
    /// )
    /// .withReviewAndConfirm()
    /// .build()
    /// ```
    ///
    /// - Returns: The builder instance for chaining.
    @discardableResult
    func withReviewAndConfirm() -> Self {
        self.setReviewAndConfirm(onEmailChangeRequested: nil)
        return self
    }
}
