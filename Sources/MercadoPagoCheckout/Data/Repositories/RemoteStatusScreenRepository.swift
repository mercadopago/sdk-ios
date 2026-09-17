//
//  RemoteStatusScreenRepository.swift
//  MercadoPagoSDK
//

import MPCore

struct RemoteStatusScreenRepository: StatusScreenRepository {
    typealias Dependency = HasNetwork

    private let dependencies: Dependency

    init(dependencies: Dependency = CoreDependencyContainer.shared) {
        self.dependencies = dependencies
    }

    func fetchStatusScreen(
        request: StatusScreenRequestBody,
        clientToken: String
    ) async throws -> StatusScreenResponse {
        try await self.dependencies.networkService.request(
            StatusScreenEndpoint(clientToken: clientToken, requestBody: request)
        )
    }
}
