//
//  FetchSiteIDUseCase.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 12/02/25.
//

protocol FetchSiteIDUseCaseProtocol {
    func getSiteID(with publicKey: String, and country: MercadoPagoSDK.Country) async -> String
}

enum FetchSiteIDUseCaseFactory {
    static func make(dependencies: CoreDependencyContainer) -> FetchSiteIDUseCase {
        let repository = SiteRepository(dependencies: dependencies)
        return FetchSiteIDUseCase(dependencies: dependencies, repository: repository)
    }
}

final class FetchSiteIDUseCase: FetchSiteIDUseCaseProtocol {
    private let repository: SiteRepositoryProtocol

    typealias Dependency = HasNoDependency

    private let dependencies: Dependency

    var currentRetry = 0
    let maxRetry = 3

    init(dependencies: Dependency, repository: SiteRepositoryProtocol) {
        self.dependencies = dependencies
        self.repository = repository
    }

    func getSiteID(with publicKey: String, and country: MercadoPagoSDK.Country) async -> String {
        do {
            let response = try await repository.getID()

            return response.id
            
        } catch _ as APIClientError {
            if self.currentRetry < self.maxRetry {
                self.currentRetry += 1
                return await self.getSiteID(with: publicKey, and: country)
            }

            return country.getSiteId()
        } catch {
            return country.getSiteId()
        }
    }
}
