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
        cardNumber: String?,
        expirationDateMonth: String?,
        expirationDateYear: String?,
        securityCodeInput: String,
        cardID: String?
    ) async throws -> CardToken
}

final class GenerateCardTokenUseCase: GenerateCardTokenUseCaseProtocol {
    private let repository: CoreMethodsRepositoryProtocol

    init(repository: CoreMethodsRepositoryProtocol = CoreMethodsRepository()) {
        self.repository = repository
    }

    func tokenize(
        cardNumber: String?,
        expirationDateMonth: String?,
        expirationDateYear: String?,
        securityCodeInput: String,
        cardID: String?
    ) async throws -> CardToken {
        let cardData = CardTokenBody(
            cardNumber: cardNumber,
            expirationMonth: expirationDateMonth,
            expirationYear: expirationDateYear,
            securityCode: securityCodeInput,
            cardId: cardID
        )

        let response = try await repository.generateCardToken(cardData)

        return .init(token: response.id)
    }
}
