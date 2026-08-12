//
//  ApplePayTokenBody.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 23/07/25.
//
import Foundation
import PassKit

/// Request body for Apple Pay tokenization endpoint.
struct ApplePayRequestBody {
    let paymentMethod: PaymentMethod
    let transactionIdentifier: String
    let device: Data

    /// Nested payment method 
    struct PaymentMethod: Codable {
        let type: String
        let paymentData: String
    }

    /// Initializes the ApplePayRequestBody using PKPaymentToken.
    /// - Parameter paymentToken: The Apple Pay payment token.
    init(paymentToken: PKPaymentToken, device: Data) {
        self.paymentMethod = PaymentMethod(
            type: "applepay",
            paymentData: paymentToken.paymentData.base64EncodedString()
        )
        self.transactionIdentifier = paymentToken.transactionIdentifier
        self.device = device
    }
}


extension ApplePayRequestBody {
    /// Converts the `ApplePayRequestBody` data to JSON format for use in a request body.
    ///
    /// - Returns: A `Data` object representing the post data in JSON format, or `nil` if the conversion fails.
    func toJSONData() -> Data? {
        let payment: [String: String] = [
            "type": paymentMethod.type,
            "payment_data": paymentMethod.paymentData
        ]
        
        var jsonObject: [String: Any] = [
            "payment_method": payment as Any,
            "transaction_identifier": transactionIdentifier as Any,
        ]
        
        if let deviceObject = try? JSONSerialization.jsonObject(with: device, options: []) as? [String: Any] {
            jsonObject["device"] = deviceObject
        }

        return try? JSONSerialization.data(withJSONObject: jsonObject, options: [])
    }
}
