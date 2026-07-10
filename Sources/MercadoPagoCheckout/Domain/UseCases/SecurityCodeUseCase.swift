//
//  SecurityCodeUseCase.swift
//  MercadoPagoSDK
//

import CoreMethods

struct SecurityCodeUseCase {
    private let service: CheckoutServiceProtocol

    init(service: CheckoutServiceProtocol = CheckoutService()) {
        self.service = service
    }

    func execute(
        code: String,
        expectedLength: Int,
        cardId: String
    ) async throws(MercadoPagoCheckoutError) -> CardToken {
        try self.validateFormat(code: code, expectedLength: expectedLength)
        let params = CardParams(
            cardNumber: "",
            expirationYear: "",
            expirationMonth: "",
            securityCode: code,
            documentType: nil,
            documentNumber: nil,
            cardHolderName: "",
            cardId: cardId
        )
        return try await self.service.createCardToken(cardParams: params)
    }

    // MARK: - Validation

    private func validateFormat(code: String, expectedLength: Int) throws(MercadoPagoCheckoutError) {
        guard !code.isEmpty else {
            throw MercadoPagoCheckoutError(code: .unknown, localizedDescription: "security_code_empty", location: .tokenization)
        }
        guard code.allSatisfy(\.isNumber) else {
            throw MercadoPagoCheckoutError(code: .unknown, localizedDescription: "security_code_invalid_format", location: .tokenization)
        }
        guard code.count == expectedLength else {
            throw MercadoPagoCheckoutError(code: .unknown, localizedDescription: "security_code_invalid_length", location: .tokenization)
        }
    }
}
