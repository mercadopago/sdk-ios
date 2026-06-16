//
//  MercadoPagoCheckoutResult.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 30/01/26.
//
import Foundation

/// The outcome of a checkout flow, delivered to the `onResult` closure when the flow finishes.
///
/// The payment data type `T` matches the ``MercadoPagoCheckout/CheckoutType`` you chose when
/// building the checkout: `.cardTransaction(order:)` produces an
/// `MercadoPagoCheckoutResult<MPPaymentData.CardTransaction>`, and `.saveCard` produces an
/// `MercadoPagoCheckoutResult<MPPaymentData.CardSave>`. Both the ``success(_:)`` payload and the
/// ``userCancelled(_:)`` context are concretely typed for that flow, so you can read their fields
/// directly without casting.
///
/// Handle every case in your result closure:
///
/// ```swift
/// checkout.present(from: self) { result in
///     switch result {
///     case let .success(payment):
///         // payment: MPPaymentData.CardTransaction
///         print("Paid with token \(payment.token), \(payment.installment ?? 1) installments")
///
///     case let .error(error):
///         // Something went wrong during the flow.
///         present(errorAlert(for: error))
///
///     case let .userCancelled(context):
///         // context: MPUserCancelledContext.CardTransaction
///         // The user abandoned the flow. Inspect what they had entered:
///         print("Cancelled after visiting screens: \(context.screens)")
///         print("Card form field states: \(context.cardForm.fields)")
///     }
/// }
/// ```
///
/// - Tip: Because `T` is fixed by the checkout type, the ``success(_:)`` payload and the
///   ``userCancelled(_:)`` context are already concrete — read their properties directly, with no
///   downcast.
///
/// ## Topics
///
/// ### Outcomes
///
/// - ``success(_:)``
/// - ``error(_:)``
/// - ``userCancelled(_:)``
public enum MercadoPagoCheckoutResult<T: MPPaymentData.Kind>: Sendable {
    /// The flow completed successfully.
    ///
    /// The associated value is the concrete ``MPPaymentData`` variant for the configured
    /// checkout type — for example ``MPPaymentData/CardTransaction`` or
    /// ``MPPaymentData/CardSave`` — carrying the resulting token and payment details.
    case success(T)

    /// The flow failed before completing.
    ///
    /// Inspect the associated ``MercadoPagoCheckoutError`` to decide how to recover or what to
    /// surface to the user.
    case error(MercadoPagoCheckoutError)

    /// The user cancelled the flow before completing it (for example by dismissing the screen).
    ///
    /// The associated value is the concrete ``MPUserCancelledContext`` variant for the configured
    /// checkout type, describing how far the user progressed and what they had entered at the
    /// moment they left — useful for analytics or to pre-fill a retry.
    case userCancelled(T.Cancellation)
}
