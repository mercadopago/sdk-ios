//
//  CardFormInitializationResponse.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 18/03/26.
//

import CoreMethods

struct CardFormInitializationResponse: Decodable, Sendable {
    let identificationTypes: [IdentificationType]
    let translations: Translations
    let cardNumber: CardNumberConfig
    let securityCode: SecurityCodeConfig

    enum CodingKeys: String, CodingKey {
        case identificationTypes = "identification_types"
        case translations
        case cardNumber = "card_number"
        case securityCode = "security_code"
    }

    struct Translations: Decodable, Sendable {
        let cardFormTitle: String
        let cardNumberLabel: String
        let cardNumberPlaceholder: String
        let cardholderNameLabel: String
        let cardholderNamePlaceholder: String
        let cardholderNameHelper: String
        let expirationDateLabel: String
        let expirationDatePlaceholder: String
        let securityCodeLabel: String
        let securityCodePlaceholder: String
        let documentLabel: String
        let payButtonLabel: String

        enum CodingKeys: String, CodingKey {
            case cardFormTitle = "card_form_title"
            case cardNumberLabel = "card_number_label"
            case cardNumberPlaceholder = "card_number_placeholder"
            case cardholderNameLabel = "cardholder_name_label"
            case cardholderNamePlaceholder = "cardholder_name_placeholder"
            case cardholderNameHelper = "cardholder_name_helper"
            case expirationDateLabel = "expiration_date_label"
            case expirationDatePlaceholder = "expiration_date_placeholder"
            case securityCodeLabel = "security_code_label"
            case securityCodePlaceholder = "security_code_placeholder"
            case documentLabel = "document_label"
            case payButtonLabel = "pay_button_label"
        }
    }

    struct CardNumberConfig: Decodable, Sendable {
        let length: Int
        let mask: String
    }

    struct SecurityCodeConfig: Decodable, Sendable {
        let length: Int
    }
}
