//
//  APIErrorResponse.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 28/01/25.
//

package struct APIErrorResponse: Codable, Equatable {
    let code: String
    let message: String

    package init(code: String, message: String) {
        self.code = code
        self.message = message
    }
}
