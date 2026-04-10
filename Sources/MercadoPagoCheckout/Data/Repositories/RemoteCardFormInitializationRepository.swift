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
        let t = response.translations
        return CardFormInitializationInput(
            title: t.cardFormTitle,
            buttonVariants: .init(save: t.installments.payButtonLabel, pay: t.installments.payButtonLabel),
            fields: .init(
                cardNumber: .init(
                    label: t.cardNumber.label,
                    placeholder: t.cardNumber.placeholder,
                    validation: .init(
                        errorEmpty: t.cardNumber.errorEmptyField,
                        errorIncomplete: t.cardNumber.errorIncompleteField,
                        errorInvalid: t.cardNumber.errorInvalidField,
                        errorMethodNotAllowed: MPStrings.CardForm.CardNumber.errorMethodNotAllowed(brand: "%@"),
                        errorTypeNotAllowed: MPStrings.CardForm.CardNumber.errorTypeNotAllowed(cardType: "%@")
                    ),
                    config: .init(
                        type: response.cardNumber.type,
                        length: .init(min: response.cardNumber.length.min, max: response.cardNumber.length.max)
                    )
                ),
                cardHolder: .init(
                    label: t.holderName.label,
                    placeholder: t.holderName.placeholder,
                    helperText: t.holderName.helper,
                    validation: .init(
                        errorEmpty: t.holderName.errorEmptyField,
                        errorIncomplete: t.holderName.errorIncompleteField,
                        errorInvalid: t.holderName.errorInvalidField
                    ),
                    config: .init(
                        type: response.holderName.type,
                        length: .init(min: response.holderName.length.min, max: response.holderName.length.max)
                    )
                ),
                expiration: .init(
                    label: t.expirationDate.label,
                    placeholder: t.expirationDate.placeholder,
                    validation: .init(
                        errorEmpty: t.expirationDate.errorEmptyField,
                        errorIncomplete: t.expirationDate.errorIncompleteField,
                        errorInvalid: t.expirationDate.errorInvalidField
                    ),
                    config: .init(
                        type: response.expirationDate.type,
                        length: .init(min: response.expirationDate.length.min, max: response.expirationDate.length.max)
                    )
                ),
                cvv: .init(
                    label: t.securityCode.label,
                    placeholderDefault: t.securityCode.placeholder,
                    placeholderAmex: t.securityCode.placeholder,
                    validation: .init(
                        errorEmpty: t.securityCode.errorEmptyField,
                        errorIncomplete: t.securityCode.errorIncompleteField
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
                    label: t.document.label,
                    placeholder: MPStrings.CardForm.Document.placeholder,
                    validation: .init(
                        errorEmpty: t.document.errorEmptyField,
                        errorIncomplete: t.document.errorIncompleteField,
                        errorInvalid: t.document.errorInvalidField
                    )
                )
            ),
            identificationTypes: response.identificationTypes.map { dto in
                IdentificationType(
                    id: dto.id,
                    name: dto.name,
                    type: dto.type,
                    minLenght: dto.minLength,
                    maxLenght: dto.maxLength,
                    placeholder: dto.placeholder,
                    mask: dto.mask
                )
            }
        )
    }
}
