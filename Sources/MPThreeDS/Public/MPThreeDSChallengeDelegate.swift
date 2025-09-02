//
//  MPThreeDSChallengeDelegate.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 21/07/25.
//

import Foundation

/// Delegate protocol for receiving 3D Secure challenge result callbacks.
///
/// Implement this protocol to handle the various outcomes of a 3DS challenge flow.
/// Set your delegate on the ``MPThreeDS`` instance before calling 
/// ``MPThreeDS/startChallenge(from:data:timeOut:)`` to receive callbacks.
///
public protocol MPThreeDSChallengeDelegate: AnyObject {
    /// Called when the 3D Secure challenge completes successfully.
    ///
    func completed(transactionStatus: String, transactionId: String)
    
    /// Called when the user cancels the 3D Secure challenge.
    func cancelled()
    
    /// Called when the 3D Secure challenge times out.
    ///
    /// This occurs when the challenge exceeds the configured timeout period
    /// (default 20 seconds). The user may have abandoned the flow or
    /// experienced connectivity issues.
    func timedout()
    
    /// Called when a protocol error occurs during the challenge.
    ///
    /// Protocol errors indicate issues with 3DS communication, such as
    /// invalid responses, network problems, or server-side errors.
    /// These errors are recoverable and you may allow the user to retry.
    ///
    /// - Parameters:
    ///   - transactionId: Unique identifier for the failed transaction
    ///   - error: Detailed error information including code and message
    func protocolError(transactionId: String, error: MPThreeDSChallengeError)
    
    /// Called when a runtime error occurs within the 3DS SDK.
    ///
    /// Runtime errors indicate system-level problems with the SDK itself,
    /// such as configuration issues, initialization failures, or internal errors.
    /// These errors typically require technical intervention.
    ///
    /// - Parameter error: Detailed error information including code and message
    func runtimeError(error: MPThreeDSChallengeError)
}
