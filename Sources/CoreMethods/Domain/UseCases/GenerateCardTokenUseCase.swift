//
//  GenerateCardTokenUseCase.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 18/02/25.
//

import Foundation
#if SWIFT_PACKAGE
    import MPCore
    import MPAnalytics
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
    private let paymentMethodUseCase: PaymentMethodUseCaseProtocol

    typealias Dependency = HasFingerPrint

    let dependencies: Dependency

    init(
        dependencies: Dependency,
        repository: CoreMethodsRepositoryProtocol,
        paymentMethodUseCase: PaymentMethodUseCaseProtocol
    ) {
        self.repository = repository
        self.dependencies = dependencies
        self.paymentMethodUseCase = paymentMethodUseCase
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
        try validateExpirationDate(month: expirationDateMonth, year: expirationDateYear)
        try await validateCardData(cardNumber: cardNumber, securityCode: securityCodeInput, cardID: cardID)

        var buyerIdentification: BuyerIdentification?
        
        let session = await MPAnalyticsConfiguration.shared.sessionID
        let version = await MPAnalyticsConfiguration.shared.version

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
            device: deviceData,
            session: session,
            sdkVersion: version
        )

        let response = try await repository.generateCardToken(cardData)

        return .init(
            token: response.id,
            publicKey: response.publicKey,
            bin: response.firstSixDigits,
            expirationMonth: response.expirationMonth,
            expirationYear: response.expirationYear,
            lastFourDigits: response.lastFourDigits,
            cardHolder: .init(
                identification: .init(type: response.cardholder?.identification?.type),
                name: response.cardholder?.name
            ),
            status: response.status,
            dateCreated: response.dateCreated,
            dateLastUpdated: response.dateLastUpdated,
            dateDue: response.dateDue,
            luhnValidation: response.luhnValidation,
            liveMode: response.liveMode,
            requireEsc: response.requireEsc,
            cardNumberLength: response.cardNumberLength,
            securityCodeLength: response.securityCodeLength,
            truncCardNumber: response.truncCardNumber
        )
    }

    private func validateExpirationDate(month: String?, year: String?) throws {
        if let month, month.isEmpty {
            throw CoreMethodsError.expirationDateInvalid
        }

        if let year, year.isEmpty {
            throw CoreMethodsError.expirationDateInvalid
        }
    }

    private func validateCardData(
        cardNumber: String?,
        securityCode: String?,
        cardID: String?
    ) async throws {
        if let cardNumber, !cardNumber.isEmpty {
            let bin = CardNumber.getBin(cardNumber)
            let params = PaymentMethodsParams(
                bin: bin,
                processingMode: ProcessingMode.aggregator.rawValue
            )

            guard let paymentMethod = try await paymentMethodUseCase
                .getPaymentMethods(params: params)
                .first else {
                return
            }

            if let securityCode,
               paymentMethod.card?.securityCode.mode == "mandatory" {
                let requiredLength = paymentMethod.card?.securityCode.length ?? 3

                if securityCode.isEmpty || securityCode.count != requiredLength {
                    throw CoreMethodsError.securityCodeInvalid
                }
            }
        } else if cardID == nil {
            throw CoreMethodsError.cardNumberInvalid
        }
    }
}
