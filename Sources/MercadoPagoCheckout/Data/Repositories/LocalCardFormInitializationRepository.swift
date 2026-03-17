//
//  LocalCardFormInitializationRepository.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 16/03/26.
//

import CoreMethods
import MPFoundation

/// Returns initialization data from local MPStrings and identification types from the service.
struct LocalCardFormInitializationRepository: CardFormInitializationRepository {
    private let service: CheckoutServiceProtocol

    init(service: CheckoutServiceProtocol = CheckoutService()) {
        self.service = service
    }

    func fetchInitialization() async throws -> CardFormInitializationInput {
        let identificationTypes = try await service.identificationTypes()

        return CardFormInitializationInput(
            title: MPStrings.CardForm.title,
            buttonVariants: .init(
                save: MPStrings.CardForm.button,
                pay: ""
            ),
            fields: .init(
                cardNumber: .init(
                    label: MPStrings.CardForm.CardNumber.label,
                    placeholder: MPStrings.CardForm.CardNumber.placeholder,
                    validation: .init(
                        errorEmpty: MPStrings.CardForm.CardNumber.errorEmpty,
                        errorIncomplete: MPStrings.CardForm.CardNumber.errorIncomplete,
                        errorInvalid: MPStrings.CardForm.CardNumber.errorInvalid,
                        errorSellerExclusion: MPStrings.CardForm.CardNumber.errorSellerExclusion(brand: "%@"),
                        errorTypeNotAllowed: MPStrings.CardForm.CardNumber.errorTypeNotAllowed(cardType: "%@")
                    )
                ),
                cardHolder: .init(
                    label: MPStrings.CardForm.CardHolder.label,
                    placeholder: MPStrings.CardForm.CardHolder.placeholder,
                    helperText: MPStrings.CardForm.CardHolder.helperText,
                    validation: .init(
                        errorEmpty: MPStrings.CardForm.CardHolder.errorEmpty,
                        errorIncomplete: MPStrings.CardForm.CardHolder.errorIncomplete,
                        errorInvalidFormat: MPStrings.CardForm.CardHolder.errorInvalidFormat
                    )
                ),
                expiration: .init(
                    label: MPStrings.CardForm.Expiration.label,
                    placeholder: MPStrings.CardForm.Expiration.placeholder,
                    validation: .init(
                        errorEmpty: MPStrings.CardForm.Expiration.errorEmpty,
                        errorIncomplete: MPStrings.CardForm.Expiration.errorIncomplete,
                        errorInvalid: MPStrings.CardForm.Expiration.errorInvalid
                    )
                ),
                cvv: .init(
                    label: MPStrings.CardForm.CVV.label,
                    placeholderDefault: MPStrings.CardForm.CVV.placeholderDefault,
                    placeholderAmex: MPStrings.CardForm.CVV.placeholderAmex,
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
                    label: MPStrings.CardForm.Document.label,
                    placeholder: MPStrings.CardForm.Document.placeholder,
                    validation: .init(
                        errorEmpty: MPStrings.CardForm.Document.errorEmpty,
                        errorIncomplete: MPStrings.CardForm.Document.errorIncomplete,
                        errorInvalid: MPStrings.CardForm.Document.errorInvalid
                    )
                )
            ),
            identificationTypes: identificationTypes
        )
    }
}
