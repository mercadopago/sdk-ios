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
    public class Builder {
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
        public func setPaymentMethod(_ paymentMethods: [PaymentMethod] = PaymentMethod.defaults) -> Builder {
            self.paymentMethods = paymentMethods
            return self
        }

        /// Builds and returns the configured ``MercadoPagoCheckout`` instance.
        ///
        /// - Returns: A fully configured `MercadoPagoCheckout` ready to be presented.
        @MainActor
        public func build() -> MercadoPagoCheckout {
            MercadoPagoCheckout(
                theme: checkoutAppearance,
                checkoutConfiguration: .init(
                    checkoutType: checkoutType,
                    paymentMethod: paymentMethods
                )
            )
        }
    }
}


public extension MercadoPagoCheckout {
    /// Information about the payer initiating the checkout.
    public struct Payer: Sendable {
        /// The payer's email address.
        public var email: String

        /// Creates a new payer with the given email.
        ///
        /// - Parameter email: The payer's email address.
        public init(email: String) {
            self.email = email
        }
    }
    
    /// Configuration specific to the card form checkout experience.
    public struct CardFormConfiguration: Sendable {
        /// The transaction amount to be charged. Optional; when `nil` the amount is determined server-side.
        public var amount: Double?
        /// Payer information pre-filled in the form. Optional.
        public var payer: Payer?

        /// Creates a new card form configuration.
        ///
        /// - Parameters:
        ///   - amount: The transaction amount. Defaults to `nil`.
        ///   - payer: Pre-filled payer information. Defaults to `nil`.
        public init(amount: Double? = nil, payer: Payer? = nil) {
            self.amount = amount
            self.payer = payer
        }
    }
    
    /// The type of checkout experience to launch.
    public enum CheckoutType: Sendable {
        /// A card-based payment form.
        ///
        /// - Parameter cardFormConfiguration: Configuration values for the card form, such as amount and payer.
        case cardForm(cardFormConfiguration: CardFormConfiguration)
    }

    /// A payment method available during the checkout flow.
    public enum PaymentMethod: Sendable {
        /// A credit, debit, or prepaid card payment.
        /// - Parameters:
        ///   - cardTypes: The card types accepted (e.g. `.credit`, `.debit`, `.prepaid`).
        ///   - installment: Installment options for this payment method. Defaults to ``Installment/init()``.
        case card(cardTypes: [CardType], installment: Installment? = Installment())
        /// Pix instant payment.
        case pix
        /// Boleto bank slip payment.
        case boleto
        /// Loan-based payment.
        ///
        /// - Parameter installment: Installment options for this payment method. Defaults to ``Installment/init()``.
        case loan(installment: Installment? = Installment())

        /// The default set of payment methods: card (credit, debit, prepaid), Pix, and Boleto.
        public static var defaults: [PaymentMethod] {
            [
                .card(cardTypes: [.credit, .debit, .prepaid]),
                .pix,
                .boleto
            ]
        }
    }

    /// Installment constraints for a payment method.
    public struct Installment: Sendable {
        /// The minimum number of installments allowed.
        public var minInstallments: Int
        /// The maximum number of installments allowed.
        public var maxInstallments: Int

        /// Creates a new installment configuration.
        ///
        /// - Parameters:
        ///   - minInstallments: The minimum number of installments. Defaults to `1`.
        ///   - maxInstallments: The maximum number of installments. Defaults to `180`.
        public init(minInstallments: Int = 1, maxInstallments: Int = 180) {
            self.minInstallments = minInstallments
            self.maxInstallments = maxInstallments
        }
    }

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
