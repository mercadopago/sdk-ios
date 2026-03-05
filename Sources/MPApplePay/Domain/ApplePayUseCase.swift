//
//  ApplePayUseCase.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 23/07/25.
//

import Foundation
import PassKit
#if SWIFT_PACKAGE
    import MPCore
#endif

/// Abstraction of Apple Pay tokenization business rules.
protocol ApplePayUseCaseProtocol: Sendable {
    func createToken(
        _ payment: PKPaymentToken,
        status: String?
    ) async throws -> MPApplePayToken
}

final class ApplePayUseCase: ApplePayUseCaseProtocol {

    private let repository: ApplePayRepositoryProtocol
    
    typealias Dependency = HasFingerPrint

    let dependencies: Dependency

    /// Creates a use case instance.
    /// - Parameter dependencies: Dependencies of UseCase
    /// - Parameter repository: Repository responsible for network operations.
    init(
        dependencies: Dependency,
        repository: ApplePayRepositoryProtocol
    ) {
        self.repository = repository
        self.dependencies = dependencies
    }

    /// Exchanges an Apple Pay token with the backend.
    /// - Parameter payment: `PKPaymentToken` received from Apple Pay sheet.
    /// - Returns: `MPApplePayToken` with backend token data.
    func createToken(_ payment: PKPaymentToken, status: String?) async throws -> MPApplePayToken {
        
        let deviceData = await dependencies.fingerPrint.getDeviceData() ?? Data()

        return try await repository.createToken(payment: payment, status: status, device: deviceData)
    }
}
