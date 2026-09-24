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
            expirationDateMonth: params.expirationMonth,
            expirationDateYear: params.expirationYear,
            securityCode: params.securityCode,
            cardHolderName: params.cardHolderName,
            documentType: params.documentType,
            documentNumber: params.documentNumber,
            cardID: params.cardId
        )
    }

    /// Checkout owns errors for this flow; CoreMethods still owns the successful tokenization event.
    package func createTokenForCheckout(_ params: CardParams) async throws -> CardToken {
        return try await tokenization(
            cardNumber: params.cardNumber,
            expirationDateMonth: params.expirationMonth,
            expirationDateYear: params.expirationYear,
            securityCode: params.securityCode,
            cardHolderName: params.cardHolderName,
            documentType: params.documentType,
            documentNumber: params.documentNumber,
            cardID: params.cardId,
            tracksErrorEvents: false
        )
    }
}
