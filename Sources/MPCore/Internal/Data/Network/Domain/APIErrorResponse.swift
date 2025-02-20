//
//  APIErrorResponse.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 28/01/25.
//

public struct APIErrorResponse: Codable, Equatable, Sendable {
    let code: String
    let message: String

    package init(code: String, message: String) {
        self.code = code
        self.message = message
    }
}
