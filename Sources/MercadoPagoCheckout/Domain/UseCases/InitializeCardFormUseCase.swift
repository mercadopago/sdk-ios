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

    init(repository: CardFormInitializationRepository = RemoteCardFormInitializationRepository()) {
        self.repository = repository
    }

    /// Fetches initialization data from the repository,
    /// then applies business rules (button selection, custom text overrides).
    func execute(
        amount: Double,
        checkoutType: MercadoPagoCheckout<some MPPaymentData.Kind>.CheckoutType
    ) async throws(MercadoPagoCheckoutError) -> CardFormInitializationOutput {
        do {
            let data = try await repository.fetchInitialization(
                amount: amount,
                checkoutType: checkoutType.analyticsValue
            )

            return self.mapToResult(data: data)
        } catch let error as APIClientError {
            if case let .apiError(response) = error,
               let errorCode = response.errorCode,
               CheckoutAPIErrorCode.isIntegrationError(errorCode) {
                throw MercadoPagoCheckoutError(
                    code: .integrationError,
                    localizedDescription: response.message,
                    userInfo: ["error_code": errorCode, "message": response.message],
                    location: .initialization
                )
            }
            throw .init(from: error, location: .initialization)
        } catch {
            throw .init(code: .unknown, localizedDescription: error.localizedDescription, location: .identification)
        }
    }

    // MARK: - Business Rules

    private func mapToResult(
        data: CardFormInitializationInput
    ) -> CardFormInitializationOutput {
        let fields = data.fields

        return CardFormInitializationOutput(
            title: data.title,
            button: data.buttonLabel,
            fields: .init(
                cardNumber: .init(
                    label: fields.cardNumber.label,
                    placeholder: fields.cardNumber.placeholder,
                    validation: .init(
                        errorEmpty: fields.cardNumber.validation.errorEmpty,
                        errorIncomplete: fields.cardNumber.validation.errorIncomplete,
                        errorInvalid: fields.cardNumber.validation.errorInvalid
                    ),
                    config: fields.cardNumber.config
                ),
                cardHolder: .init(
                    label: fields.cardHolder.label,
                    placeholder: fields.cardHolder.placeholder,
                    helperText: fields.cardHolder.helperText,
                    validation: .init(
                        errorEmpty: fields.cardHolder.validation.errorEmpty,
                        errorIncomplete: fields.cardHolder.validation.errorIncomplete,
                        errorInvalid: fields.cardHolder.validation.errorInvalid
                    ),
                    config: fields.cardHolder.config
                ),
                expiration: .init(
                    label: fields.expiration.label,
                    placeholder: fields.expiration.placeholder,
                    validation: .init(
                        errorEmpty: fields.expiration.validation.errorEmpty,
                        errorIncomplete: fields.expiration.validation.errorIncomplete,
                        errorInvalid: fields.expiration.validation.errorInvalid
                    ),
                    config: fields.expiration.config
                ),
                cvv: .init(
                    label: fields.cvv.label,
                    placeholder: fields.cvv.placeholder,
                    tooltip: fields.cvv.tooltip,
                    validation: .init(
                        errorEmpty: fields.cvv.validation.errorEmpty,
                        errorIncomplete: fields.cvv.validation.errorIncomplete,
                        errorInvalid: fields.cvv.validation.errorInvalid
                    ),
                    config: fields.cvv.config
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
