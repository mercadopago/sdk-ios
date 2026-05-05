//
//  CardFormFields.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 16/03/26.
//

enum CardFormFields: Equatable {
    struct Fields: Equatable {
        let cardNumber: CardNumberField
        let cardHolder: CardHolderField
        let expiration: ExpirationField
        let cvv: CVVField
        let issuer: IssuerField
        let document: DocumentField
    }

    struct CardNumberField: Equatable {
        let label: String
        let placeholder: String
        let validation: Validation
        let config: CardFieldConfig

        struct Validation: Equatable {
            let errorEmpty: String
            let errorIncomplete: String
            let errorInvalid: String
        }
    }

    struct CardHolderField: Equatable {
        let label: String
        let placeholder: String
        let helperText: String
        let validation: Validation
        let config: CardFieldConfig

        struct Validation: Equatable {
            let errorEmpty: String
            let errorIncomplete: String
            let errorInvalid: String
        }
    }

    struct ExpirationField: Equatable {
        let label: String
        let placeholder: String
        let validation: Validation
        let config: CardFieldConfig

        struct Validation: Equatable {
            let errorEmpty: String
            let errorIncomplete: String
            let errorInvalid: String
        }
    }

    struct CVVField: Equatable {
        let label: String
        let placeholder: String
        let tooltip: String
        let validation: Validation
        let config: CardFieldConfig

        struct Validation: Equatable {
            let errorEmpty: String
            let errorIncomplete: String
            let errorInvalid: String
        }
    }

    struct IssuerField: Equatable {
        let label: String
        let placeholder: String
    }

    struct DocumentField: Equatable {
        let label: String
        let placeholder: String
        let validation: Validation

        struct Validation: Equatable {
            let errorEmpty: String
            let errorIncomplete: String
            let errorInvalid: String
        }
    }
}
