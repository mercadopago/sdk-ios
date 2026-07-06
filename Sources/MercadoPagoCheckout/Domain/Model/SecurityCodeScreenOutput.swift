//
//  SecurityCodeScreenOutput.swift
//  MercadoPagoSDK
//

/// Output required to render the security code (CVV) entry screen for a saved card.
///
/// Built from `security_code.screen` in the `GET /payment_brick/initialization` response.
/// Only present when the saved card requires CVV verification — cards with
/// `has_preapproval_scope` skip this screen entirely.
struct SecurityCodeScreenOutput: Equatable {
    /// Title displayed at the top of the screen.
    let headerTitle: String
    /// Output for the CVV input field.
    let field: Field
    /// Label for the primary action button.
    let buttonLabel: String

    struct Field: Equatable {
        /// Field label shown above the input (e.g. "Código de seguridad").
        let label: String
        /// Placeholder shown inside the input (e.g. "Ej.: ***").
        let placeholder: String
        /// Helper text shown below the input (e.g. "Está en el reverso de tu tarjeta.").
        let helper: String
    }
}
