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
    public func createToken(_ paymentToken: PKPaymentToken) async throws -> MPApplePayToken {
        return try await useCase.createToken(paymentToken)
    }
}
