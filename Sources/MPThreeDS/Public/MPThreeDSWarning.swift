//
//  MPThreeDSWarning.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 26/08/25.
//

public struct MPThreeDSWarning: Sendable {
    public let id: String
    public let message: String
    public let severity: Severity
    
    public enum Severity: Int, Sendable {
        case low
        case medium
        case high
        case none
    }
}
