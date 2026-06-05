//
//  MPUserCancelledContext.swift
//  MercadoPagoSDK
//

/// The context provided when a user cancels a checkout flow.
///
/// Each case corresponds to a specific checkout flow and carries
/// the field states captured at the moment of cancellation.
public enum MPUserCancelledContext: Sendable, Equatable {
    /// The user cancelled during the card form flow.
    case cardForm(MPCardFormUserCancelledContext)
    case installments
}
