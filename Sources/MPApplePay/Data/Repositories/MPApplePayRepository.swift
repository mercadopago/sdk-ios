//
//  AuthenticateRepositoryProtocol.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 23/07/25.
//


import Foundation
import PassKit
#if SWIFT_PACKAGE
    import MPCore
#endif

protocol ApplePayRepositoryProtocol: Sendable {
    func postToken(_ data: PKPaymentToken) async throws -> MPApplePayToken
}

final class MPApplePayRepository: ApplePayRepositoryProtocol {

    typealias Dependency = HasNetwork
    private typealias Endpoint = ApplePayEndpoint

    let dependencies: Dependency

    init(
        dependencies: Dependency = CoreDependencyContainer.shared,
    ) {
        self.dependencies = dependencies
    }

    func postToken(_ data: PKPaymentToken) async throws -> MPApplePayToken {
        guard let body = data.toJSONData() else {
            throw NSError(domain: "MPApplePayRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create request body"])
        }

        let response: MPTokenResponse = try await self.dependencies.networkService.request(
            Endpoint.postToken(body: body)
        )
        
        return MPApplePayToken(token: response.token)
    }
}
