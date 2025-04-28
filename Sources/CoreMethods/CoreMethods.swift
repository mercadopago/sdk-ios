//
//  CoreMethods.swift
//  CoreMethods
//
//  Created by Guilherme Prata Costa on Dec 19, 2024.
//  Copyright © 2024 Mercado Pago. All rights reserved.
//

import Foundation
#if SWIFT_PACKAGE
    import MPAnalytics
    @_exported import MPCore
#endif

/// CoreMethods provides access to Mercado Pago's public API functionality.
/// This class serves as the main entry point for interacting with Mercado Pago's payment processing services,
/// offering methods for card tokenization, fetching payment options, and retrieving supported identification types.
///
/// # Features
/// - Card tokenization for new and saved cards
/// - Retrieval of accepted identification document types
/// - Fetching of available installment options for payments
/// - Discovery of payment methods supported for a specific card
///
/// # Thread Safety
/// This class is thread-safe and can be used from multiple threads simultaneously.
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
    private let installmentsUseCase: InstallmentsUseCaseProtocol
    private let paymentMethodUseCase: PaymentMethodUseCaseProtocol
    private let issuerUseCase: IssuerUseCaseProtocol

    typealias Dependency = HasAnalytics & HasFingerPrint

    let dependencies: Dependency

    /// Initializes a new instance of CoreMethods with default dependencies.
    ///
    /// This initializer sets up the class with the standard implementation of the card token generation use case.
    /// Use this initializer for production code.
    public init() {
        self.dependencies = CoreDependencyContainer.shared
        self.generateTokenUseCase = GenerateCardTokenUseCase(dependencies: self.dependencies)
        self.identificationTypeUseCase = IdentificationTypesUseCase()
        self.installmentsUseCase = InstallmentsUseCase()
        self.paymentMethodUseCase = PaymentMethodUseCase()
        self.issuerUseCase = IssuerUseCase()
    }

    /// Initializes a new instance of CoreMethods with custom dependencies.
    ///
    /// This initializer allows injection of a custom implementation of the use cases.
    /// - Parameter generateTokenUseCase: A custom implementation of the card token generation protocol
    /// - Note: This initializer is intended for testing purposes only
    init(
        dependencies: Dependency,
        generateTokenUseCase: GenerateCardTokenUseCaseProtocol,
        identificationTypeUseCase: IdentificationTypesUseCaseProtocol,
        installmentsUseCase: InstallmentsUseCaseProtocol,
        paymentMethodUseCase: PaymentMethodUseCaseProtocol,
        issuerUseCase: IssuerUseCaseProtocol
    ) {
        self.dependencies = dependencies
        self.generateTokenUseCase = generateTokenUseCase
        self.identificationTypeUseCase = identificationTypeUseCase
        self.installmentsUseCase = installmentsUseCase
        self.paymentMethodUseCase = paymentMethodUseCase
        self.issuerUseCase = issuerUseCase
    }

    /// Creates a card token using the provided card details.
    ///
    /// This method processes the input from card-related text fields and generates
    /// a token that can be used for payment processing through Mercado Pago's API.
    /// It's suitable for collecting minimal card information without cardholder details.
    ///
    /// # Example
    /// ```swift
    /// Task {
    ///     do {
    ///         let token = try await coreMethods.createToken(
    ///             cardNumber: cardNumberField,
    ///             expirationDate: expirationField,
    ///             securityCode: securityCodeField
    ///         )
    ///         print("Generated token: \(token.id)")
    ///     } catch {
    ///         print("Token generation failed: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - cardNumber: A text field containing the card number
    ///   - expirationDate: A text field containing the card's expiration date in MM/YY format
    ///   - securityCode: A text field containing the card's security code (CVV)
    ///
    /// - Returns: A CardToken object containing the generated card token and related information
    ///
    /// - Throws:
    ///   - NetworkError: If communication with the API fails
    ///   - ValidationError: If the provided card details are invalid
    ///   - DecodingError: If the API response cannot be properly decoded
    ///
    /// - Note: This method performs asynchronous operations to retrieve values from the text fields
    ///         and to communicate with the Mercado Pago API
    ///
    public func createToken(
        cardNumber: CardNumberTextField,
        expirationDate: ExpirationDateTextfield,
        securityCode: SecurityCodeTextField
    ) async throws -> CardToken {
        return try await executeWithTracking(
            operation: {
                async let cardNumber = cardNumber.input.getValue()
                async let expirationDateYear = expirationDate.getYear()
                async let expirationDateMonth = expirationDate.getMonth()
                async let securityCode = securityCode.input.getValue()

                return try await self.generateTokenUseCase
                    .tokenize(
                        cardNumber: cardNumber,
                        expirationDateMonth: expirationDateMonth,
                        expirationDateYear: expirationDateYear,
                        securityCodeInput: securityCode,
                        cardID: nil,
                        cardHolderName: nil,
                        identificationType: nil,
                        identificationNumber: nil
                    )
            },
            path: AnalyticsPath.tokenization,
            extractEventData: { _ -> TokenizationEventData? in
                return TokenizationEventData(isSaveCard: false, documentType: "")
            }
        )
    }

    /// Creates a card token using the provided card details and cardholder information.
    ///
    /// This method processes the input from card-related text fields along with cardholder details
    /// to generate a token that can be used for payment processing through Mercado Pago's API.
    /// Use this method when full cardholder information is required for the transaction.
    ///
    /// # Example
    /// ```swift
    /// Task {
    ///     do {
    ///         // First, fetch available document types
    ///         let documentTypes = try await coreMethods.identificationTypes()
    ///
    ///         // User need select type select
    ///         guard let documentType = documentTypes[0]
    ///
    ///         let token = try await coreMethods.createToken(
    ///             cardNumber: cardNumberField,
    ///             expirationDate: expirationField,
    ///             securityCode: securityCodeField,
    ///             documentType: documentType,
    ///             documentNumber: "12345678900",
    ///             cardHolderName: "João Silva"
    ///         )
    ///         print("Generated token: \(token.id)")
    ///     } catch {
    ///         print("Token generation failed: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - cardNumber: A text field containing the card number
    ///   - expirationDate: A text field containing the card's expiration date in MM/YY format
    ///   - securityCode: A text field containing the card's security code (CVV)
    ///   - documentType: The type of identification document for the cardholder
    ///   - documentNumber: The identification number associated with the document type
    ///   - cardHolderName: The full name of the cardholder as it appears on the card
    ///
    /// - Returns: A CardToken object containing the generated card token and related information
    ///
    /// - Throws:
    ///   - NetworkError: If communication with the API fails
    ///   - ValidationError: If the provided card or identification details are invalid
    ///   - DecodingError: If the API response cannot be properly decoded
    ///
    /// - Note: Different countries may require different types of identification documents.
    ///         Use the `identificationTypes()` method to retrieve the valid options.
    public func createToken(
        cardNumber: CardNumberTextField,
        expirationDate: ExpirationDateTextfield,
        securityCode: SecurityCodeTextField,
        documentType: IdentificationType,
        documentNumber: String,
        cardHolderName: String
    ) async throws -> CardToken {
        return try await executeWithTracking(
            operation: {
                async let cardNumber = cardNumber.input.getValue()
                async let expirationDateYear = expirationDate.getYear()
                async let expirationDateMonth = expirationDate.getMonth()
                async let securityCode = securityCode.input.getValue()

                return try await self.generateTokenUseCase
                    .tokenize(
                        cardNumber: cardNumber,
                        expirationDateMonth: expirationDateMonth,
                        expirationDateYear: expirationDateYear,
                        securityCodeInput: securityCode,
                        cardID: nil,
                        cardHolderName: cardHolderName,
                        identificationType: documentType.name,
                        identificationNumber: documentNumber
                    )
            },
            path: AnalyticsPath.tokenization,
            extractEventData: { _ -> TokenizationEventData? in
                return TokenizationEventData(isSaveCard: false, documentType: documentType.name)
            }
        )
    }

    /// Creates a payment token for a previously saved card using its ID.
    ///
    /// Tokenizes a card that was previously saved in Mercado Pago's system by combining its ID
    /// with the user-provided security code and optionally updated expiration date.
    /// The resulting token can be used for payment processing through Mercado Pago's API.
    ///
    /// # Example
    /// ```swift
    /// Task {
    ///     do {
    ///         let savedCardID = "id_card"
    ///         let token = try await coreMethods.createToken(
    ///             cardID: savedCardID,
    ///             securityCode: securityCodeField
    ///         )
    ///         print("Generated token for saved card: \(token.id)")
    ///     } catch {
    ///         print("Token generation for saved card failed: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - cardID: The unique identifier of the saved card
    ///   - expirationDate: Optional text field containing updated expiration date in MM/YY format
    ///   - securityCode: Text field containing the card's security code (CVV)
    ///
    /// - Returns: A CardToken object containing the generated payment token and related information
    ///
    /// - Throws:
    ///   - NetworkError: If communication with the API fails
    ///   - ValidationError: If the provided card ID or security code is invalid
    ///   - DecodingError: If the API response cannot be properly decoded
    ///
    /// - Important: The card must be previously saved in Mercado Pago's system. For new cards,
    ///             use one of the other `createToken` methods instead.
    ///
    /// - Note: The expirationDate parameter is optional and should only be provided if the
    ///         card's expiration date needed.
    public func createToken(
        cardID: String,
        expirationDate: ExpirationDateTextfield? = nil,
        securityCode: SecurityCodeTextField
    ) async throws -> CardToken {
        return try await executeWithTracking(
            operation: {
                async let expirationDateYear = expirationDate?.getYear()
                async let expirationDateMonth = expirationDate?.getMonth()
                async let securityCode = securityCode.input.getValue()

                return try await self.generateTokenUseCase
                    .tokenize(
                        cardNumber: nil,
                        expirationDateMonth: expirationDateMonth,
                        expirationDateYear: expirationDateYear,
                        securityCodeInput: securityCode,
                        cardID: cardID,
                        cardHolderName: nil,
                        identificationType: nil,
                        identificationNumber: nil
                    )
            },
            path: AnalyticsPath.tokenization,
            extractEventData: { _ -> TokenizationEventData? in
                return TokenizationEventData(isSaveCard: true, documentType: "")
            }
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
            path: AnalyticsPath.identificationTypes,
            extractEventData: { result -> IdentificationTypeEventData? in
                let documents = result?.map { data in
                    data.name
                }

                return IdentificationTypeEventData(documentTypes: documents)
            }
        )
    }

    /// Gets available installment options for a payment amount and card BIN
    ///
    /// Retrieves a list of installment plans available for a specified payment amount
    /// and card BIN (first 6-8 digits of the card number). This allows merchants to
    /// present financing options to customers during checkout.
    ///
    /// - Parameters:
    ///   - amount: The payment amount to calculate installment options for
    ///   - bin: Bank Identification Number (first 6-8 digits of card number)
    ///   - mode: The processing mode to use (default: .agreggator)
    ///
    /// - Returns: An array of ``Installment`` objects containing available payment plans
    ///
    /// - Throws:
    ///   - .invalidURL: If the API endpoint URL is malformed
    ///   - .networkError: If a connection to the API cannot be established
    ///   - .decodingFailed(Error): If the response cannot be decoded
    ///
    public func installments(
        amount: Double,
        bin: String,
        mode: ProcessingMode = .aggregator
    ) async throws -> [Installment] {
        let params = InstallmentsParams(amount: amount, bin: bin, processingMode: mode.rawValue)

        return try await executeWithTracking(
            operation: { try await self.installmentsUseCase.getInstallments(params: params) },
            path: AnalyticsPath.installments,
            extractEventData: { result -> InstallmentEventData? in
                return InstallmentEventData(
                    amount: amount,
                    paymentType: result?.first?.paymentTypeId ?? ""
                )
            }
        )
    }

    /// Gets available payment methods for a card BIN
    ///
    /// Retrieves a list of payment methods available for a specified card BIN
    /// (first 6-8 digits of the card number).
    ///
    /// - Parameters:
    ///   - bin: Bank Identification Number (first 6-8 digits of card number)
    ///   - mode: The processing mode to use (default: .aggregator)
    ///
    /// - Returns: An array of ``PaymentMethod`` objects containing available payment methods
    ///
    /// - Throws:
    ///   - .invalidURL: If the API endpoint URL is malformed
    ///   - .networkError: If a connection to the API cannot be established
    ///   - .decodingFailed(Error): If the response cannot be decoded
    ///
    public func paymentMethods(
        bin: String,
        mode: ProcessingMode = .aggregator
    ) async throws -> [PaymentMethod] {
        let params = PaymentMethodsParams(bin: bin, processingMode: mode.rawValue)

        return try await executeWithTracking(
            operation: {
                try await self.paymentMethodUseCase.getPaymentMethods(params: params)
            },
            path: AnalyticsPath.paymentMethods,
            extractEventData: { result -> PaymentMethodEventData? in
                guard let data = result?.first else {
                    return PaymentMethodEventData()
                }

                return PaymentMethodEventData(
                    issuer: data.issuer?.id,
                    paymentType: data.paymentTypeId,
                    sizeSecurityCode: data.card?.securityCode.length,
                    cardBrand: data.id
                )
            }
        )
    }

    /// Gets available issuers for a card BIN and payment method
    ///
    /// Retrieves a list of issuers (banks) that can process a transaction for
    /// a specified card BIN and payment method combination.
    ///
    /// # Example
    /// ```swift
    /// Task {
    ///     do {
    ///         let issuers = try await coreMethods.issuer(
    ///             bin: "411111",
    ///             paymentMethodID: "visa"
    ///         )
    ///         print("Available issuers: \(issuers.map { $0.name }.joined(separator: ", "))")
    ///     } catch {
    ///         print("Failed to fetch issuers: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - bin: Bank Identification Number (first 6-8 digits of card number)
    ///   - paymentMethodID: The ID of the payment method (e.g., "visa", "master")
    ///
    /// - Returns: An array of ``Issuer`` objects representing available card issuers
    ///
    /// - Throws:
    ///   - NetworkError: If communication with the API fails
    ///   - ValidationError: If the provided bin or paymentMethodID is invalid
    ///   - DecodingError: If the API response cannot be properly decoded
    public func issuers(
        bin: String,
        paymentMethodID: String
    ) async throws -> [Issuer] {
        let params = IssuersParams(bin: bin, paymentMethodID: paymentMethodID)

        return try await executeWithTracking(
            operation: {
                try await self.issuerUseCase.getIssuers(params: params)
            },
            path: AnalyticsPath.issuers,
            extractEventData: { result -> IssuersEventData? in
                guard let data = result else {
                    return IssuersEventData(issuers: [])
                }

                let issuers = data.map { data in
                    data.name
                }

                return IssuersEventData(issuers: issuers)
            }
        )
    }
}

// MARK: Execute Operation of Core Methods

private extension CoreMethods {
    private enum AnalyticsPath {
        static let identificationTypes = "/checkout_api_native/core_methods/identification_types"
        static let installments = "/checkout_api_native/core_methods/installments"
        static let paymentMethods = "/checkout_api_native/core_methods/payment_methods"
        static let tokenization = "/checkout_api_native/core_methods/tokenization"
        static let issuers = "/checkout_api_native/core_methods/issuers"
    }

    func executeWithTracking<T: Sendable>(
        operation: @Sendable () async throws -> T,
        path: String,
        extractEventData: (@Sendable (T?) async -> (any AnalyticsEventData)?)? = nil
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
                let event = await self.dependencies.analytics
                    .trackEvent(path + "/error")
                    .setError("\(error)")

                if let extractEventData,
                   let eventData = await extractEventData(nil) {
                    await event.setEventData(eventData)
                }

                await event.send()
            }

            throw error
        }
    }
}
