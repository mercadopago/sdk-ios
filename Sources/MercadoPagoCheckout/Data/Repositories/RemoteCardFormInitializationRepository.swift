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

    func fetchInitialization(amount: Double?, checkoutType: String) async throws -> CardFormInitializationInput {
        let response: CardFormInitializationResponse = try await networkService.request(
            CardFormInitializationEndpoint(amount: amount, checkoutType: checkoutType)
        )
        return self.map(response)
    }

    // MARK: - Mapping

    private func map(_ response: CardFormInitializationResponse) -> CardFormInitializationInput {
        let translations = response.translations
        return CardFormInitializationInput(
            title: translations.cardFormTitle,
            buttonLabel: translations.cardFormFooterButtonLabel,
            fields: .init(
                cardNumber: .init(
                    label: translations.cardNumber.label,
                    placeholder: translations.cardNumber.placeholder,
                    validation: .init(
                        errorEmpty: translations.cardNumber.errorEmptyField,
                        errorIncomplete: translations.cardNumber.errorIncompleteField,
                        errorInvalid: translations.cardNumber.errorInvalidField,
                        errorMethodNotAllowed: MPStrings.CardForm.CardNumber.errorMethodNotAllowed(brand: "%@"),
                        errorTypeNotAllowed: MPStrings.CardForm.CardNumber.errorTypeNotAllowed(cardType: "%@")
                    ),
                    config: .init(
                        type: response.cardNumber.type,
                        length: .init(min: response.cardNumber.length.min, max: response.cardNumber.length.max)
                    )
                ),
                cardHolder: .init(
                    label: translations.holderName.label,
                    placeholder: translations.holderName.placeholder,
                    helperText: translations.holderName.helper,
                    validation: .init(
                        errorEmpty: translations.holderName.errorEmptyField,
                        errorIncomplete: translations.holderName.errorIncompleteField,
                        errorInvalid: translations.holderName.errorInvalidField
                    ),
                    config: .init(
                        type: response.holderName.type,
                        length: .init(min: response.holderName.length.min, max: response.holderName.length.max)
                    )
                ),
                expiration: .init(
                    label: translations.expirationDate.label,
                    placeholder: translations.expirationDate.placeholder,
                    validation: .init(
                        errorEmpty: translations.expirationDate.errorEmptyField,
                        errorIncomplete: translations.expirationDate.errorIncompleteField,
                        errorInvalid: translations.expirationDate.errorInvalidField
                    ),
                    config: .init(
                        type: response.expirationDate.type,
                        length: .init(min: response.expirationDate.length.min, max: response.expirationDate.length.max)
                    )
                ),
                cvv: .init(
                    label: translations.securityCode.label,
                    placeholder: translations.securityCode.placeholder,
                    tooltip: translations.securityCode.tooltip,
                    validation: .init(
                        errorEmpty: translations.securityCode.errorEmptyField,
                        errorIncomplete: translations.securityCode.errorIncompleteField
                    ),
                    config: .init(
                        type: response.securityCode.type,
                        length: .init(min: response.securityCode.length, max: response.securityCode.length)
                    )
                ),
                issuer: .init(
                    label: MPStrings.CardForm.Issuer.label,
                    placeholder: MPStrings.CardForm.Issuer.placeholder
                ),
                document: .init(
                    label: translations.document.label,
                    placeholder: MPStrings.CardForm.Document.placeholder,
                    validation: .init(
                        errorEmpty: translations.document.errorEmptyField,
                        errorIncomplete: translations.document.errorIncompleteField,
                        errorInvalid: translations.document.errorInvalidField
                    )
                )
            ),
            identificationTypes: response.identificationTypes.map { dto in
                IdentificationType(
                    id: dto.id,
                    name: dto.name,
                    type: dto.type ?? "",
                    minLength: dto.minLength,
                    maxLength: dto.maxLength,
                    placeholder: dto.placeholder ?? "",
                    mask: dto.mask ?? "",
                    sequence: dto.sequence
                )
            }
        )
    }
}
