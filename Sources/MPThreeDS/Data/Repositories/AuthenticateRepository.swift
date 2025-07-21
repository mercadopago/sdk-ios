//
//  MPThreeDSRepository.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 17/07/25.
//

import Foundation
#if SWIFT_PACKAGE
    import MPCore
#endif

protocol AuthenticateRepositoryProtocol: Sendable {
    func authenticate(_ data: ThreeDSBody) async throws -> MPThreeDSAuthenticationResponse
}

final class AuthenticateRepository: AuthenticateRepositoryProtocol {
    
    typealias Dependency = HasNetwork
    private typealias Endpoint = ThreeDSEndpoint

    let dependencies: Dependency

    init(
        dependencies: Dependency = CoreDependencyContainer.shared,
    ) {
        self.dependencies = dependencies
    }

    func authenticate(_ data: ThreeDSBody) async throws -> MPThreeDSAuthenticationResponse {
        guard let body = data.toJSONData() else {
            throw NSError(domain: "ThreeDSError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create request body"])
        }
        
        let response: MPThreeDSAuthenticationResponse = try await self.dependencies.networkService.request(
            ThreeDSEndpoint.authenticate(body: body)
        )
        
        return response
    }
}
