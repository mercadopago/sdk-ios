//
//  MPOrder.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 20/02/26.
//

protocol CheckoutTypeConfiguration: Sendable {
    /// The transaction amount to be charged.
    var amount: Double { get }
}

/// Represents a payment order to be processed by the MercadoPago checkout.
///
/// Pass an `MPOrder` when building a checkout with ``MercadoPagoCheckout/CheckoutType/payment(order:)``
/// or ``MercadoPagoCheckout/CheckoutType/cardTransaction(order:)``.
///
/// ## Payment flow
///
/// Use `orderId` when the order was previously created through the MercadoPago Orders API.
/// The SDK uses it to associate the checkout result with your backend order.
///
/// ```swift
/// let order = MPOrder(orderId: "order-abc123", amount: 199.90)
///
/// let checkout = MercadoPagoCheckout.Builder(
///     checkoutType: .payment(order: order),
///     checkoutAppearance: .init()
/// )
/// .build()
/// ```
///
/// ## Card transaction flow
///
/// Provide `amount` and, optionally, `orderId` to associate the charge with an existing order
/// and `payer` to pre-fill the form.
///
/// ```swift
/// let order = MPOrder(orderId: "order-abc123", amount: 199.90, payer: MPPayer(email: "buyer@email.com"))
///
/// let checkout = MercadoPagoCheckout.Builder(
///     checkoutType: .cardTransaction(order: order),
///     checkoutAppearance: .init()
/// )
/// .build()
/// ```
public struct MPOrder: CheckoutTypeConfiguration {
    /// The ID of a previously created order from the MercadoPago Orders API.
    public var orderId: String

    /// The total amount to charge the buyer, in the account's default currency.
    public var amount: Double

    /// Payer details used to pre-fill the checkout form.
    ///
    /// Optional. When provided, the payer's email is shown in the form automatically.
    public var payer: MPPayer?

    /// Creates a new order configuration.
    ///
    /// - Parameters:
    ///   - orderId: ID of a previously created order.
    ///   - amount: Total amount to charge.
    ///   - payer: Optional payer details for pre-filling the form.
    public init(orderId: String = "", amount: Double, payer: MPPayer? = nil) {
        self.orderId = orderId
        self.amount = amount
        self.payer = payer
    }
}

struct SavedCardConfiguration: CheckoutTypeConfiguration {
    var amount: Double = .zero

    init() {}
}
