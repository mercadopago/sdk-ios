//
//  ReviewConfirmFooter.swift
//  MercadoPagoSDK
//

/// The confirm button, total amount and installment description shown at the bottom of the review
/// and confirm screen.
///
/// `installments` mirrors the installments screen's contract: the label and its highlighted
/// fragment come as separate strings plus a semantic `state`, so the SDK resolves the highlight
/// color from the theme (e.g. `state == "success"` → positive/green) instead of the backend
/// sending a raw color. See CHOBK-4695 for the backend rollout.
struct ReviewConfirmFooter: Codable {
    let button: Button
    let totalAmount: String
    let installments: Installments?

    struct Button: Codable {
        let label: String
    }

    struct Installments: Codable {
        /// Primary text, e.g. `"3x $ 1.666,66"`.
        let label: String
        /// Highlighted fragment, e.g. `"sin interés"`. Colored via `state`.
        let secondaryLabel: String?
        /// Semantic state driving the highlight color (e.g. `"success"`), matching the installments
        /// screen vocabulary. The SDK maps it to a theme color — never a raw color from the backend.
        let state: String?

        enum CodingKeys: String, CodingKey {
            case label
            case secondaryLabel = "secondary_label"
            case state
        }
    }

    enum CodingKeys: String, CodingKey {
        case button
        case totalAmount = "total_amount"
        case installments
    }
}
