//
//  MPApplePay.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 23/07/25.
//

import Foundation
import PassKit
#if SWIFT_PACKAGE
    @_exported import MPCore
#endif

/// Primary entry point for Apple Pay tokenization with Mercado Pago.
///
/// Use this type to exchange an Apple Pay `PKPaymentToken` for a backend token
/// (`MPApplePayToken`) that you can later use to create a payment in your backend.
///
/// Example:
/// ```swift
/// let mpApplePay = MPApplePay()
/// let token = try await mpApplePay.createToken(payment.token)
/// print(token.id)
/// ```
public struct MPApplePay {
    
    private let useCase: ApplePayUseCaseProtocol
    
    public init() {
        let networkDependency = CoreDependencyContainer.shared
        let repository = MPApplePayRepository(dependencies: networkDependency)
        let useCase = ApplePayUseCase(repository: repository)
        
        self.useCase = useCase
    }
    
    init(_ useCase: ApplePayUseCaseProtocol) {
        self.useCase = useCase
    }
}

extension MPApplePay {
    /// Exchanges an Apple Pay payment token for a Mercado Pago token.
    /// - Parameter paymentToken: The `PKPaymentToken` obtained from Apple Pay.
    /// - Returns: A `MPApplePayToken` with an identifier and BIN information when available.
    /// - Throws: Errors originating from the underlying network request or response decoding.
    public func createToken(_ paymentToken: PKPaymentToken) async throws -> MPApplePayToken {
        return try await useCase.createToken(paymentToken)
    }
}
