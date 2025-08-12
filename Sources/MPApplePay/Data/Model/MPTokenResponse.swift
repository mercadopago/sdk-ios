//
//  MPTokenResponse.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 23/07/25.
//

/// Network response for Apple Pay tokenization.
struct MPTokenResponse: Codable, Sendable {
    let id: String
    let bin: String
}
