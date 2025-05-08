//
//  CoreMethods+CreateToken.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 06/05/25.
//
import Foundation

@_documentation(visibility: private)
extension CoreMethods {
    public func createToken(
        _ params: CardParams
    ) async throws -> CardToken {
        
        return try await tokenization(
            cardNumber: params.cardNumber,
            expirationDateMonth: params.expirationYear,
            expirationDateYear: params.expirationMonth,
            securityCode: params.securityCode,
            cardHolderName: params.cardHolderName,
            documentType: params.documentType,
            documentNumber: params.documentNumber
        )
    }
}
