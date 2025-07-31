//
//  CardTokenResponse.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 18/02/25.
//

struct CardTokenResponse: Codable, Sendable {
    let id: String
    let publicKey: String?
    let firstSixDigits: String?
    let expirationMonth: Int?
    let expirationYear: Int?
    let lastFourDigits: String?
    let cardholder: CardholderResponse?
    let status: String?
    let dateCreated: String?
    let dateLastUpdated: String?
    let dateDue: String?
    let luhnValidation: Bool?
    let liveMode: Bool?
    let requireEsc: Bool?
    let cardNumberLength: Int?
    let securityCodeLength: Int?
    let truncCardNumber: String?

    enum CodingKeys: String, CodingKey {
        case id
        case publicKey = "public_key"
        case firstSixDigits = "first_six_digits"
        case expirationMonth = "expiration_month"
        case expirationYear = "expiration_year"
        case lastFourDigits = "last_four_digits"
        case cardholder
        case status
        case dateCreated = "date_created"
        case dateLastUpdated = "date_last_updated"
        case dateDue = "date_due"
        case luhnValidation = "luhn_validation"
        case liveMode = "live_mode"
        case requireEsc = "require_esc"
        case cardNumberLength = "card_number_length"
        case securityCodeLength = "security_code_length"
        case truncCardNumber = "trunc_card_number"
    }
}

struct CardholderResponse: Codable, Sendable {
    let identification: IdentificationResponse?
    let name: String?
}

struct IdentificationResponse: Codable, Sendable {
    let type: String?
}
