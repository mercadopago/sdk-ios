//
//  MPThreeDSAuthenticated.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 17/07/25.
//

public struct MPThreeDSAuthenticated: Sendable {
    public let parameters: MPThreeDSAuthRequestParameters
    public var challengeParameters: MPThreeDSChallengeParameters?
    let transaction: ThreeDSTransactionProtocol
    
    public struct MPThreeDSChallengeParameters: Sendable {
        public var threeDSServerTransID: String
        public var acsReferenceNumber: String
        public var dsTransID: String
        public var acsTransID: String
        public var acsSignedContent: String 
    }
}
