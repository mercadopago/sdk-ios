//
//  InitializeCardFormUseCase.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 16/03/26.
//

import CoreMethods

/// Orchestrates fetching all initialization data for the CardForm screen.
/// Applies business rules: resolves button variant and custom texts over defaults.
struct InitializeCardFormUseCase: Sendable {
    private let repository: CardFormInitializationRepository

    init(repository: CardFormInitializationRepository = LocalCardFormInitializationRepository()) {
        self.repository = repository
    }

    /// Fetches initialization data from the repository,
    /// then applies business rules (button selection, custom text overrides).
    func execute(config: MercadoPagoCheckout.CardFormConfiguration) async throws -> CardFormInitializationOutput {
        let data = try await repository.fetchInitialization()
        return self.mapToResult(data: data, config: config)
    }

    // MARK: - Business Rules

    private func mapToResult(
        data: CardFormInitializationInput,
        config _: MercadoPagoCheckout.CardFormConfiguration
    ) -> CardFormInitializationOutput {
        let custom: CardFormCustomTexts? = nil
        let fields = data.fields

        return CardFormInitializationOutput(
            title: custom?.title ?? data.title,
            button: custom?.button ?? data.buttonVariants.save,
            fields: .init(
                cardNumber: .init(
                    label: custom?.cardNumber?.label ?? fields.cardNumber.label,
                    placeholder: custom?.cardNumber?.placeholder ?? fields.cardNumber.placeholder,
                    validation: .init(
                        errorEmpty: fields.cardNumber.validation.errorEmpty,
                        errorIncomplete: fields.cardNumber.validation.errorIncomplete,
                        errorInvalid: fields.cardNumber.validation.errorInvalid,
                        errorSellerExclusion: fields.cardNumber.validation.errorSellerExclusion,
                        errorTypeNotAllowed: fields.cardNumber.validation.errorTypeNotAllowed
                    )
                ),
                cardHolder: .init(
                    label: custom?.cardHolder?.label ?? fields.cardHolder.label,
                    placeholder: custom?.cardHolder?.placeholder ?? fields.cardHolder.placeholder,
                    helperText: fields.cardHolder.helperText,
                    validation: .init(
                        errorEmpty: fields.cardHolder.validation.errorEmpty,
                        errorIncomplete: fields.cardHolder.validation.errorIncomplete,
                        errorInvalidFormat: fields.cardHolder.validation.errorInvalidFormat
                    )
                ),
                expiration: .init(
                    label: custom?.expiration?.label ?? fields.expiration.label,
                    placeholder: custom?.expiration?.placeholder ?? fields.expiration.placeholder,
                    validation: .init(
                        errorEmpty: fields.expiration.validation.errorEmpty,
                        errorIncomplete: fields.expiration.validation.errorIncomplete,
                        errorInvalid: fields.expiration.validation.errorInvalid
                    )
                ),
                cvv: .init(
                    label: custom?.cvv?.label ?? fields.cvv.label,
                    placeholderDefault: custom?.cvv?.placeholder ?? fields.cvv.placeholderDefault,
                    placeholderAmex: custom?.cvv?.placeholder ?? fields.cvv.placeholderAmex,
                    validation: .init(
                        errorEmpty: fields.cvv.validation.errorEmpty,
                        errorIncomplete: fields.cvv.validation.errorIncomplete
                    )
                ),
                issuer: .init(
                    label: custom?.issuer?.label ?? fields.issuer.label,
                    placeholder: custom?.issuer?.placeholder ?? fields.issuer.placeholder
                ),
                document: .init(
                    label: custom?.document?.label ?? fields.document.label,
                    placeholder: custom?.document?.placeholder ?? fields.document.placeholder,
                    validation: .init(
                        errorEmpty: fields.document.validation.errorEmpty,
                        errorIncomplete: fields.document.validation.errorIncomplete,
                        errorInvalid: fields.document.validation.errorInvalid
                    )
                )
            ),
            identificationTypes: data.identificationTypes
        )
    }
}
