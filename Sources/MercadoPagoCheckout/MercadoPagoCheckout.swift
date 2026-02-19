//
//  MercadoPagoCheckout.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 09/06/25.
//
import MPFoundation
import UIKit
import SwiftUI

/// The main entry point for the MercadoPago checkout experience.
///
/// `MercadoPagoCheckout` encapsulates the full configuration needed to launch a
/// payment flow, including appearance theming and the checkout behavior. Use the
/// ``Builder`` to assemble an instance fluently, then present it via SwiftUI,
/// UIKit modal, or a `UINavigationController` push.
///
/// ## Usage
///
/// ```swift
/// let checkout = MercadoPagoCheckout.Builder(
///     checkoutType: .cardForm(cardFormConfiguration: .init(amount: 99.90)),
///     checkoutAppearance: .init()
/// )
/// .setPaymentMethod([.card(cardTypes: [.credit, .debit]), .pix])
/// .build()
///
/// // SwiftUI
/// checkout.show { result in
///     print(result)
/// }
///
/// // UIKit – modal
/// checkout.present(from: self) { result in
///     print(result)
/// }
/// ```

public struct MercadoPagoCheckout: Sendable, Identifiable {
    /// A unique identifier for this checkout instance.
    public let id: UUID = UUID()

    /// Visual appearance settings for the checkout flow.
    ///
    /// Controls which color scheme is applied and provides separate ``MPTheme``
    /// values for light and dark modes.
    public struct CheckoutAppearance: Sendable {
        /// The preferred user interface style for the checkout flow.
        ///
        /// Defaults to `.automatic`, which follows the device setting.
        public var style: UserInterfaceStyle = .automatic

        /// The theme applied when the interface is in light mode.
        public var light: MPTheme

        /// The theme applied when the interface is in dark mode.
        public var dark: MPTheme

        /// Creates a new appearance configuration.
        ///
        /// - Parameters:
        ///   - style: The preferred user interface style. Defaults to `.automatic`.
        ///   - light: The theme for light mode. Defaults to `MPLightTheme` when `nil`.
        ///   - dark: The theme for dark mode. Defaults to `MPLightTheme` when `nil`.
        @MainActor
        public init(
            style: UserInterfaceStyle = .automatic,
            light: MPTheme? = nil,
            dark: MPTheme? = nil
        ) {
            self.style = style
            self.light = light ?? MPLightTheme()
            self.dark = dark ?? MPLightTheme()
        }
    }

    /// The visual appearance applied to the checkout flow.
    var theme: CheckoutAppearance
    /// The behavioral configuration for the checkout flow.
    var checkoutConfiguration: CheckoutConfiguration

    /// Creates a `MercadoPagoCheckout` with explicit theme and configuration values.
    ///
    /// Prefer using ``Builder`` for a more ergonomic construction experience.
    ///
    /// - Parameters:
    ///   - theme: The visual appearance for the checkout. Defaults to a default ``CheckoutAppearance``.
    ///   - checkoutConfiguration: The behavioral configuration.
    @MainActor
    public init(theme: CheckoutAppearance = CheckoutAppearance(), checkoutConfiguration: CheckoutConfiguration) {
        self.theme = theme
        self.checkoutConfiguration = checkoutConfiguration
    }

    /// Returns a SwiftUI view that presents the checkout flow.
    ///
    /// Use this method when embedding the checkout inside an existing SwiftUI hierarchy.
    ///
    /// - Parameter onResult: A closure called with the checkout result when the flow finishes.
    /// - Returns: A SwiftUI view representing the checkout flow.
    @MainActor
    @ViewBuilder
    public func show(
        onResult: @escaping (MercadoPagoCheckoutResult) -> Void
    ) -> some View {
        CardFormBrick(configuration: self, onResult: onResult)
    }

    /// Presents the checkout flow modally from a UIKit view controller.
    ///
    /// The checkout is wrapped in a `UIHostingController` and presented full-screen.
    ///
    /// - Parameters:
    ///   - viewController: The view controller from which to present the checkout.
    ///   - animated: Whether to animate the presentation. Defaults to `true`.
    ///   - onResult: A closure called with the checkout result when the flow finishes.
    @MainActor
    public func present(
        from viewController: UIViewController,
        animated: Bool = true,
        onResult: @escaping (MercadoPagoCheckoutResult) -> Void
    ) {
        let cardFormBrick = CardFormBrick(configuration: self, onResult: onResult)
        let hostingController = UIHostingController(rootView: cardFormBrick)
        hostingController.modalPresentationStyle = .fullScreen
        viewController.present(hostingController, animated: animated)
    }

    /// Pushes the checkout flow onto a UIKit navigation stack.
    ///
    /// The checkout is wrapped in a `UIHostingController` and pushed onto the
    /// provided `UINavigationController`.
    ///
    /// - Parameters:
    ///   - navigationController: The navigation controller to push the checkout onto.
    ///   - animated: Whether to animate the push. Defaults to `true`.
    ///   - onResult: A closure called with the checkout result when the flow finishes.
    @MainActor
    public func push(
        to navigationController: UINavigationController,
        animated: Bool = true,
        onResult: @escaping (MercadoPagoCheckoutResult) -> Void
    ) {
        let cardFormBrick = CardFormBrick(configuration: self, onResult: onResult)
        let hostingController = UIHostingController(rootView: cardFormBrick)
        navigationController.pushViewController(hostingController, animated: animated)
    }

    /// Behavioral configuration for the checkout flow.
    ///
    /// Defines the checkout experience
    public struct CheckoutConfiguration: Sendable {
        /// The type of checkout experience to present.
        public var checkoutType: CheckoutType
        /// The payment methods available during the checkout flow.
        public var paymentMethod: [PaymentMethod]

        /// Creates a new checkout configuration.
        ///
        /// - Parameters:
        ///   - checkoutType: The type of checkout experience to present.
        ///   - paymentMethod: The payment methods available to the user.
        public init(checkoutType: CheckoutType, paymentMethod: [PaymentMethod]) {
            self.checkoutType = checkoutType
            self.paymentMethod = paymentMethod
        }
    }

    /// Information about the payer initiating the checkout.
    public struct Payer: Sendable {
        /// The payer's email address.
        var email: String

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
        var minInstallments: Int
        /// The maximum number of installments allowed.
        var maxInstallments: Int

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

