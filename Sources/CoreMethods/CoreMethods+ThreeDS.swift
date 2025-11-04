//
//  CoreMethods+ThreeDS.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 04/11/25.
//
import UIKit

extension CoreMethods {
    
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
    ///     var responseToken = try coreMethods.createToken(
    ///                          cardNumber: CardNumberTextField,
    ///                          expirationDate: ExpirationDateTextfield,
    ///                          securityCode: SecurityCodeTextField,
    ///                          cardHolderName: String?
    ///                         )
    ///
    ///     let challengeParametersFromBackend = requestServer(responseToken.token)
    ///
    ///     let challengeParameters = MPThreeDSChallengeParameters(
    ///                                 threeDSServerTransID: challengeParametersFromBackend.threeDSServerTransID ,
    ///                                 acsReferenceNumber: challengeParametersFromBackend.acsReferenceNumber
    ///                                 dsTransID: challengeParametersFromBackend.dsTransID
    ///                                 acsTransID: challengeParametersFromBackend.acsTransID
    ///                                 acsSignedContent: challengeParametersFromBackend.acsSignedContent
    ///                               )
    ///
    ///     let result = await coreMethods.startChallenge(
    ///         from: navigationController,
    ///         challengeParameters: challengeParameters
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
    ///
    @MainActor
    public func startChallenge(
        from navigationController: UINavigationController,
        challengeParameters: MPThreeDSChallengeParameters,
        timeOut: Int32 = 20
    ) async -> MPThreeDSChallengeResult {

        return await withCheckedContinuation { continuation in
            self.challengeContinuation = continuation

            self.transaction?.doChallenge(
                navigationController,
                challengeParameters: challengeParameters,
                challengeStatusReceiver: self,
                timeOut: timeOut
            )
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
        return threeDSSDK?.getWarnings() ?? []
    }
    
    /// The close method is called to clean up resources that are held by the Transaction object. It shall be called when the transaction is completed. The following are some examples of transaction completion events:
    ///
    /// - The Cardholder completes the challenge.
    /// - An error occurs
    /// - The Cardholder chooses to cancel the transaction.
    /// - The ACS recommends a challenge, but the Merchant overrides the recommendation and chooses to complete the transaction without a challenge
    @MainActor
    public func close() throws {
        try self.transaction?.close()
    }
}

@MainActor
extension CoreMethods: @preconcurrency ThreeDSChallengeStatusReceiver {

    func completed(transactionStatus: String, transactionId: String) {
        do {
            try self.transaction?.close()
        } catch {
            print("Error for closing transaction: \(error)")
        }

        let result = MPThreeDSChallengeResult.completed(
            transactionStatus: transactionStatus,
            transactionId: transactionId
        )

        if let continuation = challengeContinuation {
            continuation.resume(returning: result)
            challengeContinuation = nil
        }

        challengeDelegate?.completed(
            transactionStatus: transactionStatus,
            transactionId: transactionId
        )
    }

    func cancelled() {
        do {
            try self.transaction?.close()
        } catch {
            print("Error for closing transaction: \(error)")
        }

        let result = MPThreeDSChallengeResult.cancelled

        if let continuation = challengeContinuation {
            continuation.resume(returning: result)
            challengeContinuation = nil
        }

        challengeDelegate?.cancelled()
    }

    func timedout() {
        do {
            try self.transaction?.close()
        } catch {
            print("Error for closing transaction: \(error)")
        }

        let result = MPThreeDSChallengeResult.timedout

        if let continuation = challengeContinuation {
            continuation.resume(returning: result)
            challengeContinuation = nil
        }

        challengeDelegate?.timedout()
    }

    @MainActor
    func protocolError(transactionId: String, code: String, message: String, detail: String?) {
        do {
            try self.transaction?.close()
        } catch {
            print("Error for closing transaction: \(error)")
        }

        let challengeError = MPThreeDSChallengeError(
            code: code,
            errorType: .protocolError,
            message: message,
            detail: detail
        )

        let result = MPThreeDSChallengeResult.protocolError(
            transactionId: transactionId,
            error: challengeError
        )

        if let continuation = challengeContinuation {
            continuation.resume(returning: result)
            challengeContinuation = nil
        }

        challengeDelegate?.protocolError(
            transactionId: transactionId,
            error: challengeError
        )
    }

    @MainActor
    func runtimeError(code: String, message: String) {
        let challengeError = MPThreeDSChallengeError(
            code: code,
            errorType: .runtimeError,
            message: message,
            detail: nil
        )

        let result = MPThreeDSChallengeResult.runtimeError(error: challengeError)

        if let continuation = challengeContinuation {
            continuation.resume(returning: result)
            challengeContinuation = nil
        }

        challengeDelegate?.runtimeError(error: challengeError)
    }
}
