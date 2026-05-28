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
// .setPaymentMethodConfiguration([.card(excludedTypes: [.prepaid])])
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
    var theme: MPCheckoutAppearance
    /// The behavioral configuration for the checkout flow.
    var configuration: MPCheckoutConfiguration<T>

    /// Creates a `MercadoPagoCheckout` with explicit theme and configuration values.
    ///
    /// Prefer using ``Builder`` for a more ergonomic construction experience.
    ///
    /// - Parameters:
    ///   - theme: The visual appearance for the checkout. Defaults to a default ``MPCheckoutAppearance``.
    ///   - checkoutConfiguration: The behavioral configuration.
    @MainActor
    init(theme: MPCheckoutAppearance = MPCheckoutAppearance(), configuration: MPCheckoutConfiguration<T>) {
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
