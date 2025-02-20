//
//  CardTokenBody.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 18/02/25.
//
import Foundation

struct CardTokenBody: Codable {
    let cardNumber: String?
    let expirationMonth: String?
    let expirationYear: String?
    let securityCode: String

    var cardId: String? = nil
    var esc: String? = nil
    var requireEsc = false
    var buyerIdentification: BuyerIdentification? = nil
}

extension CardTokenBody {
    /// Converts the `CardTokenBody` data to JSON format for use in a request body.
    ///
    /// - Returns: A `Data` object representing the post data in JSON format, or `nil` if the conversion fails.
    func toJSONData() -> Data? {
        let jsonObject: [String: Any] = [
            "card_number": cardNumber as Any,
            "expiration_month": expirationMonth ?? "",
            "expiration_year": expirationYear ?? "",
            "securityCode": securityCode,
            "card_id": cardId as Any,
            "esc": esc as Any,
            "require_esc": requireEsc,
            "buyer_identification": buyerIdentification as Any
        ]
        return try? JSONSerialization.data(withJSONObject: jsonObject, options: [])
    }
}

struct BuyerIdentification: Codable {
    let name: String
    let number: String
    let type: String
}
