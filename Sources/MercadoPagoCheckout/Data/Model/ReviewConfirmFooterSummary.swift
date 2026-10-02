//
//  ReviewConfirmFooterSummary.swift
//  MercadoPagoSDK
//

/// The order breakdown shown above the footer, resolved by the backend from the order — products,
/// discount coupon and installment interest are all optional and independent of each other.
struct ReviewConfirmFooterSummary: Codable {
    let products: [SummaryLine]?
    let coupon: SummaryLine?
    let interest: Interest?

    /// A single label + amount row in the breakdown, e.g. a product line or the discount coupon.
    struct SummaryLine: Codable {
        let label: String
        let amount: String
    }

    struct Interest: Codable {
        let title: String
        let tooltipMessage: String
        let amount: String

        enum CodingKeys: String, CodingKey {
            case title
            case tooltipMessage = "tooltip_message"
            case amount
        }
    }
}
