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
    let securityCode: String

    let cardId: String? = nil
    let esc: String? = nil
    let requireEsc = false
    let buyerIdentification: BuyerIdentification? = nil
}

extension CardTokenBody {
    /// Converts the `CardTokenBody` data to JSON format for use in a request body.
    ///
    /// - Returns: A `Data` object representing the post data in JSON format, or `nil` if the conversion fails.
    func toJSONData() -> Data? {
        let jsonObject: [String: Any] = [
            "card_number": cardNumber,
            "expiration_month": expirationMonth,
            "expiration_year": expirationYear,
            "securityCode": securityCode,
            "card_id": cardId,
            "esc": esc,
            "require_esc": requireEsc,
            "buyer_identification": buyerIdentification
        ]
        return try? JSONSerialization.data(withJSONObject: jsonObject, options: [])
    }
}

struct BuyerIdentification: Codable {
    let name: String
    let number: String
    let type: String
}
