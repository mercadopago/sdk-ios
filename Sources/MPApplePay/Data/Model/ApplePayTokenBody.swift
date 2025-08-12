//
//  ApplePayTokenBody.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 23/07/25.
//
import Foundation
import PassKit

/// Request body for Apple Pay tokenization endpoint.
struct ApplePayRequestBody: Encodable, Sendable {
    let paymentMethod: PaymentMethod
    let transactionIdentifier: String

    enum CodingKeys: String, CodingKey {
        case paymentMethod = "payment_method"
        case transactionIdentifier = "transaction_identifier"
    }

    /// Nested payment method 
    struct PaymentMethod: Encodable, Sendable {
        let type: String
        let paymentData: String

        enum CodingKeys: String, CodingKey {
            case type
            case paymentData = "payment_data"
        }
    }

    /// Initializes the ApplePayRequestBody using PKPaymentToken.
    /// - Parameter paymentToken: The Apple Pay payment token.
    init(paymentToken: PKPaymentToken) {
        self.paymentMethod = PaymentMethod(
            type: "applepay",
            paymentData: paymentToken.paymentData.base64EncodedString()
        )
        self.transactionIdentifier = paymentToken.transactionIdentifier
    }
}
