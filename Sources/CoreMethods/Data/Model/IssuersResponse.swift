//
//  IssuersResponse.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 24/03/25.
//

struct IssuersResponse: Codable, Sendable {
    let id: String
    let name: String
    let merchantAccountId: String
    let processingMode: String
    let status: String
    let thumbnail: String

    enum CodingKeys: String, CodingKey {
        case merchantAccountId = "merchant_account_id"
        case processingMode = "processing_mode"
        case id, status, thumbnail, name
    }
}

extension Issuer {
    init(with data: IssuersResponse) {
        self.id = data.id
        self.name = data.name
        self.merchantAccountId = data.merchantAccountId
        self.processingMode = data.processingMode
        self.status = data.status
        self.thumbnail = data.thumbnail
    }
}
