//
//  FetchSiteIDUseCase.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 12/02/25.
//

protocol FetchSiteIDUseCaseProtocol {
    func getSiteID(by publicKey: String) async -> String
}

final class FetchSiteIDUseCase: FetchSiteIDUseCaseProtocol {
    private let repository: SiteRepositoryProtocol = SiteRepository()

    typealias Dependency = HasKeyChain

    private let dependencies: Dependency

    var currentRetry = 0
    let maxRetry = 3

    init(dependencies: Dependency = CoreDependencyContainer.shared) {
        self.dependencies = dependencies
    }

    func getSiteID(by publicKey: String) async -> String {
        do {
            if let siteCache = try await dependencies.keyChainService.retrieve(account: publicKey) {
                return siteCache
            }

            let response = try await repository.getID()
            try await self.dependencies.keyChainService.save(response.id, account: publicKey)

            return response.id

        } catch let error as APIClientError {
            if currentRetry < maxRetry {
                currentRetry += 1

                return await getSiteID(by: publicKey)
            }

            return "unknown"
        } catch {
            return "unknown"
        }
    }
}
