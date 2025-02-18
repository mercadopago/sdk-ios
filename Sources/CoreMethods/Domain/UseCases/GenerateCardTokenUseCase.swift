//
//  GenerateCardTokenUseCase.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 18/02/25.
//

import Foundation
import MPCore

protocol GenerateCardTokenUseCaseProtocol: Sendable {
    func tokenize(
        cardNumber: CardNumberTextField,
        expirationDate: ExpirationDateTextfield,
        securityCodeInput: SecurityCodeTextField
    ) async throws -> CardToken
}

final class GenerateCardTokenUseCase: GenerateCardTokenUseCaseProtocol {
    private let repository: CoreMethodsRepositoryProtocol = CoreMethodsRepository()

    func tokenize(
        cardNumber: CardNumberTextField,
        expirationDate: ExpirationDateTextfield,
        securityCodeInput: SecurityCodeTextField
    ) async throws -> CardToken {
        let cardData = await CardTokenBody(
            cardNumber: cardNumber.input.getValue(),
            expirationMonth: expirationDate.getMonth(),
            expirationYear: expirationDate.getYear(),
            securityCode: securityCodeInput.input.getValue()
        )

        let response = try await repository.generateCardToken(cardData)

        return .init(token: response.id)
    }
}
