//
//  CardFormTranslationsResponse.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 13/04/26.
//
//  Shared translations DTO used by card_payment_brick/initialization
//  and card_payment_brick/card endpoints.
//

struct CardFormTranslationsResponse: Codable {
    let cardFormTitle: String
    let cardFormFooterButtonLabel: String
    let cardNumber: FieldTranslationsData
    let holderName: FieldTranslationsData
    let expirationDate: FieldTranslationsData
    let securityCode: FieldTranslationsData?
    let document: DocumentTranslationsData
    let installments: InstallmentsTranslationsData

    enum CodingKeys: String, CodingKey {
        case cardFormTitle = "card_form_title"
        case cardFormFooterButtonLabel = "card_form_footer_button_label"
        case cardNumber = "card_number"
        case holderName = "holder_name"
        case expirationDate = "expiration_date"
        case securityCode = "security_code"
        case document
        case installments
    }

    struct FieldTranslationsData: Codable {
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

    struct DocumentTranslationsData: Codable {
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

    struct InstallmentsTranslationsData: Codable {
        let header: HeaderData
        let totalLabel: String
        let payButtonLabel: String

        enum CodingKeys: String, CodingKey {
            case header
            case totalLabel = "total_label"
            case payButtonLabel = "pay_button_label"
        }

        struct HeaderData: Codable {
            let title: String
        }
    }
}
