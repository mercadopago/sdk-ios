//
//  MPThreeDSAuthenticated.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 17/07/25.
//

public struct MPThreeDSAuthenticated: Sendable {
    public let status: Status
    public let parameters: ThreeDSParameters
    public let transaction: ThreeDSTransactionProtocol
    
    public enum Status: Sendable {
        case notAuthorized
        case challenge
    }
    
    public struct ThreeDSParameters: Sendable {
        public var threeDSServerTransID: String
        public var acsReferenceNumber: String
        public var dsTransID: String
        public var acsTransID: String
        public var acsSignedContent: String
    }
}
