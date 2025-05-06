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
        return try await executeWithTracking(
            operation: {
                return try await self.generateTokenUseCase
                    .tokenize(
                        cardNumber: cardNumber,
                        expirationDateMonth: expirationMonth,
                        expirationDateYear: expirationYear,
                        securityCodeInput: securityCode,
                        cardID: nil,
                        cardHolderName: cardHolderName,
                        identificationType: documentType,
                        identificationNumber: documentNumber
                    )
            },
            path: AnalyticsPath.tokenization,
            extractEventData: { _ -> TokenizationEventData? in
                return TokenizationEventData(isSaveCard: false, documentType: documentType)
            }
        )
    }
}
