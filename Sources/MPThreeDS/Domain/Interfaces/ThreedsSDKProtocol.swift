//
//  ThreedsSDKProtocol.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 21/07/25.
//

import UIKit
import uSDK

protocol ThreeDSTransactionProtocol: Sendable {
    var id: String { get }
    func getAuthenticationRequestParameters() -> MPThreeDSAuthRequestParameters?
    func doChallenge(
        _ navigationController: UINavigationController,
        challengeParameters: MPThreeDSParameters.MPThreeDSChallengeParameters,
        challengeStatusReceiver: ThreeDSChallengeStatusReceiver,
        timeOut: Int32
    )
    
    func close() throws
}

protocol ThreeDSSDKProtocol {
    func initialize(
        config: ThreeDSConfig,
        locale: String,
        completion: @escaping (Error?) -> Void
    )
    
    func createTransaction(
        directoryServerId: String,
        messageVersion: String
    ) -> ThreeDSTransactionProtocol?
    
    func getWarnings() -> [MPThreeDSWarning]    
}

protocol ThreeDSChallengeStatusReceiver: AnyObject {
    func completed(transactionStatus: String, transactionId: String)
    func cancelled()
    func timedout()
    func protocolError(transactionId: String, code: String, message: String, detail: String?)
    func runtimeError(code: String, message: String)
}

public struct ThreeDSConfig {
    public var customization: UUiCustomization
    
    public init(customization: UUiCustomization = UUiCustomization()) {
        self.customization = customization
    }
}
