//
//  MPApplePayRepository.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 23/07/25.
//


import Foundation
import PassKit
#if SWIFT_PACKAGE
    import MPCore
#endif


/// Abstraction for Apple Pay repository behaviors.
protocol ApplePayRepositoryProtocol: Sendable {
    /// Creates an Apple Pay token using backend tokenization endpoint.
    /// - Parameter payment: The Apple Pay payment token.
    /// - Returns: A public `MPApplePayToken` with token id and optional bin info.
    func createToken(payment: PKPaymentToken) async throws -> MPApplePayToken
}

/// Default implementation of `ApplePayRepositoryProtocol` backed by `NetworkService`.
final class MPApplePayRepository: ApplePayRepositoryProtocol {

    typealias Dependency = HasNetwork
    private typealias Endpoint = ApplePayEndpoint

    let dependencies: Dependency

    /// Creates a repository instance.
    /// - Parameter dependencies: Object providing network capabilities.
    init(
        dependencies: Dependency
    ) {
        self.dependencies = dependencies
    }

    /// Sends a tokenization request to the backend.
    /// - Parameter payment: `PKPaymentToken` provided by Apple Pay.
    /// - Returns: `MPApplePayToken` on success.
    func createToken(payment: PKPaymentToken) async throws -> MPApplePayToken {
        let body: ApplePayRequestBody = .init(paymentToken: payment)

        let response: MPTokenResponse = try await self.dependencies.networkService.request(
            Endpoint.postToken(body: body)
        )

        return MPApplePayToken(id: response.id, bin: response.bin)
    }
}
