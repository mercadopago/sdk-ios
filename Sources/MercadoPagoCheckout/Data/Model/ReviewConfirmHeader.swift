//
//  ReviewConfirmHeader.swift
//  MercadoPagoSDK
//

/// The title and optional seller identity shown at the top of the review and confirm screen.
struct ReviewConfirmHeader: Codable {
    let title: String
    let sellerName: String?
    let sellerIconUrl: String?

    enum CodingKeys: String, CodingKey {
        case title
        case sellerName = "seller_name"
        case sellerIconUrl = "seller_icon_url"
    }
}
