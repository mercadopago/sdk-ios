//
//  StatusScreenRequestBody.swift
//  MercadoPagoSDK
//

struct StatusScreenRequestBody: Encodable, Sendable {
    struct SellerInfo: Encodable, Sendable {
        let name: String?
        let iconURL: String?

        enum CodingKeys: String, CodingKey {
            case name
            case iconURL = "icon_url"
        }
    }

    let orderID: String
    let lastFourDigits: String?
    let sellerInfo: SellerInfo?

    enum CodingKeys: String, CodingKey {
        case orderID = "order_id"
        case lastFourDigits = "last_four_digits"
        case sellerInfo = "seller_info"
    }
}
