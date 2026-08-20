//
//  ReviewConfirmCardDetails.swift
//  MercadoPagoSDK
//

/// Card fields the review and confirm request needs beyond `OrderTransactionParams`, so the
/// backend can resolve the issuer name and render the card row. All `nil` for non-card methods.
struct ReviewConfirmCardDetails {
    let bin: String?
    /// Issuer id in its domain form. `FetchReviewConfirmUseCase` converts it to the request's string.
    let issuerId: Int?
    let lastFourDigits: String?
    let installmentAmount: String?
}
