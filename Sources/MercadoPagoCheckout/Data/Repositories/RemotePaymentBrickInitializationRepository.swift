//
//  RemotePaymentBrickInitializationRepository.swift
//  MercadoPagoSDK
//
//  Created by SDK on 22/06/26.
//

import CoreMethods
import Foundation
import MPCore

struct RemotePaymentBrickInitializationRepository: PaymentBrickInitializationRepository {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    func fetchInitialization(
        orderId: String,
        totalAmount: Decimal,
        customerId: String?,
        cardIds: [String]
    ) async throws -> PaymentInitializationOutput {
        let response: PaymentBrickInitializationResponse = try await networkService.request(
            PaymentBrickInitializationEndpoint(
                orderId: orderId,
                totalAmount: totalAmount,
                customerId: customerId,
                cardIds: cardIds
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
            // footer.totalAmount is intentionally omitted — the displayed amount is
            // sourced client-side from the Order via MPAmountData(from: order.amount).
            footer: .init(totalLabel: response.footer.totalLabel)
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
            route: method.type
        )
    }
}
