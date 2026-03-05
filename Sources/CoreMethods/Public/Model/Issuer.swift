//
//  Issuer.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 24/03/25.
//

public struct Issuer: Codable, Sendable, Equatable {
    public let id: String
    public let name: String
    public let merchantAccountId: String
    public let processingMode: String
    public let status: String
    public let thumbnail: String
}
