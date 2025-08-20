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
    import MPAnalytics
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
public final class MPApplePay: Sendable {
    
    private let useCase: ApplePayUseCaseProtocol
    
    typealias Dependency = HasAnalytics
    let dependencies: Dependency
    
    struct Analytics {
        static let tokenization = "/checkout_api_native/core_methods/tokenization"
    }
    
    public init() {
        let container = CoreDependencyContainer.shared
        self.dependencies = container
        let repository = MPApplePayRepository(dependencies: container)
        let useCase = ApplePayUseCase(repository: repository)
        
        self.useCase = useCase
    }
    
    init(dependencies: Dependency, _ useCase: ApplePayUseCaseProtocol) {
        self.dependencies = dependencies
        self.useCase = useCase
    }
}

extension MPApplePay {
    /// Exchanges an Apple Pay payment token for a Mercado Pago token.
    /// - Parameters:
    ///   - paymentToken:  The `PKPaymentToken` obtained from Apple Pay.
    ///   - status: This parameter only will be using for testing payments Link for status: https://www.mercadopago.com.br/developers/pt/docs/checkout-api/integration-test/test-cards
    /// - Returns: A `MPApplePayToken` with an identifier and BIN information when available.
    /// - Throws: Errors originating from the underlying network request or response decoding.
    public func createToken(_ paymentToken: PKPaymentToken, status: String? = nil) async throws -> MPApplePayToken {
        do {
            let token = try await useCase.createToken(paymentToken, status: status)
            
            Task.detached {
                await self.dependencies.analytics
                    .trackEvent(Analytics.tokenization)
                    .setEventData(ApplePayEventData())
                    .send()
            }
            
            return token
            
        } catch {
            Task.detached {
                await self.dependencies.analytics
                    .trackEvent(Analytics.tokenization + "/error")
                    .setEventData(ApplePayEventData())
                    .setError(error.localizedDescription)
                    .send()
            }
            
            throw error
        }
    }
}
