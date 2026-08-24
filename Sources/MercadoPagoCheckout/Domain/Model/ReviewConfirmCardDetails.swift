//
//  ReviewConfirmCardDetails.swift
//  MercadoPagoSDK
//

import Foundation

/// Card fields the review and confirm request needs beyond `OrderTransactionParams`, so the
/// backend can resolve the issuer name and render the card row. All `nil` for non-card methods.
struct ReviewConfirmCardDetails {
    let bin: String?
    /// Issuer id in its domain form. `FetchReviewConfirmUseCase` converts it to the request's string.
    let issuerId: Int?
    let lastFourDigits: String?
    let installmentAmount: Decimal?
    /// Identifier of a saved card. It is unavailable for a newly entered card and offline methods.
    let cardId: String?

    init(
        bin: String?,
        issuerId: Int?,
        lastFourDigits: String?,
        installmentAmount: Decimal?,
        cardId: String? = nil
    ) {
        self.bin = bin
        self.issuerId = issuerId
        self.lastFourDigits = lastFourDigits
        self.installmentAmount = installmentAmount
        self.cardId = cardId
    }
}
