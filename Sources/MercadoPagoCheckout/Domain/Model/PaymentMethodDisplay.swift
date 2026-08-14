//
//  PaymentMethodDisplay.swift
//  MercadoPagoSDK
//

/// Presentation of the payment method row on the review and confirm screen.
///
/// Derived from the `ReviewConfirmItem` of type `"payment_method"`. `changeLabel` mirrors the
/// BFF's decision: present only when the row should show a "Modificar" action.
struct PaymentMethodDisplay {
    let label: String
    let value: String?
    let changeLabel: String?

    /// - Returns: `nil` when `item` is not the payment method row.
    init?(item: ReviewConfirmItem) {
        guard item.type == "payment_method" else { return nil }
        self.label = item.label
        self.value = item.value
        self.changeLabel = item.button?.label
    }
}
