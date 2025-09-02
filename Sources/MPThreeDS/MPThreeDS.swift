//
//  MPThreeDS.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 14/07/25.
//
import MPCore
import UIKit

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
///
/// // With custom configuration
/// let customization = UUiCustomization()
/// let config = ThreeDSConfig(customization: customization)
/// let threeDS = MPThreeDS(config: config)
///
/// do {
///     // Get authentication parameters
///     var authData = try threeDS.getAuthenticationRequestParameters(
///         paymentMethodId: "visa"
///     )
///     
///     // Send authData.parameters to your backend for challenge verification
///     // If backend returns challenge parameters, start the challenge:
///     if let challengeParams = challengeParametersFromBackend {
///         authData.challengeParameters = challengeParams
///         
///         let result = await threeDS.startChallenge(
///             from: navigationController,
///             data: authData
///         )
///         
///         switch result {
///         case .completed(let status, let transactionId):
///             if status == "Y" {
///                 // Authentication successful - proceed with payment
///                 proceedWithPayment(transactionId: transactionId)
///             } else {
///                 // Authentication failed or declined
///                 handleAuthenticationFailure(status: status)
///             }
///         case .cancelled:
///             showMessage("Authentication was cancelled")
///         case .timedout:
///             showMessage("Authentication timed out")
///         case .protocolError(_, let error):
///             handleError(error)
///         case .runtimeError(let error):
///             handleError(error)
///         }
///     }
/// } catch {
///     print("Authentication error: \(error)")
/// }
/// ```
///
public class MPThreeDS: NSObject {

    private let messageVersion = "2.2.0"
    private let threeDSSDK: ThreeDSSDKProtocol
    
    internal var parameters: MPThreeDSParameters?
    
    /// Delegate to receive callbacks from the challenge process.
    ///
    /// Configure this delegate to receive notifications about the 3DS challenge result.
    /// The delegate will be called when the challenge is completed, cancelled, times out, or fails.
    /// 
    /// - Note: This delegate is also called when using the async/await API for backward compatibility.
    public weak var challengeDelegate: MPThreeDSChallengeDelegate?
    
    /// Internal continuation for async/await support.
    internal var challengeContinuation: CheckedContinuation<MPThreeDSChallengeResult, Never>?
    
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
    
    /// Returns security warnings generated during 3DS SDK initialization.
    ///
    /// The 3DS SDK performs several security checks during initialization time to assess
    /// the safety of the mobile device environment. These checks may produce warnings
    /// that help determine whether it's safe to initiate 3D Secure authentication.
    ///
    /// - Returns: Array of ``MPThreeDSWarning`` objects containing security warning details.
    ///
    public func getWarnings() -> [MPThreeDSWarning] {
        return threeDSSDK.getWarnings()
    }
    
    /// Requests 3D Secure authentication parameters for a specific payment method.
    ///
    /// This method initiates the 3DS authentication process by collecting device information
    /// and generating the necessary parameters that should be sent to your backend for
    /// challenge verification.
    ///
    /// - Parameters:
    ///   - paymentMethodId: Payment method ID (e.g., "visa", "master", "amex").
    ///
    /// - Returns: ``MPThreeDSParameters`` containing authentication parameters and transaction reference.
    ///
    /// - Throws: ``MPThreeDSError`` if any error occurs during the process.
    ///
    /// ## Example
    /// ```swift
    /// do {
    ///     let authData = try threeDS.requestParameters(paymentMethodId: "visa")
    ///     // Send authData.parameters to your backend
    /// } catch MPThreeDSError.noDirectoryServerAvailable {
    ///     print("Payment method not supported for 3DS")
    /// } catch {
    ///     print("3DS authentication failed: \(error)")
    /// }
    /// ```
    public func requestParameters(
        paymentMethodId: String
    ) throws(MPThreeDSError) -> MPThreeDSParameters {
        
        /// Gets the Directory Server from the selected Payment Method ID
        guard let directoryServer = MPThreeDSDirectoryServer(rawValue: paymentMethodId) else {
            throw .noDirectoryServerAvailable
        }

        /// Creates an instance of Transaction. 3DS Requestor App gets the data that is required to perform the transaction.
        guard let transaction = threeDSSDK.createTransaction(
            directoryServerId: directoryServer.id,
            messageVersion: messageVersion
        ) else {
            throw .transaction
        }

        /// When the 3DS Requestor App calls this method, the 3DS SDK encrypts the
        /// device information that it collects during initialization and sends this information along with the SDK information to
        /// the 3DS Requestor App.
        guard let authenticationRequestParameters = transaction.getAuthenticationRequestParameters() else {
            throw .authenticationRequestParameters
        }
        
        let warnings = getWarnings()
        
        let createParameters: MPThreeDSParameters = .init(
            authenticationRequestParameters: authenticationRequestParameters,
            warnings: warnings,
            transaction: transaction
        )
        
        parameters = createParameters
        
        return createParameters
    }
    
