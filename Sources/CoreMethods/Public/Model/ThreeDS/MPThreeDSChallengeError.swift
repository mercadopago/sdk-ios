//
//  MPThreeDSChallengeError.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 21/07/25.
//

import Foundation

/// Error information for 3D Secure challenge failures.
///
/// Encapsulates detailed error information when a 3DS challenge encounters problems.
/// These errors are typically received through the ``MPThreeDSChallengeDelegate``
/// and provide specific error codes and messages for debugging and user feedback.
///
/// ## Error Handling
/// ```swift
/// extension MyViewController: MPThreeDSChallengeDelegate {
///     func protocolError(transactionId: String, error: MPThreeDSChallengeError) {
///         switch error.errorType {
///         case .protocolError:
///             logger.error("3DS Protocol Error: \(error.message ?? "Unknown")")
///         case .runtimeError:
///             logger.error("3DS Runtime Error: \(error.message ?? "Unknown")")
///         }
///     }
/// }
/// ```
public final class MPThreeDSChallengeError: Sendable {
    /// Error code identifying the specific type of failure.
    ///
    /// Standard error codes as defined by the 3DS specification.
    /// Use this for programmatic error handling and logging.
    public let code: String
    
    /// Human-readable error message describing the failure.
    ///
    /// May be nil for some error types. When available, provides
    /// detailed information about what caused the error.
    public let message: String?
    
    /// Additional error details and context.
    ///
    /// Optional detailed information that may help with debugging
    /// or provide additional context about the error.
    public let detail: String?
    
    /// Category of the error that occurred.
    ///
    /// Indicates whether this is a protocol-level error or runtime error,
    /// which determines the appropriate handling strategy.
    public let errorType: MPThreeDSChallengeErrorType
    
    /// Initializes a new challenge error.
    ///
    /// - Parameters:
    ///   - code: Error code from the 3DS system
    ///   - errorType: Category of error that occurred  
    ///   - message: Optional human-readable error description
    ///   - detail: Optional additional error context
    init(
        code: String,
        errorType: MPThreeDSChallengeErrorType,
        message: String?,
        detail: String?
    ) {
        self.code = code
        self.message = message
        self.detail = detail
        self.errorType = errorType
    }
}

/// Categories of errors that can occur during 3D Secure challenges.
///
/// Differentiates between protocol-level errors (issues with 3DS communication)
/// and runtime errors (SDK or system-level issues).
public enum MPThreeDSChallengeErrorType: Sendable {
    /// Protocol-level error in 3DS communication.
    ///
    /// Indicates an error in the 3DS protocol communication between
    /// the SDK and the Access Control Server (ACS). These errors
    /// are typically related to invalid data, network issues, or
    /// protocol violations.
    case protocolError
    
    /// Runtime error within the 3DS SDK.
    ///
    /// Indicates a system-level error in the 3DS SDK operation,
    /// such as initialization failures, configuration issues,
    /// or internal SDK problems.
    case runtimeError
}
