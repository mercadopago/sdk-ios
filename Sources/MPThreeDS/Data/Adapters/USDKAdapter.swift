//
//  USDKAdapter.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 21/07/25.
//

import Foundation
@preconcurrency import uSDK

final class USDKAdapter: ThreeDSSDKProtocol {
    
    func initialize(
        config: ThreeDSConfig,
        locale: String,
        completion: @escaping (Error?) -> Void
    ) {
        UThreeDS2ServiceImpl.shared().u_initialize(
            UConfigParameters(),
            locale: locale,
            uiCustomization: config.customization,
            completion: completion
        )
    }
    
    func createTransaction(
        directoryServerId: String,
        messageVersion: String
    ) -> ThreeDSTransactionProtocol? {
        guard let transaction = UThreeDS2ServiceImpl.shared().createTransaction(
            directoryServerId,
            messageVersion: messageVersion
        ) else {
            return nil
        }
        return UTransactionAdapter(transaction: transaction)
    }
}

// MARK: - Adapter for UTransaction
final class UTransactionAdapter: ThreeDSTransactionProtocol {
    private let transaction: UTransaction
    
    init(transaction: UTransaction) {
        self.transaction = transaction
    }
    
    var id: String {
        return transaction.description
    }
    
    func getAuthenticationRequestParameters() -> ThreeDSAuthRequestParameters? {
        guard let params = transaction.getAuthenticationRequestParameters() else {
            return nil
        }
        
        return ThreeDSAuthRequestParameters(
            sdkAppId: params.getSDKAppID(),
            deviceData: params.getDeviceData(),
            sdkEphemeralPublicKey: params.getSDKEphemeralPublicKey(),
            sdkReferenceNumber: params.getSDKReferenceNumber(),
            sdkTransactionId: params.getSDKTransactionID()
        )
    }
    
    func doChallenge(
        _ navigationController: UINavigationController,
        challengeParameters: ThreeDSChallengeParameters,
        challengeStatusReceiver: ThreeDSChallengeStatusReceiver,
        timeOut: Int32
    ) {
        let uChallengeParams = UChallengeParameters(
            threeDSServerTransactionID: challengeParameters.threeDSServerTransactionID,
            acsTransactionID: challengeParameters.acsTransactionID,
            acsRefNumber: challengeParameters.acsRefNumber,
            acsSignedContent: challengeParameters.acsSignedContent
        )
        
        let statusReceiver = UChallengeStatusReceiverAdapter(receiver: challengeStatusReceiver)
        
        transaction.doChallenge(
            navigationController,
            challengeParameters: uChallengeParams,
            challengeStatusReceiver: statusReceiver,
            timeOut: timeOut
        )
    }
}

// MARK: - Adapter for UChallengeStatusReceiver
final class UChallengeStatusReceiverAdapter: NSObject, UChallengeStatusReceiver {
    private weak var receiver: ThreeDSChallengeStatusReceiver?
    
    init(receiver: ThreeDSChallengeStatusReceiver) {
        self.receiver = receiver
    }
    
    func completed(_ completionEvent: UCompletionEvent) {
        receiver?.completed(
            transactionStatus: completionEvent.getTransactionStatus(),
            transactionId: completionEvent.getSDKTransactionID()
        )
    }
    
    func cancelled() {
        receiver?.cancelled()
    }
    
    func timedout() {
        receiver?.timedout()
    }
    
    func protocolError(_ protocolErrorEvent: UProtocolErrorEvent) {
        let errorMessage = protocolErrorEvent.getErrorMessage()
        receiver?.protocolError(
            transactionId: protocolErrorEvent.getSDKTransactionID(),
            code: errorMessage.getErrorCode(),
            message: errorMessage.getErrorDescription(),
            detail: errorMessage.getErrorDetails()
        )
    }
    
    func runtimeError(_ runtimeErrorEvent: URuntimeErrorEvent) {
        receiver?.runtimeError(
            code: runtimeErrorEvent.getErrorCode(),
            message: runtimeErrorEvent.getErrorMessage()
        )
    }
} 
