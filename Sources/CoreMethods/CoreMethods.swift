//
//  CoreMethods.swift
//  CoreMethods
//
//  Created by Guilherme Prata Costa on Dec 19, 2024.
//  Copyright © 2024 Mercado Pago. All rights reserved.
//

import Foundation
import MPCore

public final class CoreMethods: Sendable {
    private let generateTokenUseCase: GenerateCardTokenUseCaseProtocol = GenerateCardTokenUseCase()

    public init() {}

    public func createToken(
        cardNumber: CardNumberTextField,
        expirationDate: ExpirationDateTextfield,
        securityCode: SecurityCodeTextField
    ) async throws -> CardToken {
        let cardNumber = await cardNumber.input.getValue()
        let expirationDateYear = await expirationDate.getYear()
        let expirationDateMonth = await expirationDate.getMonth()
        let securityCode = await securityCode.input.getValue()

        return try await self.generateTokenUseCase
            .tokenize(
                cardNumber: cardNumber,
                expirationDateMonth: expirationDateMonth,
                expirationDateYear: expirationDateYear,
                securityCodeInput: securityCode
            )
    }
}
