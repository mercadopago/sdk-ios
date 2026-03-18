//
//  RemoteCardFormInitializationRepository.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 18/03/26.
//

import CoreMethods
import MPCore
import MPFoundation

struct RemoteCardFormInitializationRepository: CardFormInitializationRepository {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    func fetchInitialization() async throws -> CardFormInitializationInput {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response: CardFormInitializationResponse = try await networkService.request(
            CardFormInitializationEndpoint.getInitialization,
            decoder: decoder
        )
        return self.map(response)
    }

    // MARK: - Mapping

    private func map(_ response: CardFormInitializationResponse) -> CardFormInitializationInput {
        let t = response.translations
        return CardFormInitializationInput(
            title: t.cardFormTitle,
            buttonVariants: .init(save: t.payButtonLabel, pay: t.payButtonLabel),
            fields: .init(
                cardNumber: .init(
                    label: t.cardNumberLabel,
                    placeholder: t.cardNumberPlaceholder,
                    validation: .init(
                        errorEmpty: MPStrings.CardForm.CardNumber.errorEmpty,
                        errorIncomplete: MPStrings.CardForm.CardNumber.errorIncomplete,
                        errorInvalid: MPStrings.CardForm.CardNumber.errorInvalid,
                        errorMethodNotAllowed: MPStrings.CardForm.CardNumber.errorMethodNotAllowed(brand: "%@"),
                        errorTypeNotAllowed: MPStrings.CardForm.CardNumber.errorTypeNotAllowed(cardType: "%@")
                    )
                ),
                cardHolder: .init(
                    label: t.cardholderNameLabel,
                    placeholder: t.cardholderNamePlaceholder,
                    helperText: t.cardholderNameHelper,
                    validation: .init(
                        errorEmpty: MPStrings.CardForm.CardHolder.errorEmpty,
                        errorIncomplete: MPStrings.CardForm.CardHolder.errorIncomplete,
                        errorInvalid: MPStrings.CardForm.CardHolder.errorInvalid
                    )
                ),
                expiration: .init(
                    label: t.expirationDateLabel,
                    placeholder: t.expirationDatePlaceholder,
                    validation: .init(
                        errorEmpty: MPStrings.CardForm.Expiration.errorEmpty,
                        errorIncomplete: MPStrings.CardForm.Expiration.errorIncomplete,
                        errorInvalid: MPStrings.CardForm.Expiration.errorInvalid
                    )
                ),
                cvv: .init(
                    label: t.securityCodeLabel,
                    placeholderDefault: t.securityCodePlaceholder,
                    placeholderAmex: t.securityCodePlaceholder,
                    validation: .init(
                        errorEmpty: MPStrings.CardForm.CVV.errorEmpty,
                        errorIncomplete: MPStrings.CardForm.CVV.errorIncomplete
                    )
                ),
                issuer: .init(
                    label: MPStrings.CardForm.Issuer.label,
                    placeholder: MPStrings.CardForm.Issuer.placeholder
                ),
                document: .init(
                    label: t.documentLabel,
                    placeholder: MPStrings.CardForm.Document.placeholder,
                    validation: .init(
                        errorEmpty: MPStrings.CardForm.Document.errorEmpty,
                        errorIncomplete: MPStrings.CardForm.Document.errorIncomplete,
                        errorInvalid: MPStrings.CardForm.Document.errorInvalid
                    )
                )
            ),
            identificationTypes: response.identificationTypes
        )
    }
}
