//
//  InputCardData.swift
//  MercadoPagoSDK
//

/// Card data captured from the card form (new card) that the review and confirm request needs
/// beyond the payment data.
///
/// Held in the brick's state until the review and confirm screen is presented, so card data never
/// travels through the navigation route. Both fields are `nil` for non-card flows or when too few
/// digits were entered.
struct InputCardData {
    /// First 8 digits of the entered card.
    let bin: String?
    /// Last 4 digits of the entered card.
    let lastFourDigits: String?
}
