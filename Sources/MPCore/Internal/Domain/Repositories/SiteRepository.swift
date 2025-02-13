//
//  SiteRepository.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 12/02/25.
//

final class SiteRepository: SiteRepositoryProtocol {
    typealias Dependency = HasNetwork

    let dependencies: Dependency

    init(dependencies: Dependency) {
        self.dependencies = dependencies
    }

    func getID() async throws -> SiteResponse {
        return try await self.dependencies.networkService.request(CoreAPIEndpoint.getSiteID)
    }
}
