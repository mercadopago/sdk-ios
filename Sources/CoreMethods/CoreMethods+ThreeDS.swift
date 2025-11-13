//
//  CoreMethods+ThreeDS.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 04/11/25.
//
import UIKit

extension CoreMethods {
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
    
    @MainActor
    public func startChallenge(
        from navigationController: UINavigationController,
        capabilityID: String,
        timeOut: Int32 = 20
    ) async throws -> MPThreeDSChallengeResult {
        
        do {
            let challengeParameters = try await self.capabilityUseCase.getChallengeParameters(capabilityID)
            
            return await withCheckedContinuation { continuation in
                self.challengeContinuation = continuation

                self.transaction?.doChallenge(
                    navigationController,
                    challengeParameters: challengeParameters,
                    challengeStatusReceiver: self,
                    timeOut: timeOut
                )
            }

        } catch {
            throw error
        }
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
    
    @MainActor
    func createTransation(_ response: CardToken) async throws {
        guard let directoryServer = MPThreeDSDirectoryServer(rawValue: response.token) else {
            return
        }
        
        self.transaction = self.threeDSSDK?.createTransaction(
            directoryServerId: directoryServer.id,
            messageVersion: configuration.messageVersion
        )
        
        guard var parameters = self.transaction?.getAuthenticationRequestParameters() else{
            return
        }
                            
        parameters.token = response.token
        
        let _ = try await self.generateTokenUseCase.sendDeviceData(parameters)
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
