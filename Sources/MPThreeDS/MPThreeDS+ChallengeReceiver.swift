//
//  MPThreeDS+ChallengeReceiver.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 02/09/25.
//
import Foundation

extension MPThreeDS: ThreeDSChallengeStatusReceiver {

    func completed(transactionStatus: String, transactionId: String) {
        do {
            try parameters?.transaction.close()
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
            try parameters?.transaction.close()
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
            try parameters?.transaction.close()
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

    func protocolError(transactionId: String, code: String, message: String, detail: String?) {
        do {
            try parameters?.transaction.close()
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
