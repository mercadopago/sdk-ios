//
//  RemotePaymentBrickRepository.swift
//  MercadoPagoSDK
//
//  Created by SDK on 22/06/26.
//

import CoreMethods
import Foundation
import MPCore

struct RemotePaymentBrickRepository: PaymentBrickRepository {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    func fetchInitialization(
        orderId: String,
        clientToken: String,
        screens: String? = nil
    ) async throws -> PaymentInitializationOutput {
        let response: PaymentBrickInitializationResponse = try await networkService.request(
            PaymentBrickInitializationEndpoint(
                orderId: orderId,
                clientToken: clientToken,
                screens: screens
            )
        )
        return self.map(response)
    }

    // MARK: - Mapping

    private func map(_ response: PaymentBrickInitializationResponse) -> PaymentInitializationOutput {
        let sections = response.sections.enumerated().map { index, section in
            PaymentInitializationOutput.Section(
                id: "section_\(index)",
                title: section.title,
                items: section.methods.map { self.map($0) }
            )
        }
        return PaymentInitializationOutput(
            headerTitle: response.headerTitle,
            sections: sections,
            footer: .init(totalLabel: response.footer.totalLabel, totalAmount: response.footer.totalAmount)
        )
    }

    private func mapSecurityCodeScreen(
        _ cardData: PaymentBrickInitializationResponse.CardData
    ) -> SecurityCodeScreenOutput? {
        guard let screen = cardData.securityCode.screen else { return nil }
        return SecurityCodeScreenOutput(
            length: cardData.securityCode.length,
            headerTitle: screen.header.title,
            field: SecurityCodeScreenOutput.Field(
                label: screen.field.label,
                placeholder: screen.field.placeholder,
                helper: screen.field.helper,
                error: screen.field.error
            ),
            buttonLabel: screen.button.label
        )
    }

    private func mapInstallments(
        _ cardData: PaymentBrickInitializationResponse.CardData
    ) -> InstallmentScreenData? {
        guard let installments = cardData.installments else { return nil }
        return InstallmentScreenData(
            selectionType: installments.selectionType,
            quotas: installments.quotas.map {
                InstallmentScreenData.Quota(
                    installments: $0.installments,
                    installmentAmount: $0.installmentAmount,
                    totalAmount: $0.totalAmount,
                    primaryLabel: $0.primaryLabel,
                    secondaryLabel: $0.secondaryLabel,
                    state: .init($0.state),
                    tertiaryLabel: $0.tertiaryLabel,
                    accessibilityLabel: $0.accessibilityLabel
                )
            },
            translations: InstallmentScreenData.Translations(
                headerTitle: installments.header.title,
                totalLabel: installments.footer.totalLabel,
                payButtonLabel: installments.footer.button.label,
                currencySymbol: installments.footer.currencySymbol
            )
        )
    }

    private func mapMethodSelectionScreen(
        _ screen: PaymentBrickInitializationResponse.MethodSelectionScreen?
    ) -> MethodSelectionOutput? {
        guard let screen else { return nil }
        return MethodSelectionOutput(
            headerTitle: screen.headerTitle,
            selectionType: .init(screen.selectionType),
            footer: MethodSelectionOutput.Footer(
                totalLabel: screen.footer.totalLabel,
                totalAmount: screen.footer.totalAmount,
                button: screen.footer.button.map { MethodSelectionOutput.Footer.Button(label: $0.label) }
            ),
            options: screen.options.map {
                MethodSelectionOutput.Option(id: $0.id, name: $0.name, subtitle: $0.subtitle, iconUrl: $0.iconUrl)
            }
        )
    }

    private func map(_ method: PaymentBrickInitializationResponse.PaymentMethod) -> PaymentInitializationOutput.Item {
        let identifier: String = {
            if method.type == "saved_card" {
                return method.cardData?.id ?? method.type
            }
            return method.type
        }()

        return PaymentInitializationOutput.Item(
            id: identifier,
            title: method.title,
            description: method.subtitle,
            icon: .remote(URL(string: method.iconUrl)),
            route: method.type,
            cardData: method.cardData.map { data in
                .init(
                    paymentMethodId: data.paymentMethodId,
                    paymentTypeId: data.paymentTypeId,
                    issuerId: data.issuerId,
                    securityCodeScreen: self.mapSecurityCodeScreen(data),
                    bin: data.bin,
                    lastFourDigits: data.lastFourDigits,
                    installments: self.mapInstallments(data)
                )
            },
            screen: self.mapMethodSelectionScreen(method.screen)
        )
    }
}
