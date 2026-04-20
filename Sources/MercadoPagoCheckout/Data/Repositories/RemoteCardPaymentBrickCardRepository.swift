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
        return self.map(response: response)
    }

    // MARK: - Mapping

    private func map(response: CardPaymentBrickCardResponse) -> CardPaymentBrickCardData {
        CardPaymentBrickCardData(
            securityCodeTranslations: response.translations.securityCode.map { self.mapSecurityCodeTranslations($0) },
            installment: response.installment.map { self.mapInstallment($0) },
            paymentMethods: response.paymentMethods.map { self.mapPaymentMethod($0) }
        )
    }

    private func mapSecurityCodeTranslations(
        _ data: CardFormTranslationsResponse.FieldTranslationsData
    ) -> CardPaymentBrickCardData.SecurityCodeTranslations {
        CardPaymentBrickCardData.SecurityCodeTranslations(
            label: data.label,
            placeholder: data.placeholder,
            helper: data.helper,
            tooltip: data.tooltip,
            errorEmpty: data.errorEmptyField,
            errorIncomplete: data.errorIncompleteField,
            errorInvalid: data.errorInvalidField
        )
    }

    private func mapInstallment(
        _ data: CardPaymentBrickCardResponse.InstallmentData
    ) -> CardPaymentBrickCardData.Installment {
        CardPaymentBrickCardData.Installment(
            selectionType: data.selectionType,
            quotas: data.quotas.map {
                CardPaymentBrickCardData.Installment.Quota(
                    installments: $0.installments,
                    installmentAmount: $0.installmentAmount
                )
            }
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
