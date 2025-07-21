//
//  MPThreeDS.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 14/07/25.
//
import MPCore
import UIKit

/// Errors that can occur during the 3D Secure authentication process.
///
/// This enum defines all possible errors that can be returned during the 3DS authentication flow.
public enum MPThreeDSError: Error {
    /// No directory server is available for the specified payment method.
    case noDirectoryServerAvailable
    
    /// Failed to create a 3DS transaction.
    case transaction
    
    /// Failed to obtain authentication request parameters.
    case authenticationRequestParameters
    
    /// Error during the authentication process.
    /// - Parameter message: Detailed error message.
    case authentication(message: String)
}

/// Main class for 3D Secure authentication.
///
/// `MPThreeDS` provides a simplified interface for implementing 3D Secure authentication in iOS applications.
/// This class abstracts the complexity of 3DS SDKs, enabling easy integration and potential implementation swapping.
///
/// ## Overview
///
/// 3D Secure authentication is a two-step process:
/// 1. **Request Challenge**: Request authentication for a specific card
/// 2. **Start Challenge**: Present the challenge interface to the user
///
/// ## Usage
///
/// ```swift
/// // Basic initialization
/// let threeDS = MPThreeDS()
/// threeDS.challengeDelegate = self
///
/// // With custom configuration
/// let customization = UUiCustomization()
/// let config = ThreeDSConfig(customization: customization)
/// let threeDS = MPThreeDS(config: config)
///
/// // Requesting authentication
/// do {
///     let result = try await threeDS.requestChallenge(
///         cardtoken: "card_token",
///         paymentMethodId: "visa"
///     )
///     
///     if result.status == .challenge {
///         await threeDS.startChallenge(
///             from: navigationController,
///             data: result
///         )
///     }
/// } catch {
///     print("Authentication error: \(error)")
/// }
/// ```
///
public class MPThreeDS: NSObject {

    private let messageVersion = "2.2.0"
    private let useCase = ThreeDSUseCase()
    private let threeDSSDK: ThreeDSSDKProtocol
    
    /// Delegate to receive callbacks from the challenge process.
    ///
    /// Configure this delegate to receive notifications about the 3DS challenge result.
    /// The delegate will be called when the challenge is completed, cancelled, times out, or fails.
    public weak var challengeDelegate: MPThreeDSChallengeDelegate?
    
    /// Initializes a new instance of MPThreeDS.
    ///
    /// - Parameter config: Configuration for 3DS interface customization. If not provided, uses default configuration.
    ///
    /// ## Example
    /// ```swift
    /// // Default configuration
    /// let threeDS = MPThreeDS()
    ///
    /// // With customization
    /// let customization = UUiCustomization()
    /// // Configure customization...
    /// let config = ThreeDSConfig(customization: customization)
    /// let threeDS = MPThreeDS(config: config)
    /// ```
    public init(
        config: ThreeDSConfig = ThreeDSConfig(),
    ) {
        self.threeDSSDK = USDKAdapter()
        super.init()
        
        let locale = MercadoPagoSDK.shared.configuration?.locale ?? "en_US"
        self.threeDSSDK.initialize(
            config: config,
            locale: locale
        ) { error in
            if let error = error {
                print("3DS SDK failed to initialize: \(error)")
            } else {
                print("3DS SDK successfully initialized")
            }
        }
    }
    
