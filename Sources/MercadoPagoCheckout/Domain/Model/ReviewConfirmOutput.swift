//
//  ReviewConfirmOutput.swift
//  MercadoPagoSDK
//

/// The data the review and confirm screen renders, converted from the raw `ReviewConfirmResponse`.
///
/// `header`, `items`, `footerSummary` and `footer` carry no wire-format concerns of their own
/// (plain labels and amounts), so this type reuses the response's value types directly instead of
/// redefining them.
struct ReviewConfirmOutput {
    let header: ReviewConfirmHeader
    let items: [ReviewConfirmItem]
    let footerSummary: ReviewConfirmFooterSummary?
    let footer: ReviewConfirmFooter

    init(from response: ReviewConfirmResponse) {
        self.header = response.header
        self.items = response.items
        self.footerSummary = response.footerSummary
        self.footer = response.footer
    }
}
