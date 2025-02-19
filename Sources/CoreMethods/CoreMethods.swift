//
//  CoreMethods.swift
//  CoreMethods
//
//  Created by Guilherme Prata Costa on Dec 19, 2024.
//  Copyright © 2024 Mercado Pago. All rights reserved.
//

import Foundation
import MPCore

/// CoreMethods provides access to Mercado Pago's public API functionality.
/// This class serves as the main entry point for interacting with Mercado Pago's payment processing services,
///
/// Usage Example:
/// ```swift
/// let coreMethods = CoreMethods()
/// Task {
///     let token = await coreMethods.createToken(
///         cardNumber: cardNumberField,
///         expirationDate: expirationField,
///         securityCode: securityCodeField
///     )
/// }
/// ```
public final class CoreMethods: Sendable {
    private let generateTokenUseCase: GenerateCardTokenUseCaseProtocol

    /// Initializes a new instance of CoreMethods with default dependencies.
    ///
    /// This initializer sets up the class with the standard implementation of the card token generation use case.
    /// Use this initializer for production code.
    public init() {
        self.generateTokenUseCase = GenerateCardTokenUseCase()
    }

    /// Initializes a new instance of CoreMethods with custom dependencies.
    ///
    /// This initializer allows injection of a custom implementation of the use cases.
    /// - Parameter generateTokenUseCase: A custom implementation of the card token generation protocol
    /// - Note: This initializer is intended for testing purposes only
    init(generateTokenUseCase: GenerateCardTokenUseCaseProtocol) {
        self.generateTokenUseCase = generateTokenUseCase
    }

    /// Creates a card token using the provided card details.
    ///
    /// This method processes the input from various card-related text fields and generates
    /// a token that can be used for payment processing through Mercado Pago's API.
    ///
    /// - Parameters:
    ///   - cardNumber: A text field containing the card number
    ///   - expirationDate: A text field containing the card's expiration date
    ///   - securityCode: A text field containing the card's security code (CVV)
    ///
    /// - Returns: A `CardToken` object containing the tokenized card information
    ///
    /// - Throws: An error if token generation fails
    ///
    /// - Note: This method performs asynchronous operations to retrieve values from the text fields
    ///         and to communicate with the Mercado Pago API
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
