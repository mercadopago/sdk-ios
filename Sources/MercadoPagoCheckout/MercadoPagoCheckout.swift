//
//  MercadoPagoCheckout.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 09/06/25.
//
import MPFoundation
import SwiftUI
import UIKit

// The main entry point for the MercadoPago checkout experience.
//
// `MercadoPagoCheckout` encapsulates the full configuration needed to launch a
// payment flow, including appearance theming and the checkout behavior. Use the
// ``Builder`` to assemble an instance fluently, then present it via SwiftUI,
// UIKit modal, or a `UINavigationController` push.
//
// The generic parameter `T` represents the concrete ``MPPaymentData`` variant produced by the
// flow. It is inferred from the ``CheckoutType`` passed to the ``Builder``, so the
// ``MercadoPagoCheckoutResult`` delivered to the callback carries the concrete subtype directly.
//
// ## Usage
//
// ```swift
// let checkout = MercadoPagoCheckout.Builder(
//     checkoutType: .cardTransaction(order: .init(amount: 99.90, payer: .init(email: "..."))),
//     checkoutAppearance: .init()
// )
// .setPaymentMethods([.card(allowedTypes: [.credit, .debit])])
// .build()
//
// // SwiftUI
// checkout.show { result in
//     // result: MercadoPagoCheckoutResult<MPPaymentData.CardTransaction>
//     print(result)
// }
//
// // UIKit – modal
// checkout.present(from: self) { result in
//     print(result)
// }
// ```

public struct MercadoPagoCheckout<T: MPPaymentData.Kind>: Sendable, Identifiable {
    /// A unique identifier for this checkout instance.
    public let id = UUID()

    /// The visual appearance applied to the checkout flow.
    var theme: CheckoutAppearance
    /// The behavioral configuration for the checkout flow.
    var configuration: CheckoutConfiguration

    /// Creates a `MercadoPagoCheckout` with explicit theme and configuration values.
    ///
    /// Prefer using ``Builder`` for a more ergonomic construction experience.
    ///
    /// - Parameters:
    ///   - theme: The visual appearance for the checkout. Defaults to a default ``CheckoutAppearance``.
    ///   - checkoutConfiguration: The behavioral configuration.
    @MainActor
    init(theme: CheckoutAppearance = CheckoutAppearance(), configuration: CheckoutConfiguration) {
        self.theme = theme
        self.configuration = configuration
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
        onResult: @escaping (MercadoPagoCheckoutResult<T>) -> Void
    ) -> some View {
        CardFormBrick<T>(
            configuration: self.configuration,
            appearance: self.theme,
            onResult: onResult
        )
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
        onResult: @escaping (MercadoPagoCheckoutResult<T>) -> Void
    ) {
        let cardFormBrick = CardFormBrick<T>(
            configuration: configuration,
            appearance: theme,
            onResult: onResult
        )
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
        onResult: @escaping (MercadoPagoCheckoutResult<T>) -> Void
    ) {
        let cardFormBrick = CardFormBrick<T>(
            configuration: configuration,
            appearance: theme,
            onResult: onResult
        )
        let hostingController = UIHostingController(rootView: cardFormBrick)
        navigationController.pushViewController(hostingController, animated: animated)
    }
}

public extension MercadoPagoCheckout {
    /// Behavioral configuration for the checkout flow.
    ///
    /// Defines the checkout experience
    struct CheckoutConfiguration: Sendable {
        /// The type of checkout experience to present.
        public var type: CheckoutType
        /// The payment methods available during the checkout flow.
        public var paymentMethod: [PaymentMethod]

        /// Creates a new checkout configuration.
        ///
        /// - Parameters:
        ///   - checkoutType: The type of checkout experience to present.
        ///   - paymentMethod: The payment methods available to the user.
        public init(type: CheckoutType, paymentMethod: [PaymentMethod]) {
            self.type = type
            self.paymentMethod = paymentMethod
        }
    }

    /// Theme configuration for the checkout flow.
    ///
    /// Holds the ``MPTheme`` instances used in light and dark modes.
    struct MercadoPagoThemeConfiguration: Sendable {
        /// The theme applied when the interface is in light mode.
        public var light: MPTheme

        /// The theme applied when the interface is in dark mode.
        public var dark: MPTheme

        /// Creates a new theme configuration.
        ///
        /// - Parameters:
        ///   - light: The theme for light mode. Defaults to `MPLightTheme` when `nil`.
        ///   - dark: The theme for dark mode. Defaults to `MPLightTheme` when `nil`.
        @MainActor
        public init(
            light: MPTheme? = nil,
            dark: MPTheme? = nil
        ) {
            self.light = light ?? MPLightTheme()
            self.dark = dark ?? MPLightTheme()
        }
    }

    /// Visual appearance settings for the checkout flow.
    ///
    /// Controls which color scheme is applied and provides the theme configuration
    /// for light and dark modes via ``MercadoPagoThemeConfiguration``.
    struct CheckoutAppearance: Sendable {
        /// The preferred user interface style for the checkout flow.
        ///
        /// Defaults to `.automatic`, which follows the device setting.
        public var style: MercadoPagoUserInterfaceStyle

        /// The theme configuration holding light and dark mode themes.
        public var themeConfiguration: MercadoPagoThemeConfiguration

        /// Creates a new appearance configuration.
        ///
        /// - Parameters:
        ///   - style: The preferred user interface style. Defaults to `.automatic`.
        ///   - theme: The theme configuration for light and dark modes.
        @MainActor
        public init(
            style: MercadoPagoUserInterfaceStyle = .automatic,
            theme: MercadoPagoThemeConfiguration = MercadoPagoThemeConfiguration()
        ) {
            self.style = style
            self.themeConfiguration = theme
        }
    }
}
