//
//  ThreeDSBody.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 23/07/25.
//


import Foundation

struct ApplePayTokenBody: Sendable {
    let paymentData: String

    /// Initializes the ApplePayTokenBody
    /// - Parameters:
    ///   - paymentData: Apple Payment Data
    init(
        paymentData: Data,
    ) {
        self.paymentData = paymentData.base64EncodedString()
    }
}

extension ApplePayTokenBody {
    /// Converts the `ApplePayTokenBody` data to JSON format for use in a request body.
    ///
    /// - Returns: A `Data` object representing the post data in JSON format, or `nil` if the conversion fails.
    func toJSONData() -> Data? {
        let jsonObject: [String: Any] = [
            "paymentData": token
        ]

        return try? JSONSerialization.data(withJSONObject: jsonObject, options: [])
    }
}
