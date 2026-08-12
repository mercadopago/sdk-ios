//
//  MPOrder.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 20/02/26.
//
import Foundation

protocol CheckoutTypeConfiguration: Sendable {
    /// The transaction amount to be charged.
    var amount: Decimal { get }
}

/// Represents an order created through the MercadoPago Orders API.
///
/// Both ``orderId`` and ``clientToken`` are returned by the Orders API when the order
/// is created. Pass an `MPOrder` to
/// ``MercadoPagoCheckout/CheckoutType/payment(order:cardIds:)`` or
/// ``MercadoPagoCheckout/CheckoutType/cardTransaction(order:)`` to start the checkout.
///
/// ## Initializing from an order creation response
///
/// ```swift
/// // orderId and clientToken come from the Orders API create-order response.
/// let order = MPOrder(
///     orderId: orderResponse.id,
///     clientToken: orderResponse.clientToken,
///     amount: 199.90,
///     payer: MPPayer(email: buyerEmail)
/// )
/// ```
///
/// ## Using the order in the Payment flow
///
/// ```swift
/// let checkout = MercadoPagoCheckout.Builder(
///     checkoutType: .payment(order: order),
///     checkoutAppearance: .init()
/// )
/// .build()
///
/// checkout.show { result in
///     switch result {
///     case .success(let data): // data: MPPaymentData.Payment
///         print(data.orderId, data.orderStatus)
///     case .userCancelled:
///         break
///     case .failure:
///         break
///     }
/// }
/// ```
///
/// ## Using the order in the Card Transaction flow
///
/// ```swift
/// let checkout = MercadoPagoCheckout.Builder(
///     checkoutType: .cardTransaction(order: order),
///     checkoutAppearance: .init()
/// )
/// .build()
/// ```
///
/// ## Topics
///
/// ### Order identity
/// - ``orderId``
/// - ``clientToken``
///
/// ### Charge details
/// - ``amount``
/// - ``payer``
public struct MPOrder: CheckoutTypeConfiguration {
    /// The ID returned by the Orders API when the order was created.
    public var orderId: String

    /// The token returned by the Orders API when the order was created.
    ///
    /// Used by the SDK to authorize the payment request
    public let clientToken: String

    /// The total amount to charge, in the account's default currency.
    public var amount: Decimal

    /// Payer information used to pre-fill the checkout form.
    ///
    /// Providing at least ``MPPayer/email`` reduces friction during checkout.
    public var payer: MPPayer

    /// Creates an order configuration to pass to the MercadoPago checkout.
    ///
    /// - Parameters:
    ///   - orderId: The ID returned by the Orders API when the order was created.
    ///   - clientToken: The token returned by the Orders API when the order was created.
    ///   - amount: The total amount to charge.
    ///   - payer: Payer information used to pre-fill the checkout form.
    public init(orderId: String, clientToken: String, amount: Decimal, payer: MPPayer) {
        self.orderId = orderId
        self.clientToken = clientToken
        self.amount = amount
        self.payer = payer
    }
}

struct SavedCardConfiguration: CheckoutTypeConfiguration {
    var amount: Decimal = .zero

    init() {}
}
