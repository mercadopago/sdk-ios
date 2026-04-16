//
//  DeviceSessionResponse.swift
//  MercadoPagoSDK
//

import Foundation

struct DeviceSessionResponse: Codable {
    let meliSessionId: String

    enum CodingKeys: String, CodingKey {
        case meliSessionId = "meli_session_id"
    }
}
