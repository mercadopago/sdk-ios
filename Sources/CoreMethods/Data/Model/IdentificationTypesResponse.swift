//
//  IdentificationTypesResponse.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 25/02/25.
//

struct IdentificationTypesResponse: Codable, Sendable {
    let id: String
    let name: String
    let type: String
    let minLength: Int
    let maxLength: Int

    enum CodingKeys: String, CodingKey {
        case id, name, type
        case minLength = "min_length"
        case maxLength = "max_length"
    }
}