    /// Starts the 3D Secure challenge and returns the result asynchronously.
    ///
    /// This method should be called when your backend determines that a challenge is required
    /// and returns challenge parameters. It presents the 3DS authentication interface to the user
    /// and returns the authentication result.
    ///
    /// - Parameters:
    ///   - navigationController: Navigation controller to present the challenge interface.
    ///   - data: Authentication data returned by ``getAuthenticationRequestParameters(paymentMethodId:)``.
    ///   - timeOut: Challenge timeout in seconds. Default is 20 seconds.
    ///
    /// - Returns: ``MPThreeDSChallengeResult`` containing the authentication outcome.
    ///
    /// - Important: This method must be called on the main thread.
    ///
    /// ## Example
    /// ```swift
    /// do {
    ///     var authData = try threeDS.requestParameters(paymentMethodId: "visa")
    ///
    ///     let challengeParametersFromBackend = requestServer(authData.authenticationRequestParameters)
    ///
    ///     authData.challengeParameters = challengeParametersFromBackend
    ///     
    ///     let result = await threeDS.startChallenge(
    ///         from: navigationController,
    ///         data: authData
    ///     )
    ///     
    ///     switch result {
    ///     case .completed(let status, let transactionId):
    ///         if status == "Y" {
    ///             // Authentication successful
    ///             proceedWithPayment(transactionId: transactionId)
    ///         } else {
    ///             handleAuthenticationFailure(status: status)
    ///         }
    ///     case .cancelled:
    ///         showMessage("Authentication was cancelled")
    ///     case .timedout:
    ///         showMessage("Authentication timed out")
    ///     case .protocolError(let transactionId, let error):
    ///         handleProtocolError(error, transactionId: transactionId)
    ///     case .runtimeError(let error):
    ///         handleRuntimeError(error)
    ///     }
    /// } catch {
    ///     handleError(error)
    /// }
    /// ```
    @MainActor
    public func startChallenge(
        from navigationController: UINavigationController,
        parameters: MPThreeDSParameters,
        timeOut: Int32 = 20
    ) async -> MPThreeDSChallengeResult {
        guard let challengeParameters = parameters.challengeParameters else {
            return .runtimeError(error: MPThreeDSChallengeError(
                code: "MISSING_CHALLENGE_PARAMS",
                errorType: .runtimeError,
                message: "Challenge parameters are required but missing",
                detail: "Ensure challengeParameters is set on MPThreeDSAuthenticated before calling startChallenge"
            ))
        }
        
        return await withCheckedContinuation { continuation in
            self.challengeContinuation = continuation
            
            parameters.transaction.doChallenge(
                navigationController,
                challengeParameters: challengeParameters,
                challengeStatusReceiver: self,
                timeOut: timeOut
            )
        }
    }
    
    /// The close method is called to clean up resources that are held by the Transaction object. It shall be called when the transaction is completed. The following are some examples of transaction completion events:
    ///
    /// - The Cardholder completes the challenge.
    /// - An error occurs
    /// - The Cardholder chooses to cancel the transaction.
    /// - The ACS recommends a challenge, but the Merchant overrides the recommendation and chooses to complete the transaction without a challenge
    public func close() throws {
        try parameters?.transaction.close()
    }
}
