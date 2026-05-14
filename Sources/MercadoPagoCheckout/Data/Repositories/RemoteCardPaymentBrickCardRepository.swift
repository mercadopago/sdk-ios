//
//  RemoteCardPaymentBrickCardRepository.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 13/04/26.
//

import MPCore
import MPFoundation

struct RemoteCardPaymentBrickCardRepository: CardPaymentBrickCardRepository {
    typealias Dependency = HasNetwork

    private let dependencies: Dependency

    init(dependencies: Dependency = CoreDependencyContainer.shared) {
        self.dependencies = dependencies
    }

    func fetchCard(params: CardPaymentBrickCardParams) async throws -> CardPaymentBrickCardData {
        let response: CardPaymentBrickCardResponse = try await dependencies.networkService.request(
            CardPaymentBrickEndpoint.getCard(params: params)
        )
        return self.map(response: response, params: params)
    }

    // MARK: - Mapping

    private func map(response: CardPaymentBrickCardResponse, params _: CardPaymentBrickCardParams) -> CardPaymentBrickCardData {
        CardPaymentBrickCardData(
            securityCodeTranslations: response.translations.securityCode.map {
                self.mapSecurityCodeTranslations($0, response)
            },
            installment: response.installment.map {
                self.mapInstallment(
                    $0,
                    translations: response.translations.installments,
                    currencySymbol: response.translations.currencySymbol
                )
            },
            paymentMethods: response.paymentMethods.map { self.mapPaymentMethod($0) }
        )
    }

    private func mapSecurityCodeTranslations(
        _ data: CardFormTranslationsResponse.FieldTranslationsData,
        _ response: CardPaymentBrickCardResponse
    ) -> CardFormFields.CVVField {
        let securityCode = response.paymentMethods.map { self.mapPaymentMethod($0) }
        return CardFormFields.CVVField(
            label: data.label,
            placeholder: data.placeholder,
            tooltip: data.tooltip,
            validation: .init(
                errorEmpty: data.errorEmptyField,
                errorIncomplete: data.errorIncompleteField,
                errorInvalid: data.errorInvalidField
            ),
            config: .init(
                type: securityCode.first?.securityCode?.type ?? String(),
                length: .init(
                    min: securityCode.first?.securityCode?.length ?? 0,
                    max: securityCode.first?.securityCode?.length ?? 0
                )
            )
        )
    }

    private func mapInstallment(
        _ data: CardPaymentBrickCardResponse.InstallmentData,
        translations: CardFormTranslationsResponse.InstallmentsTranslationsData,
        currencySymbol: String
    ) -> CardPaymentBrickCardData.Installment {
        return CardPaymentBrickCardData.Installment(
            selectionType: data.selectionType,
            quotas: data.quotas.map {
                CardPaymentBrickCardData.Installment.Quota(
                    installments: $0.installments,
                    installmentAmount: $0.installmentAmount,
                    totalAmount: $0.totalAmount,
                    primaryLabel: $0.primaryLabel,
                    secondaryLabel: $0.secondaryLabel,
                    state: .init($0.state),
                    tertiaryLabel: $0.tertiaryLabel
                )
            },
            translations: CardPaymentBrickCardData.Installment.InstallmentTranslations(
                headerTitle: translations.header.title,
                totalLabel: translations.totalLabel,
                payButtonLabel: translations.payButtonLabel,
                currencySymbol: currencySymbol
            )
        )
    }

    private func mapPaymentMethod(
        _ data: CardPaymentBrickCardResponse.PaymentMethodData
    ) -> CardPaymentBrickCardData.PaymentMethod {
        CardPaymentBrickCardData.PaymentMethod(
            id: data.id,
            paymentTypeId: data.paymentTypeId,
            cardNumber: CardPaymentBrickCardData.PaymentMethod.CardNumberInfo(
                type: data.cardNumber.type,
                length: CardPaymentBrickCardData.PaymentMethod.CardNumberInfo.Length(
                    min: data.cardNumber.length.min,
                    max: data.cardNumber.length.max
                ),
                mask: data.cardNumber.mask
            ),
            securityCode: data.securityCode.map {
                CardPaymentBrickCardData.PaymentMethod.SecurityCodeInfo(
                    mode: $0.mode,
                    length: $0.length,
                    type: $0.type,
                    placeholder: $0.placeholder,
                    tooltip: $0.tooltip
                )
            },
            issuers: data.issuers.map {
                CardPaymentBrickCardData.PaymentMethod.Issuer(id: $0.id, name: $0.name)
            }
        )
    }
}
