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
        clientToken: String
    ) async throws -> PaymentInitializationOutput {
        let response: PaymentBrickInitializationResponse = try await networkService.request(
            PaymentBrickInitializationEndpoint(
                orderId: orderId,
                clientToken: clientToken
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
            headerTitle: screen.headerTitle,
            field: SecurityCodeScreenOutput.Field(
                label: screen.field.label,
                placeholder: screen.field.placeholder,
                helper: screen.field.helper,
                error: screen.field.error
            ),
            buttonLabel: screen.continueButtonLabel
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
                    securityCodeScreen: self.mapSecurityCodeScreen(data)
                )
            }
        )
    }
}
