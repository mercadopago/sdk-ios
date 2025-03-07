//
//  CoreMethodsRepository.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 18/02/25.
//

import Foundation
import MPCore

package final class CoreMethodsRepository: CoreMethodsRepositoryProtocol {
    typealias Dependency = HasNetwork
    private typealias Endpoint = CoreMethodsEndpoint

    let dependencies: Dependency

    private let installmentMapper: InstallmentsMapperProtocol

    private let paymentMethodMapper: PaymentMethodMapperProtocol

    init(
        dependencies: Dependency = CoreDependencyContainer.shared,
        installmentMapper: InstallmentsMapperProtocol = InstallmentsMapper(),
        paymentMethodMapper: PaymentMethodMapperProtocol = PaymentMethodMapper()
    ) {
        self.dependencies = dependencies
        self.installmentMapper = installmentMapper
        self.paymentMethodMapper = paymentMethodMapper
    }

    func generateCardToken(_ data: CardTokenBody) async throws -> CardTokenResponse {
        return try await self.dependencies.networkService.request(
            Endpoint.postCardToken(body: data)
        )
    }

    func getIdentificationTypes() async throws -> [IdentificationTypesResponse] {
        return try await self.dependencies.networkService.request(
            Endpoint.getIdentificationTypes
        )
    }

    func getInstallments(params: InstallmentsParams) async throws -> [Installment] {
        let response: [InstallmentsResponse] = try await self.dependencies.networkService.request(
            Endpoint.getInstallments(params: params)
        )

        return self.installmentMapper.map(responses: response)
    }

    func getPaymentMethods(params: PaymentMethodsParams) async throws -> [PaymentMethod] {
        let response: [PaymentMethodResponse] = try await self.dependencies.networkService.request(
            Endpoint.getPaymentMethods(params: params)
        )

        return self.paymentMethodMapper.map(responses: response)
    }
}
