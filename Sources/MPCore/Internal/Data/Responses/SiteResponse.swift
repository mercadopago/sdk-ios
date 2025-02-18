//
//  SiteResponse.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 12/02/25.
//

struct SiteResponse: Codable, Sendable {
    let id: String

    enum CodingKeys: String, CodingKey {
        case id = "site_id"
    }
}
