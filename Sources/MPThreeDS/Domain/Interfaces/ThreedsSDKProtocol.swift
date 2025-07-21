//
//  ThreedsSDKProtocol.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 21/07/25.
//

import UIKit
@_exported import uSDK

public protocol ThreeDSTransactionProtocol: Sendable {
    var id: String { get }
    func getAuthenticationRequestParameters() -> ThreeDSAuthRequestParameters?
    func doChallenge(
        _ navigationController: UINavigationController,
        challengeParameters: ThreeDSChallengeParameters,
        challengeStatusReceiver: ThreeDSChallengeStatusReceiver,
        timeOut: Int32
    )
}

public protocol ThreeDSSDKProtocol {
    func initialize(
        config: ThreeDSConfig,
        locale: String,
        completion: @escaping (Error?) -> Void
    )
    
    func createTransaction(
        directoryServerId: String,
        messageVersion: String
    ) -> ThreeDSTransactionProtocol?
}

public protocol ThreeDSChallengeStatusReceiver: AnyObject {
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

public struct ThreeDSAuthRequestParameters {
    public let sdkAppId: String
    public let deviceData: String
    public let sdkEphemeralPublicKey: String
    public let sdkReferenceNumber: String
    public let sdkTransactionId: String
}

public struct ThreeDSChallengeParameters {
    public let threeDSServerTransactionID: String
    public let acsTransactionID: String
    public let acsRefNumber: String
    public let acsSignedContent: String
} 
