//
//  CoreMethods+CreateToken.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 06/05/25.
//
import Foundation

@available(*, unavailable)
@_documentation(visibility: private)
extension CoreMethods {
    public func createToken(
        cardNumber: String,
        expirationYear: String,
        expirationMonth: String,
        securityCode: String,
        documentType: String,
        documentNumber: String,
        cardHolderName: String
    ) async throws -> CardToken {
        return try await tokenization(
            cardNumber: cardNumber,
            expirationDateMonth: expirationYear,
            expirationDateYear: expirationMonth,
            securityCode: securityCode,
            cardHolderName: cardHolderName,
            documentType: documentType,
            documentNumber: documentNumber
        )
    }
}
