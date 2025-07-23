//
//  ApplePayTokenBody.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 23/07/25.
//


import Foundation

struct ApplePayRequestBody: Encodable, Sendable {
    let paymentData: String

    enum CodingKeys: String, CodingKey {
        case paymentData = "paymentData"
    }
    
    /// Initializes the ApplePayTokenBody
    /// - Parameters:
    ///   - paymentData: Apple Payment Data
    init(paymentData: Data) {
        self.paymentData = paymentData.base64EncodedString()
    }
}
