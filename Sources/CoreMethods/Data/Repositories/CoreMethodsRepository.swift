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

    init(
        dependencies: Dependency = CoreDependencyContainer.shared,
        installmentMapper: InstallmentsMapperProtocol = InstallmentsMapper()
    ) {
        self.dependencies = dependencies
        self.installmentMapper = installmentMapper
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
}
