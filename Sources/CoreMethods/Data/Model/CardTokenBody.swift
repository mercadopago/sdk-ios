//
//  CardTokenBody.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 18/02/25.
//
import Foundation

struct CardTokenBody: Codable {
    let cardNumber: String
    let expirationMonth: String
    let expirationYear: String
}

extension CardTokenBody {
    /// Converts the `CardTokenBody` data to JSON format for use in a request body.
    ///
    /// - Returns: A `Data` object representing the post data in JSON format, or `nil` if the conversion fails.
    func toJSONData() -> Data? {
        let jsonObject: [String: Any] = [
            "card_number": cardNumber,
            "expiration_month": expirationMonth,
            "expiration_year": expirationYear
        ]
        return try? JSONSerialization.data(withJSONObject: jsonObject, options: [])
    }
}
