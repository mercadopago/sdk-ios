//
//  GenerateCardTokenUseCaseProtocol.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 17/07/25.
//


import Foundation
#if SWIFT_PACKAGE
    import MPCore
#endif
import uSDK

protocol ThreeDSUseCaseProtocol: Sendable {
    func authenticatedThreeDS(
        transaction: UTransaction,
        token: String,
        authenticationParams: UAuthenticationRequestParameters
    ) async throws -> MPThreeDSAuthenticationResponse
}

final class ThreeDSUseCase: ThreeDSUseCaseProtocol {

    private let repository: AuthenticateRepositoryProtocol

    typealias Dependency = HasFingerPrint

    let dependencies: Dependency

    init(
        dependencies: Dependency = CoreDependencyContainer.shared,
        repository: AuthenticateRepositoryProtocol = AuthenticateRepository()
    ) {
        self.repository = repository
        self.dependencies = dependencies
    }
    
    func authenticatedThreeDS(
        transaction: UTransaction,
        token: String,
        authenticationParams: UAuthenticationRequestParameters
    ) async throws -> MPThreeDSAuthenticationResponse {
        let data = ThreeDSBody(token: token, authenticationRequestParameters: authenticationParams)
        
        let response = try await repository.authenticate(data)

        return response
    }
}
