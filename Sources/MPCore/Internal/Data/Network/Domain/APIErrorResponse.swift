//
//  APIErrorResponse.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 28/01/25.
//

package struct APIErrorResponse: Decodable, Equatable {
    let code: String
    let message: String
}
