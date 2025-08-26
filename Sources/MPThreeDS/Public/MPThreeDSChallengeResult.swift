//
//  MPThreeDSChallengeResult.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 17/01/25.
//

/// Result of a 3D Secure challenge operation.
///
/// This enum encapsulates all possible outcomes of a 3DS challenge flow,
/// providing a type-safe way to handle authentication results when using
/// the async/await API.
///
/// ## Usage with Async/Await
/// ```swift
/// let result = await threeDS.startChallenge(
///     from: navigationController,
///     data: authData
/// )
///
/// switch result {
/// case .completed(let status, let transactionId):
///     if status == "Y" {
///         // Authentication successful - proceed with payment
///         proceedWithPayment(transactionId: transactionId)
///     } else {
///         // Authentication failed or declined
///         handleAuthenticationFailure(status: status)
///     }
/// case .cancelled:
///     showMessage("Authentication was cancelled by user")
/// case .timedout:
///     showMessage("Authentication timed out")
/// case .protocolError(let transactionId, let error):
///     handleProtocolError(error, transactionId: transactionId)
/// case .runtimeError(let error):
///     handleRuntimeError(error)
/// }
/// ```
public enum MPThreeDSChallengeResult: Sendable {
    /// Challenge completed successfully.
    ///
    /// - Parameters:
    ///   - transactionStatus: Authentication result status:
    ///     - `"Y"`: Authentication successful
    ///     - `"N"`: Authentication failed  
    ///     - `"U"`: Authentication unavailable
    ///     - `"A"`: Challenge required (rarely seen here)
    ///     - `"C"`: Challenge cancelled by user
    ///   - transactionId: Unique identifier for this authentication transaction
    case completed(transactionStatus: String, transactionId: String)
    
    /// Challenge was cancelled by the user.
    ///
    /// This occurs when the user explicitly cancels the authentication process,
    /// typically by tapping a cancel button or using system gestures.
    case cancelled
    
    /// Challenge timed out.
    ///
    /// This occurs when the challenge exceeds the configured timeout period.
    /// The user may have abandoned the flow or experienced connectivity issues.
    case timedout
    
    /// Protocol error occurred during the challenge.
    ///
    /// Protocol errors indicate issues with 3DS communication, such as
    /// invalid responses, network problems, or server-side errors.
    ///
    /// - Parameters:
    ///   - transactionId: Unique identifier for the failed transaction
    ///   - error: Detailed error information including code and message
    case protocolError(transactionId: String, error: MPThreeDSChallengeError)
    
    /// Runtime error occurred within the 3DS SDK.
    ///
    /// Runtime errors indicate system-level problems with the SDK itself,
    /// such as configuration issues, initialization failures, or internal errors.
    ///
    /// - Parameter error: Detailed error information including code and message
    case runtimeError(error: MPThreeDSChallengeError)
}

// MARK: - Convenience Properties

public extension MPThreeDSChallengeResult {
    /// Returns true if the authentication was successful.
    ///
    /// This is a convenience property that checks if the result is `.completed`
    /// with a transaction status of "Y" (successful authentication).
    var isSuccessful: Bool {
        if case .completed(let status, _) = self {
            return status == "Y"
        }
        return false
    }
    
    /// Returns the transaction ID if available.
    ///
    /// This property returns the transaction ID for completed challenges
    /// and protocol errors. Returns nil for other result types.
    var transactionId: String? {
        switch self {
        case .completed(_, let transactionId):
            return transactionId
        case .protocolError(let transactionId, _):
            return transactionId
        case .cancelled, .timedout, .runtimeError:
            return nil
        }
    }
    
    /// Returns the error if the result represents a failure.
    ///
    /// This property returns the error for protocol and runtime errors.
    /// Returns nil for successful completions, cancellations, and timeouts.
    var error: MPThreeDSChallengeError? {
        switch self {
        case .protocolError(_, let error), .runtimeError(let error):
            return error
        case .completed, .cancelled, .timedout:
            return nil
        }
    }
}
