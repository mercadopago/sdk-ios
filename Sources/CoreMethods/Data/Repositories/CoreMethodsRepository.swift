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

    init(dependencies: Dependency = CoreDependencyContainer.shared) {
        self.dependencies = dependencies
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
}
