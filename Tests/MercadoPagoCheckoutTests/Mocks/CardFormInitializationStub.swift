//
//  CardFormInitializationStub.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 16/03/26.
//

@testable import CoreMethods
@testable import MercadoPagoCheckout

// MARK: - Input (CardFormInitializationInput - Repository → UseCase)

enum CardFormInitializationInputStub {
    static func makeDefaultFields() -> CardFormFields.Fields {
        .init(
            cardNumber: .init(
                label: "Card number",
                placeholder: "0000 0000 0000 0000",
                validation: .init(
                    errorEmpty: "Enter a card number",
                    errorIncomplete: "Card number is incomplete",
                    errorInvalid: "Card number is invalid",
                    errorMethodNotAllowed: "%@ is not accepted",
                    errorTypeNotAllowed: "%@ cards are not accepted"
                ),
                config: .init(type: "number", length: .init(min: 13, max: 19))
            ),
            cardHolder: .init(
                label: "Cardholder name",
                placeholder: "e.g. JOHN DOE",
                helperText: "As shown on card",
                validation: .init(
                    errorEmpty: "Enter a name",
                    errorIncomplete: "Name is too short",
                    errorInvalid: "Invalid characters"
                ),
                config: .init(type: "string", length: .init(min: 2, max: 26))
            ),
            expiration: .init(
                label: "Expiration",
                placeholder: "MM/YY",
                validation: .init(
                    errorEmpty: "Enter expiration",
                    errorIncomplete: "Expiration incomplete",
                    errorInvalid: "Expiration invalid"
                ),
                config: .init(type: "number", length: .init(min: 4, max: 5))
            ),
            cvv: .init(
                label: "Security code",
                placeholder: "123",
                tooltip: "",
                validation: .init(
                    errorEmpty: "Enter security code",
                    errorIncomplete: "Security code incomplete"
                ),
                config: .init(type: "number", length: .init(min: 3, max: 4))
            ),
            issuer: .init(
                label: "Issuer",
                placeholder: "Select issuer"
            ),
            document: .init(
                label: "Document",
                placeholder: "Enter document",
                validation: .init(
                    errorEmpty: "Enter document",
                    errorIncomplete: "Document incomplete",
                    errorInvalid: "Document invalid"
                )
            )
        )
    }
}

// MARK: - Output (CardFormInitializationOutput - UseCase output)

enum CardFormInitializationOutputStub {
    static func make(identificationTypes: [IdentificationType] = []) -> CardFormInitializationOutput {
        CardFormInitializationOutput(
            title: "Default Header",
            button: "Save",
            fields: Self.makeDefaultFields(),
            identificationTypes: identificationTypes
        )
    }

    static func makeDefaultFields() -> CardFormFields.Fields {
        .init(
            cardNumber: .init(
                label: "Card number",
                placeholder: "0000 0000 0000 0000",
                validation: .init(
                    errorEmpty: "Enter a card number",
                    errorIncomplete: "Card number is incomplete",
                    errorInvalid: "Card number is invalid",
                    errorMethodNotAllowed: "%@ is not accepted",
                    errorTypeNotAllowed: "%@ cards are not accepted"
                ),
                config: .init(type: "number", length: .init(min: 13, max: 19))
            ),
            cardHolder: .init(
                label: "Cardholder name",
                placeholder: "e.g. JOHN DOE",
                helperText: "As shown on card",
                validation: .init(
                    errorEmpty: "Enter a name",
                    errorIncomplete: "Name is too short",
                    errorInvalid: "Invalid characters"
                ),
                config: .init(type: "string", length: .init(min: 2, max: 26))
            ),
            expiration: .init(
                label: "Expiration",
                placeholder: "MM/YY",
                validation: .init(
                    errorEmpty: "Enter expiration",
                    errorIncomplete: "Expiration incomplete",
                    errorInvalid: "Expiration invalid"
                ),
                config: .init(type: "number", length: .init(min: 4, max: 5))
            ),
            cvv: .init(
                label: "Security code",
                placeholder: "123",
                tooltip: "",
                validation: .init(
                    errorEmpty: "Enter security code",
                    errorIncomplete: "Security code incomplete"
                ),
                config: .init(type: "number", length: .init(min: 3, max: 4))
            ),
            issuer: .init(
                label: "Issuer",
                placeholder: "Select issuer"
            ),
            document: .init(
                label: "Document",
                placeholder: "Enter document",
                validation: .init(
                    errorEmpty: "Enter document",
                    errorIncomplete: "Document incomplete",
                    errorInvalid: "Document invalid"
                )
            )
        )
    }
}
