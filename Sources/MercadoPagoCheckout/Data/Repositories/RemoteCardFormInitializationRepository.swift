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
        let response: CardFormInitializationResponse = try await networkService.request(
            CardFormInitializationEndpoint.getInitialization
        )
        return self.map(response)
    }

    // MARK: - Mapping

    private func map(_ response: CardFormInitializationResponse) -> CardFormInitializationInput {
        let translations = response.translations
        return CardFormInitializationInput(
            title: translations.cardFormTitle,
            buttonVariants: .init(save: translations.payButtonLabel, pay: translations.payButtonLabel),
            fields: .init(
                cardNumber: .init(
                    label: translations.cardNumberLabel,
                    placeholder: translations.cardNumberPlaceholder,
                    validation: .init(
                        errorEmpty: MPStrings.CardForm.CardNumber.errorEmpty,
                        errorIncomplete: MPStrings.CardForm.CardNumber.errorIncomplete,
                        errorInvalid: MPStrings.CardForm.CardNumber.errorInvalid,
                        errorMethodNotAllowed: MPStrings.CardForm.CardNumber.errorMethodNotAllowed(brand: "%@"),
                        errorTypeNotAllowed: MPStrings.CardForm.CardNumber.errorTypeNotAllowed(cardType: "%@")
                    )
                ),
                cardHolder: .init(
                    label: translations.cardholderNameLabel,
                    placeholder: translations.cardholderNamePlaceholder,
                    helperText: translations.cardholderNameHelper,
                    validation: .init(
                        errorEmpty: MPStrings.CardForm.CardHolder.errorEmpty,
                        errorIncomplete: MPStrings.CardForm.CardHolder.errorIncomplete,
                        errorInvalid: MPStrings.CardForm.CardHolder.errorInvalid
                    )
                ),
                expiration: .init(
                    label: translations.expirationDateLabel,
                    placeholder: translations.expirationDatePlaceholder,
                    validation: .init(
                        errorEmpty: MPStrings.CardForm.Expiration.errorEmpty,
                        errorIncomplete: MPStrings.CardForm.Expiration.errorIncomplete,
                        errorInvalid: MPStrings.CardForm.Expiration.errorInvalid
                    )
                ),
                cvv: .init(
                    label: translations.securityCodeLabel,
                    placeholderDefault: translations.securityCodePlaceholder,
                    placeholderAmex: translations.securityCodePlaceholder,
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
                    label: translations.documentLabel,
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
