//
//  APIErrorResponse.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 28/01/25.
//

public struct APIErrorResponse: Codable, Equatable, Sendable {
    public let code: String
    package let message: String
    package let errorCode: String?
    package let userErrorMessage: String?

    package init(code: String, message: String, errorCode: String? = nil, userErrorMessage: String? = nil) {
        self.code = code
        self.message = message
        self.errorCode = errorCode
        self.userErrorMessage = userErrorMessage
    }

    enum CodingKeys: String, CodingKey {
        case code
        case message
        case errorCode = "error_code"
        case userErrorMessage = "user_error_message"
    }
}
