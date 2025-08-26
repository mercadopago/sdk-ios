//
//  ThreeDSAuthRequestParameters.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 26/08/25.
//

public struct MPThreeDSAuthRequestParameters: Sendable {
    public let sdkAppId: String
    public let deviceData: String
    public let sdkEphemeralPublicKey: String
    public let sdkReferenceNumber: String
    public let sdkTransactionId: String
}
