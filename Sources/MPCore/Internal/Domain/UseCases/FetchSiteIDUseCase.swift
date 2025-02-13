//
//  FetchSiteIDUseCase.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 12/02/25.
//

protocol FetchSiteIDUseCaseProtocol: Sendable {
    func getSiteID(by publicKey: String) async -> String
}

final class FetchSiteIDUseCase: FetchSiteIDUseCaseProtocol {
    private let repository: SiteRepositoryProtocol = SiteRepository()

    typealias Dependency = HasKeyChain

    private let dependencies: Dependency

    init(dependencies: Dependency = CoreDependencyContainer.shared) {
        self.dependencies = dependencies
    }

    func getSiteID(by publicKey: String) async -> String {
        do {
            guard let siteCache = try await dependencies.keyChainService.retrieve(account: publicKey) else {
                let response = try await repository.getID()
                try await self.dependencies.keyChainService.save(response.id, account: publicKey)

                return response.id
            }

            return siteCache
        } catch {
            return "unkown"
        }
    }
}
