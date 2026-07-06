//
//  CardFormInitializationResponse.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 18/03/26.
//
import Foundation

struct CardFormInitializationResponse: Codable {
    let identificationTypes: [IdentificationTypeDTO]
    let cardNumber: CardNumberConfig
    let securityCode: SecurityCodeConfig
    let holderName: HolderNameConfig
    let expirationDate: ExpirationDateConfig
    let translations: Translations
    let amount: Decimal?

    enum CodingKeys: String, CodingKey {
        case identificationTypes = "identification_types"
        case cardNumber = "card_number"
        case securityCode = "security_code"
        case holderName = "holder_name"
        case expirationDate = "expiration_date"
        case translations
        case amount
    }

    // MARK: - Identification Type DTO

    struct IdentificationTypeDTO: Codable {
        let id: String
        let name: String
        let minLength: Int
        let maxLength: Int
        let placeholder: String?
        let mask: String?
        let type: String?
        let sequence: String?

        enum CodingKeys: String, CodingKey {
            case id, name, type, placeholder, mask, sequence
            case minLength = "min_length"
            case maxLength = "max_length"
        }
    }

    // MARK: - Field Configs

    struct LengthRange: Codable {
        let min: Int
        let max: Int
    }

    struct CardNumberConfig: Codable {
        let type: String
        let length: LengthRange
        let mask: String
    }

    struct SecurityCodeConfig: Codable {
        let length: Int
        let type: String
    }

    struct HolderNameConfig: Codable {
        let type: String
        let length: LengthRange
    }

    struct ExpirationDateConfig: Codable {
        let type: String
        let mask: String
        let length: LengthRange
    }

    // MARK: - Translations

    struct Translations: Codable {
        let cardFormTitle: String
        let cardFormFooterButtonLabel: String
        let currencySymbol: String
        let cardNumber: FieldTranslation
        let holderName: FieldTranslation
        let expirationDate: FieldTranslation
        let securityCode: FieldTranslation
        let document: DocumentTranslation
        let installments: InstallmentsTranslation

        enum CodingKeys: String, CodingKey {
            case cardFormTitle = "card_form_title"
            case cardFormFooterButtonLabel = "card_form_footer_button_label"
            case currencySymbol = "currency_symbol"
            case cardNumber = "card_number"
            case holderName = "holder_name"
            case expirationDate = "expiration_date"
            case securityCode = "security_code"
            case document
            case installments
        }
    }

    struct FieldTranslation: Codable {
        let label: String
        let placeholder: String
        let helper: String
        let tooltip: String
        let errorEmptyField: String
        let errorIncompleteField: String
        let errorInvalidField: String

        enum CodingKeys: String, CodingKey {
            case label, placeholder, helper, tooltip
            case errorEmptyField = "error_empty_field"
            case errorIncompleteField = "error_incomplete_field"
            case errorInvalidField = "error_invalid_field"
        }
    }

    struct DocumentTranslation: Codable {
        let label: String
        let errorEmptyField: String
        let errorIncompleteField: String
        let errorInvalidField: String

        enum CodingKeys: String, CodingKey {
            case label
            case errorEmptyField = "error_empty_field"
            case errorIncompleteField = "error_incomplete_field"
            case errorInvalidField = "error_invalid_field"
        }
    }

    struct InstallmentsTranslation: Codable {
        let header: HeaderTranslation
        let totalLabel: String

        enum CodingKeys: String, CodingKey {
            case header
            case totalLabel = "total_label"
        }

        struct HeaderTranslation: Codable {
            let title: String
        }
    }
}
