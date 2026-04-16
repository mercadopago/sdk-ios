//
//  CardFormFields.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 16/03/26.
//

enum CardFormFields {
    struct Fields {
        let cardNumber: CardNumberField
        let cardHolder: CardHolderField
        let expiration: ExpirationField
        let cvv: CVVField
        let issuer: IssuerField
        let document: DocumentField
    }

    struct CardNumberField {
        let label: String
        let placeholder: String
        let validation: Validation
        let config: CardFieldConfig

        struct Validation {
            let errorEmpty: String
            let errorIncomplete: String
            let errorInvalid: String
            let errorMethodNotAllowed: String
            let errorTypeNotAllowed: String
        }
    }

    struct CardHolderField {
        let label: String
        let placeholder: String
        let helperText: String
        let validation: Validation
        let config: CardFieldConfig

        struct Validation {
            let errorEmpty: String
            let errorIncomplete: String
            let errorInvalid: String
        }
    }

    struct ExpirationField {
        let label: String
        let placeholder: String
        let validation: Validation
        let config: CardFieldConfig

        struct Validation {
            let errorEmpty: String
            let errorIncomplete: String
            let errorInvalid: String
        }
    }

    struct CVVField {
        let label: String
        let placeholder: String
        let tooltip: String
        let validation: Validation
        let config: CardFieldConfig

        struct Validation {
            let errorEmpty: String
            let errorIncomplete: String
        }
    }

    struct IssuerField {
        let label: String
        let placeholder: String
    }

    struct DocumentField {
        let label: String
        let placeholder: String
        let validation: Validation

        struct Validation {
            let errorEmpty: String
            let errorIncomplete: String
            let errorInvalid: String
        }
    }
}
