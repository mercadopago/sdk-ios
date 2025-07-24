//
//  GenerateCardTokenUseCase.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 18/02/25.
//

import Foundation
#if SWIFT_PACKAGE
    import MPCore
#endif
protocol GenerateCardTokenUseCaseProtocol: Sendable {
    func tokenize(
        cardNumber: String?,
        expirationDateMonth: String?,
        expirationDateYear: String?,
        securityCodeInput: String,
        cardID: String?,
        cardHolderName: String?,
        identificationType: String?,
        identificationNumber: String?
    ) async throws -> CardToken
}

final class GenerateCardTokenUseCase: GenerateCardTokenUseCaseProtocol {
    private let repository: CoreMethodsRepositoryProtocol

    typealias Dependency = HasFingerPrint

    let dependencies: Dependency

    init(
        dependencies: Dependency,
        repository: CoreMethodsRepositoryProtocol = CoreMethodsRepository()
    ) {
        self.repository = repository
        self.dependencies = dependencies
    }

    func tokenize(
        cardNumber: String?,
        expirationDateMonth: String?,
        expirationDateYear: String?,
        securityCodeInput: String,
        cardID: String?,
        cardHolderName: String?,
        identificationType: String?,
        identificationNumber: String?
    ) async throws -> CardToken {
        var buyerIdentification: BuyerIdentification?

        if let cardHolderName {
            buyerIdentification = BuyerIdentification(
                name: cardHolderName,
                number: identificationNumber,
                type: identificationType
            )
        }

        let deviceData = await dependencies.fingerPrint.getDeviceData()

        let cardData = CardTokenBody(
            cardNumber: cardNumber,
            expirationMonth: expirationDateMonth,
            expirationYear: expirationDateYear,
            securityCode: securityCodeInput,
            cardId: cardID,
            buyerIdentification: buyerIdentification,
            device: deviceData
        )

        let response = try await repository.generateCardToken(cardData)

        return .init(token: response.id)
    }
}
