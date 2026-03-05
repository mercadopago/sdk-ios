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
        let useCase = ApplePayUseCase(dependencies: container, repository: repository)
        
        self.useCase = useCase
    }
    
    init(dependencies: Dependency, _ useCase: ApplePayUseCaseProtocol) {
        self.dependencies = dependencies
        self.useCase = useCase
    }
}

public extension MPApplePay {

    // MARK: - Public Functions

    /**
     Returns the list of card networks that Mercado Pago supports for Apple Pay transactions.
     
     - Note: Currently, the supported networks are: Visa, Mastercard, and Maestro.
     
     - Returns: An array of `PKPaymentNetwork` containing the compatible card networks.
     */
    static func supportedPKPaymentNetworks() -> [PKPaymentNetwork] {
        return [
            .masterCard,
            .maestro,
            .visa,
        ]
    }
     
    /**
     Creates and pre-configures a `PKPaymentRequest` object with recommended default values for Mercado Pago.
     
     This convenience method simplifies the creation of the payment request by automatically configuring
     the `merchantIdentifier`, the supported payment networks (`supportedNetworks`), the 3D Secure capability (`merchantCapabilities`),
     the country code (`countryCode`), and the currency code (`currencyCode`).
     
     - Important: You still **must** configure the `paymentSummaryItems` property of the returned object
     to detail the purchase items and the total amount.
     
     - Parameters:
        - merchantIdentifier: Your Apple Merchant ID.
        - currencyCode: The three-letter ISO 4217 currency code for the transaction (e.g., "USD" for US Dollar).
     
     - Returns: A `PKPaymentRequest` instance ready to be used after adding the `paymentSummaryItems`.
     */
    static func paymentRequest(
        withMerchantIdentifier merchantIdentifier: String,
        currency currencyCode: String
    ) -> PKPaymentRequest {
        let paymentRequest = PKPaymentRequest()
        
        paymentRequest.merchantIdentifier = merchantIdentifier
        paymentRequest.supportedNetworks = supportedPKPaymentNetworks()
        paymentRequest.merchantCapabilities = .capability3DS
        paymentRequest.countryCode = String(MercadoPagoSDK.shared.configuration?.country.rawValue.dropLast() ?? "")
        paymentRequest.currencyCode = currencyCode.uppercased()
         
        return paymentRequest
    }
     
    /**
     Checks if the user's device can make Apple Pay payments through one of the networks
     supported by Mercado Pago.
     
     This function checks two conditions:
     1. Whether the device hardware supports Apple Pay.
     2. Whether the user has at least one card added to their Apple Wallet from a compatible network
        (Visa, Mastercard, or Maestro).
     
     - Tip: Use this method to decide whether the Apple Pay button should be displayed in your user interface.
     
     - Returns: `true` if Apple Pay payments are possible; otherwise, `false`.
     */
    static func canMakePayments() -> Bool {
        return PKPaymentAuthorizationController.canMakePayments(
            usingNetworks: self.supportedPKPaymentNetworks()
        )
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
