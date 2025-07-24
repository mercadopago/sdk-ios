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

protocol ApplePayUseCaseProtocol: Sendable {
    func createToken(
        _ payment: PKPaymentToken
    ) async throws -> MPApplePayToken
}

final class ApplePayUseCase: ApplePayUseCaseProtocol {

    private let repository: ApplePayRepositoryProtocol

    init(
        repository: ApplePayRepositoryProtocol
    ) {
        self.repository = repository
    }

    func createToken(_ payment: PKPaymentToken) async throws -> MPApplePayToken {
        try await repository.createToken(payment: payment)
    }
}
