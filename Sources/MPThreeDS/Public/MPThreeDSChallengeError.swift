//
//  MPThreeDSChallengeError.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 21/07/25.
//


import Foundation

@objc public class MPThreeDSChallengeError: NSObject {
    
    public let code: String
    public let message: String?
    public let detail: String?
    public let errorType: MPThreeDSChallengeErrorType
    
    init(
        code: String,
        errorType: MPThreeDSChallengeErrorType,
        message: String?,
        detail: String?
    ) {
        self.code = code
        self.message = message
        self.detail = detail
        self.errorType = errorType
    }
}

public enum MPThreeDSChallengeErrorType {
    case protocolError
    case runtimeError
}
