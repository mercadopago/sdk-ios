//
//  ReviewConfirmItem.swift
//  MercadoPagoSDK
//

/// A single data row on the review and confirm screen (e.g. payment method, payer email).
///
/// The backend is the only source of truth for what a row shows: the `button` (e.g. "Modificar")
/// is present only when the row should offer a modify action — the SDK never decides this on its own.
struct ReviewConfirmItem: Codable {
    /// Row identifier, e.g. `"payment_method"` or `"payer_email"`.
    let type: String
    let label: String
    let value: String?
    let button: Button?

    struct Button: Codable {
        let label: String
    }

    enum CodingKeys: String, CodingKey {
        case type
        case label
        case value
        case button
    }
}