    /// Requests 3D Secure authentication for a specific card.
    ///
    /// This method initiates the 3DS authentication process, collecting device information
    /// and communicating with the 3DS server to determine if a challenge is required.
    ///
    /// - Parameters:
    ///   - cardtoken: Card token for authentication.
    ///   - paymentMethodId: Payment method ID (e.g., "visa", "master", "amex").
    ///
    /// - Returns: ``MPThreeDSAuthenticated`` containing the authentication status and challenge parameters.
    ///
    /// - Throws: ``MPThreeDSError`` if any error occurs during the process.
    ///
    /// ## Example
    /// ```swift
    /// do {
    ///     let result = try await threeDS.requestChallenge(
    ///         cardtoken: "mp_token_123456",
    ///         paymentMethodId: "visa"
    ///     )
    ///     
    ///     switch result.status {
    ///     case .challenge:
    ///         // Challenge required - call startChallenge()
    ///         await startChallenge(from: navigationController, data: result)
    ///     case .notAuthorized:
    ///         // Authentication completed without challenge
    ///         print("Authentication completed")
    ///     }
    /// } catch MPThreeDSError.noDirectoryServerAvailable {
    ///     print("Payment method does not support 3DS")
    /// } catch {
    ///     print("Authentication error: \(error)")
    /// }
    /// ```
    public func requestChallenge(
        cardtoken: String,
        paymentMethodId: String
    ) async throws(MPThreeDSError) -> MPThreeDSAuthenticated {
        /**
         Gets the Directory Server from the selected Payment Method ID
         */
        guard let directoryServer = MPThreeDSDirectoryServer(rawValue: paymentMethodId) else {
            throw .noDirectoryServerAvailable
        }

        /**
         Creates an instance of Transaction. 3DS Requestor App gets the data that is required to perform the transaction.
         */
        guard let transaction = threeDSSDK.createTransaction(
            directoryServerId: directoryServer.id,
            messageVersion: messageVersion
        ) else {
            throw .transaction
        }

        /**
         When the 3DS Requestor App calls this method, the 3DS SDK encrypts the
         device information that it collects during initialization and sends this information along with the SDK information to
         the 3DS Requestor App.
         */
        guard let authenticationRequestParameters = transaction.getAuthenticationRequestParameters() else {
            throw .authenticationRequestParameters
        }
        
        do {
            return try await useCase.authenticatedThreeDS(
                transaction: transaction,
                token: cardtoken,
                authenticationParams: authenticationRequestParameters
            )
            
        } catch {
            throw .authentication(message: error.localizedDescription)
        }
    }
    
    /// Starts the 3D Secure challenge by presenting the interface to the user.
    ///
    /// This method should be called when ``requestChallenge(cardtoken:paymentMethodId:)`` 
    /// returns a status of `.challenge`. It presents the 3DS authentication interface to the user.
    ///
    /// - Parameters:
    ///   - navigationController: Navigation controller to present the challenge interface.
    ///   - data: Authentication data returned by ``requestChallenge(cardtoken:paymentMethodId:)``.
    ///
    /// - Important: This method must be called on the main thread.
    /// - Note: Configure ``challengeDelegate`` before calling this method to receive result callbacks.
    ///
    /// ## Example
    /// ```swift
    /// // Configure the delegate first
    /// threeDS.challengeDelegate = self
    ///
    /// // Start the challenge
    /// await threeDS.startChallenge(
    ///     from: self.navigationController!,
    ///     data: authenticationResult
    /// )
    ///
    /// // The result will be reported via delegate:
    /// extension MyViewController: MPThreeDSChallengeDelegate {
    ///     func completed(transactionStatus: String, transactionId: String) {
    ///         print("Challenge completed: \(transactionStatus)")
    ///     }
    /// }
    /// ```
    @MainActor
    public func startChallenge(
        from navigationController: UINavigationController,
        data: MPThreeDSAuthenticated
    ) async {
        let challengeParams = ThreeDSChallengeParameters(
            threeDSServerTransactionID: data.parameters.threeDSServerTransID,
            acsTransactionID: data.parameters.acsTransID,
            acsRefNumber: data.parameters.acsReferenceNumber,
            acsSignedContent: data.parameters.acsSignedContent
        )
        
        data.transaction.doChallenge(
            navigationController,
            challengeParameters: challengeParams,
            challengeStatusReceiver: self,
            timeOut: 20
        )
    }
}

extension MPThreeDS: ThreeDSChallengeStatusReceiver {

    public func completed(transactionStatus: String, transactionId: String) {
        challengeDelegate?.completed(
            transactionStatus: transactionStatus,
            transactionId: transactionId
        )
    }

    public func cancelled() {
        challengeDelegate?.cancelled()
    }

    public func timedout() {
        challengeDelegate?.timedout()
    }

    public func protocolError(transactionId: String, code: String, message: String, detail: String?) {
        let challengeError = MPThreeDSChallengeError(
            code: code,
            errorType: .protocolError,
            message: message,
            detail: detail
        )
        
        challengeDelegate?.protocolError?(
            transactionId: transactionId,
            error: challengeError
        )
    }

    public func runtimeError(code: String, message: String) {
        let error = MPThreeDSChallengeError(
            code: code,
            errorType: .runtimeError,
            message: message,
            detail: nil
        )
        
        challengeDelegate?.runtimeError?(error: error)
    }
}
