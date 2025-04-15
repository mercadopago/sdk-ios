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

    var device: Data? = nil
}

extension CardTokenBody {
    /// Converts the `CardTokenBody` data to JSON format for use in a request body.
    ///
    /// - Returns: A `Data` object representing the post data in JSON format, or `nil` if the conversion fails.
    func toJSONData() -> Data? {
        var jsonObject: [String: Any] = [
            "card_number": cardNumber as Any,
            "expiration_month": expirationMonth ?? "",
            "expiration_year": expirationYear ?? "",
            "securityCode": securityCode,
            "card_id": cardId as Any,
            "esc": esc as Any,
            "require_esc": requireEsc
        ]

        if let buyerIdentification {
            let buyerDict: [String: Any] = [
                "name": buyerIdentification.name,
                "number": buyerIdentification.number,
                "type": buyerIdentification.type
            ]
            jsonObject["buyer_identification"] = buyerDict
        }

        if let deviceData = device,
           let deviceObject = try? JSONSerialization.jsonObject(with: deviceData, options: []) as? [String: Any] {
            jsonObject["device"] = deviceObject
        }

        return try? JSONSerialization.data(withJSONObject: jsonObject, options: [])
    }
}

struct BuyerIdentification: Codable {
    let name: String
    let number: String
    let type: String
}
