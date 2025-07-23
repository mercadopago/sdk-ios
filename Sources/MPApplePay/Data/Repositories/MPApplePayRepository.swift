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


protocol ApplePayRepositoryProtocol: Sendable {
    func createToken(payment: PKPaymentToken) async throws -> MPApplePayToken
}

final class MPApplePayRepository: ApplePayRepositoryProtocol {

    typealias Dependency = HasNetwork
    private typealias Endpoint = ApplePayEndpoint

    let dependencies: Dependency

    init(
        dependencies: Dependency
    ) {
        self.dependencies = dependencies
    }

    func createToken(payment: PKPaymentToken) async throws -> MPApplePayToken {
        let body: ApplePayRequestBody = .init(
            paymentData: payment.paymentData
        )

        let response: MPTokenResponse = try await self.dependencies.networkService.request(
            Endpoint.postToken(body: body)
        )
        
        return MPApplePayToken(token: response.token)
    }
}
