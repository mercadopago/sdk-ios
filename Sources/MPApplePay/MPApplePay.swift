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
        self.useCase = MPApplePayUseCase()
    }
    
    init(_ useCase: MPApplePayUseCaseProtocol) {
        self.useCase = useCase
    }
    
    public func createToken(_ paymentToken: PKPaymentToken) async throws -> MPApplePayToken {
        return useCase.createToken(paymentToken)
    }
}
