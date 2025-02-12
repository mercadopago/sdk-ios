//
//  SiteIDEntry.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 12/02/25.
//

struct SiteIDEntry: Codable, Sendable {
    let siteID: String

    enum CodingKeys: String, CodingKey {
        case siteID = "site_id"
    }
}
