//
//  MPThreeDSChallengeParameters.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 04/11/25.
//

public struct MPThreeDSChallengeParameters: Sendable {
    /// Challenge status
    public var status: ChallengeStatus
    
    /// ACS Reference Number assigned by the ACS to identify a single transaction.
    public var acsReferenceNumber: String
    
    /// Directory Server Transaction ID assigned by the Directory Server.
    public var dsTransID: String
    
    /// ACS Transaction ID assigned by the ACS.
    public var acsTransID: String
    
    /// ACS Signed Content contains the JWS object created by the ACS.
    public var acsSignedContent: String
    
    
    public enum ChallengeStatus: String, Sendable {
        case authenticated
        case challenge
    }
}
