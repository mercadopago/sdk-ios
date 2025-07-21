//
//  MPThreeDSAuthenticated.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 17/07/25.
//
@preconcurrency import uSDK

public typealias MPThreeDSTransaction = UTransaction

public struct MPThreeDSAuthenticated: Sendable {
    public var status: Status
    public var parameters: ThreeDSParameters
    public var transaction: MPThreeDSTransaction
    
    public enum Status: Sendable {
        case noAuthorized
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
