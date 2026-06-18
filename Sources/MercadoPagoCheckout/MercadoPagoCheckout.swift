//
//  MercadoPagoCheckout.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 09/06/25.
//
import MPFoundation
import SwiftUI
import UIKit

/// The main entry point for presenting the MercadoPago checkout experience.
///
/// `MercadoPagoCheckout` bundles the appearance and behavior of a payment flow. Build an instance
/// with ``Builder``, then present it via SwiftUI (``show(onResult:)``), a UIKit modal
/// (``present(from:animated:onResult:)``), or a navigation push
/// (``push(to:animated:onResult:)``). When the flow finishes, your `onResult` closure receives a
/// ``MercadoPagoCheckoutResult``.
///
/// The generic parameter `T` is the concrete ``MPPaymentData`` variant the flow produces. You do
/// not specify it directly — it is inferred from the ``CheckoutType`` you pass to the ``Builder``,
/// so the result delivered to your closure is already typed for the flow you chose.
///
/// ## Usage
///
/// ```swift
/// let checkout = MercadoPagoCheckout.Builder(
///     checkoutType: .cardTransaction(order: .init(amount: 99.90, payer: .init(email: "..."))),
///     checkoutAppearance: .init()
/// )
/// .setPaymentMethodConfiguration([.card(excludedTypes: [.prepaid])])
/// .build()
///
/// // SwiftUI
/// checkout.show { result in
///     // result: MercadoPagoCheckoutResult<MPPaymentData.CardTransaction>
///     print(result)
/// }
///
/// // UIKit – modal
/// checkout.present(from: self) { result in
///     print(result)
/// }
/// ```
///
/// - Tip: You never write the generic parameter `T` yourself. Choosing the ``CheckoutType`` fixes
///   it, and with it the type of ``MercadoPagoCheckoutResult`` your closure receives.
///
/// ## Topics
///
/// ### Building a Checkout
///
/// - ``Builder``
/// - ``CheckoutType``
///
/// ### Presenting the Flow
///
/// - ``show(onResult:)``
/// - ``present(from:animated:onResult:)``
/// - ``push(to:animated:onResult:)``
///
/// ### Receiving the Result
///
/// - ``MercadoPagoCheckoutResult``
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
