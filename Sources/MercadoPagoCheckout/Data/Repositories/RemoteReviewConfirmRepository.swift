//
//  RemoteReviewConfirmRepository.swift
//  MercadoPagoSDK
//

import MPCore

struct RemoteReviewConfirmRepository: ReviewConfirmRepository {
    typealias Dependency = HasNetwork

    private let dependencies: Dependency

    init(dependencies: Dependency = CoreDependencyContainer.shared) {
        self.dependencies = dependencies
    }

    func fetchReviewConfirm(
        request: ReviewConfirmRequestBody,
        clientToken: String,
        checkoutType: String
    ) async throws -> ReviewConfirmResponse {
        try await self.dependencies.networkService.request(
            ReviewConfirmEndpoint(
                clientToken: clientToken,
                checkoutType: checkoutType,
                requestBody: request
            )
        )
    }
}
