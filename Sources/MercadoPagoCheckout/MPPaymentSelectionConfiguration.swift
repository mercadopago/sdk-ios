//
//  MPPaymentSelectionConfiguration.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 28/05/26.
//

/// Configuration for the payment selection checkout experience.
///
/// Pass this to ``MercadoPagoCheckout/CheckoutType/payment(configuration:)`` to launch
/// the PaymentBrick
///
/// ## Required fields
///
/// `orderId` and `amount` are mandatory.
///
/// ## Example
///
/// ```swift
/// let configuration = PaymentSelectionConfiguration(
///     orderId: "order-123",
///     amount: 150.0
/// )
///
/// let checkout = MercadoPagoCheckout.Builder(
///     checkoutType: .payment(configuration: configuration),
///     checkoutAppearance: .init()
/// )
/// .build()
/// ```
public struct MPPaymentSelectionConfiguration: CheckoutTypeConfiguration, Sendable {
    // MARK: - Required

    /// ID of the Order created by the seller via the Order API.
    public var orderId: String

    /// Transaction amount.
    public var amount: Double

    public init(orderId: String, amount: Double) {
        self.orderId = orderId
        self.amount = amount
    }
}
