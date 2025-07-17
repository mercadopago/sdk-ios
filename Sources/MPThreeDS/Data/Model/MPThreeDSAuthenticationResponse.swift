//
//  MPThreeDSAuthentication.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 17/07/25.
//


public struct MPThreeDSAuthenticationResponse: Codable, Sendable {
    public var response: String // NOAUTHORIZED / CHALLENGE
    public var threeDSServerTransID: String
    public var acsReferenceNumber: String
    public var dsTransID: String
    public var acsTransID: String
    public var acsSignedContent: String
}
