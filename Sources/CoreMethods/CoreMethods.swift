//
//  CoreMethods.swift
//  CoreMethods
//
//  Created by Guilherme Prata Costa on Dec 19, 2024.
//  Copyright © 2024 Mercado Pago. All rights reserved.
//

import Foundation
import MPAnalytics
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
    private let identificationTypeUseCase: IdentificationTypesUseCaseProtocol

    typealias Dependency = HasAnalytics

    let dependencies: Dependency

    /// Initializes a new instance of CoreMethods with default dependencies.
    ///
    /// This initializer sets up the class with the standard implementation of the card token generation use case.
    /// Use this initializer for production code.
    public init() {
        self.generateTokenUseCase = GenerateCardTokenUseCase()
        self.identificationTypeUseCase = IdentificationTypesUseCase()
        self.dependencies = CoreDependencyContainer.shared
    }

    /// Initializes a new instance of CoreMethods with custom dependencies.
    ///
    /// This initializer allows injection of a custom implementation of the use cases.
    /// - Parameter generateTokenUseCase: A custom implementation of the card token generation protocol
    /// - Note: This initializer is intended for testing purposes only
    init(
        dependencies: Dependency,
        generateTokenUseCase: GenerateCardTokenUseCaseProtocol,
        identificationTypeUseCase: IdentificationTypesUseCaseProtocol
    ) {
        self.dependencies = dependencies
        self.generateTokenUseCase = generateTokenUseCase
        self.identificationTypeUseCase = identificationTypeUseCase
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
    /// - Returns: A CardToken object containing:
    ///   - token: The generated card token
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
                securityCodeInput: securityCode,
                cardID: nil
            )
    }

    /// Creates a payment token for a saved card using its ID
    ///
    /// Tokenizes a previously saved card by combining its ID with the user-provided security
    /// code and expiration date. The resulting token can be used for payment processing
    /// through Mercado Pago's API.
    ///
    /// - Parameters:
    ///   - cardID: The unique identifier of the saved card.
    ///   - expirationDate: ExpirationDateTextfield containing the card's expiration date in MM/YY format
    ///   - securityCode: SecurityCodeTextField  containing the card's 3-4 digit security code (CVV)
    ///
    /// - Returns: A CardToken object containing the generated payment token
    ///
    /// - Throws:
    ///   - .invalidURL: If the API endpoint URL is malformed
    ///   - .decodingFailed(Error): If the response cannot be decoded
    ///
    /// - Important: The card must be previously saved in Mercado Pago's system. For new cards,
    ///             use the  another `createToken` method instead.
    public func createToken(
        cardID: String,
        expirationDate: ExpirationDateTextfield? = nil,
        securityCode: SecurityCodeTextField
    ) async throws -> CardToken {
        let expirationDateYear = await expirationDate?.getYear()
        let expirationDateMonth = await expirationDate?.getMonth()
        let securityCode = await securityCode.input.getValue()

        return try await self.generateTokenUseCase
            .tokenize(
                cardNumber: nil,
                expirationDateMonth: expirationDateMonth,
                expirationDateYear: expirationDateYear,
                securityCodeInput: securityCode,
                cardID: cardID
            )
    }

    /// Gets the identification document types accepted by the Mercado Pago API
    ///
    /// - Returns: An array of ``IdentificationType`` objects representing the available
    ///   document types for user identification
    ///
    /// - Throws:
    ///   - .invalidURL: If the API endpoint URL is malformed
    ///   - .decodingFailed(Error): If the response cannot be decoded
    ///
    public func identificationTypes() async throws -> [IdentificationType] {
        return try await executeWithTracking(
            operation: { try await self.identificationTypeUseCase.getIdentificationTypes() },
            path: "/sdk-native/core-methods/identification_types"
        )
    }
}

// MARK: Execute Operation of Core Methods

private extension CoreMethods {
    func executeWithTracking<T: Sendable>(
        operation: @Sendable () async throws -> T,
        path: String,
        extractEventData: (@Sendable (T) async -> (some AnalyticsEventData)?)? = nil
    ) async throws -> T {
        do {
            let result = try await operation()

            Task(priority: .low) {
                let event = await self.dependencies.analytics.trackEvent(path)

                if let extractEventData,
                   let eventData = await extractEventData(result) {
                    await event.setEventData(eventData)
                }

                await event.send()
            }

            return result
        } catch {
            Task(priority: .low) {
                await self.dependencies.analytics
                    .trackEvent(path + "/error")
                    .setError("\(error)")
                    .send()
            }

            throw error
        }
    }

    func executeWithTracking<T: Sendable>(
        operation: @Sendable () async throws -> T,
        path: String
    ) async throws -> T {
        do {
            let result = try await operation()

            Task(priority: .low) {
                await self.dependencies.analytics
                    .trackEvent(path)
                    .send()
            }

            return result
        } catch {
            Task(priority: .low) {
                await self.dependencies.analytics
                    .trackEvent(path + "/error")
                    .setError("\(error)")
                    .send()
            }

            throw error
        }
    }
}
