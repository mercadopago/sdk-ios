//
//  MPScreen.swift
//  MercadoPagoSDK
//

/// A checkout screen the user reached before cancelling.
///
/// Delivered as an ordered `screens` list on the cancellation context — for example
/// ``MPUserCancelledContext/CardTransaction/screens`` or
/// ``MPUserCancelledContext/Payment/screens`` — so you can tell how far the user progressed
/// through the flow before leaving. The order reflects the sequence in which the user visited the
/// screens.
///
/// - Important: New cases may be added in future SDK versions. Include a `default` branch when you
///   switch over a ``Screen`` value.
public enum MPScreen: Sendable, Equatable {
    /// The payment method selector screen (first screen of the PaymentBrick flow).
    case paymentMethodSelector
    /// The installments selection screen.
    case installments
    /// The security code (CVV) entry screen shown when paying with a saved card.
    case securityCode
    /// The offline payment method selection screen (e.g. choosing a ticket provider).
    case offlineMethodSelector
    /// The review and confirm screen shown before the user finalises payment.
    case reviewAndConfirm
}
