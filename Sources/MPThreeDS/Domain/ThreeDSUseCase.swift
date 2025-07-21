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

protocol ThreeDSUseCaseProtocol: Sendable {
    func authenticatedThreeDS(
        transaction: ThreeDSTransactionProtocol,
        token: String,
        authenticationParams: ThreeDSAuthRequestParameters
    ) async throws -> MPThreeDSAuthenticated
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
        transaction: ThreeDSTransactionProtocol,
        token: String,
        authenticationParams: ThreeDSAuthRequestParameters
    ) async throws -> MPThreeDSAuthenticated {
        let data = ThreeDSBody(token: token, authenticationRequestParameters: authenticationParams)
        
        let response = try await repository.authenticate(data)

        let status: MPThreeDSAuthenticated.Status = response.response == "" ? .challenge : .notAuthorized
        
        return MPThreeDSAuthenticated(
            status: status,
            parameters: .init(
                threeDSServerTransID: response.threeDSServerTransID,
                acsReferenceNumber: response.acsReferenceNumber,
                dsTransID: response.dsTransID,
                acsTransID: response.acsTransID,
                acsSignedContent: response.acsSignedContent
            ),
            transaction: transaction
        )
    }
}
