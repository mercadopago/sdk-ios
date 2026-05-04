//
//  InitializeCardFormUseCase.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 16/03/26.
//

import CoreMethods

/// Orchestrates fetching all initialization data for the CardForm screen.
/// Applies business rules: resolves button variant and custom texts over defaults.
struct InitializeCardFormUseCase {
    private let repository: CardFormInitializationRepository

    init(repository: CardFormInitializationRepository = LocalCardFormInitializationRepository()) {
        self.repository = repository
    }

    /// Fetches initialization data from the repository,
    /// then applies business rules (button selection, custom text overrides).
    func execute(config: MercadoPagoCheckout.CardFormConfiguration) async throws(MercadoPagoCheckoutError) -> CardFormInitializationOutput {
        do {
            let data = try await repository.fetchInitialization()
            return self.mapToResult(data: data, config: config)
        } catch let error as APIClientError {
            throw .init(from: error, location: .initialization)
        } catch {
            throw .init(code: .unknown, localizedDescription: error.localizedDescription, location: .identification)
        }
    }

    // MARK: - Business Rules

    private func mapToResult(
        data: CardFormInitializationInput,
        config _: MercadoPagoCheckout.CardFormConfiguration
    ) -> CardFormInitializationOutput {
        let fields = data.fields

        return CardFormInitializationOutput(
            title: data.title,
            button: data.buttonVariants.save,
            fields: .init(
                cardNumber: .init(
                    label: fields.cardNumber.label,
                    placeholder: fields.cardNumber.placeholder,
                    validation: .init(
                        errorEmpty: fields.cardNumber.validation.errorEmpty,
                        errorIncomplete: fields.cardNumber.validation.errorIncomplete,
                        errorInvalid: fields.cardNumber.validation.errorInvalid,
                        errorMethodNotAllowed: fields.cardNumber.validation.errorMethodNotAllowed,
                        errorTypeNotAllowed: fields.cardNumber.validation.errorTypeNotAllowed
                    )
                ),
                cardHolder: .init(
                    label: fields.cardHolder.label,
                    placeholder: fields.cardHolder.placeholder,
                    helperText: fields.cardHolder.helperText,
                    validation: .init(
                        errorEmpty: fields.cardHolder.validation.errorEmpty,
                        errorIncomplete: fields.cardHolder.validation.errorIncomplete,
                        errorInvalid: fields.cardHolder.validation.errorInvalid
                    )
                ),
                expiration: .init(
                    label: fields.expiration.label,
                    placeholder: fields.expiration.placeholder,
                    validation: .init(
                        errorEmpty: fields.expiration.validation.errorEmpty,
                        errorIncomplete: fields.expiration.validation.errorIncomplete,
                        errorInvalid: fields.expiration.validation.errorInvalid
                    )
                ),
                cvv: .init(
                    label: fields.cvv.label,
                    placeholderDefault: fields.cvv.placeholderDefault,
                    placeholderAmex: fields.cvv.placeholderAmex,
                    validation: .init(
                        errorEmpty: fields.cvv.validation.errorEmpty,
                        errorIncomplete: fields.cvv.validation.errorIncomplete
                    )
                ),
                issuer: .init(
                    label: fields.issuer.label,
                    placeholder: fields.issuer.placeholder
                ),
                document: .init(
                    label: fields.document.label,
                    placeholder: fields.document.placeholder,
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
