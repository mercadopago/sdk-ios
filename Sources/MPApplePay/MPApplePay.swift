//
//  MPApplePay.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 23/07/25.
//

import Foundation
import PassKit

public final struct MPApplePay {
    
    private let useCase: MPApplePayUseCaseProtocol
    
    public init() {
        let networkDependency = CoreDependencyContainer.shared
        let repository = MPApplePayRepository(dependencies: networkDependency)
        let useCase = ApplePayUseCase(repository: repository)
        
        self.useCase = useCase
    }
    
    init(_ useCase: MPApplePayUseCaseProtocol) {
        self.useCase = useCase
    }
}

extension MPApplePay {
    public func createToken(_ paymentToken: PKPaymentToken) async throws -> MPApplePayToken {
        return useCase.createToken(paymentToken)
    }
}
