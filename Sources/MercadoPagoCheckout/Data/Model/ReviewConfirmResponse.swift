//
//  ReviewConfirmResponse.swift
//  MercadoPagoSDK
//

/// Raw `POST /review_confirm` response. The backend is the only source of the screen's
/// presentation — this type mirrors the wire format; `ReviewConfirmOutput` is what the UI consumes.
struct ReviewConfirmResponse: Codable {
    let header: ReviewConfirmHeader
    let items: [ReviewConfirmItem]
    let footerSummary: ReviewConfirmFooterSummary?
    let footer: ReviewConfirmFooter

    enum CodingKeys: String, CodingKey {
        case header
        case items
        case footerSummary = "footer_summary"
        case footer
    }
}
