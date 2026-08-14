//
//  EmailFieldState.swift
//  MercadoPagoSDK
//

/// Presentation of the payer email row on the review and confirm screen.
///
/// Derived from the `ReviewConfirmItem` of type `"payer_email"`. `changeLabel` mirrors the BFF's
/// decision: present only when the row should offer the "Modificar" action — the SDK doesn't
/// decide this on its own (see DD-6 in the technical spec).
struct EmailFieldState {
    let label: String
    let maskedEmail: String
    let changeLabel: String?

    /// - Returns: `nil` when `item` is not the payer email row, or has no masked email value.
    init?(item: ReviewConfirmItem) {
        guard item.type == "payer_email", let maskedEmail = item.value else { return nil }
        self.label = item.label
        self.maskedEmail = maskedEmail
        self.changeLabel = item.changeLabel
    }
}
