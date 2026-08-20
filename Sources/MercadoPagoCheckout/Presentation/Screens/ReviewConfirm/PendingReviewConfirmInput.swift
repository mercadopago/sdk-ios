//
//  PendingReviewConfirmInput.swift
//  MercadoPagoSDK
//

/// Everything the review and confirm screen needs, held by the originating brick until the screen
/// is presented.
///
/// Kept in the brick's state rather than in the navigation route so payment data never travels
/// through route arguments. Shared by the payment and card transaction flows.
struct PendingReviewConfirmInput {
    /// The order being paid — carries both `orderId` and `clientToken`.
    let order: MPOrder
    let paymentParams: OrderTransactionParams
    /// Card fields the review and confirm request needs. All `nil` for non-card methods.
    let cardDetails: ReviewConfirmCardDetails
}
