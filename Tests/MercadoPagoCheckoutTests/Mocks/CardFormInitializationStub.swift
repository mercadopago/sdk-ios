//
//  CardFormInitializationStub.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 16/03/26.
//

@testable import MercadoPagoCheckout

// MARK: - Input (CardFormInitializationInput - Repository → UseCase)

enum CardFormInitializationInputStub {
    static func makeDefaultFields() -> CardFormTexts.Fields {
        .init(
            cardNumber: .init(
                label: "Card number",
                placeholder: "0000 0000 0000 0000",
                validation: .init(
                    errorEmpty: "Enter a card number",
                    errorIncomplete: "Card number is incomplete",
                    errorInvalid: "Card number is invalid",
                    errorSellerExclusion: "%@ is not accepted",
                    errorTypeNotAllowed: "%@ cards are not accepted"
                )
            ),
            cardHolder: .init(
                label: "Cardholder name",
                placeholder: "e.g. JOHN DOE",
                helperText: "As shown on card",
                validation: .init(
                    errorEmpty: "Enter a name",
                    errorIncomplete: "Name is too short",
                    errorInvalidFormat: "Invalid characters"
                )
            ),
            expiration: .init(
                label: "Expiration",
                placeholder: "MM/YY",
                validation: .init(
                    errorEmpty: "Enter expiration",
                    errorIncomplete: "Expiration incomplete",
                    errorInvalid: "Expiration invalid"
                )
            ),
            cvv: .init(
                label: "Security code",
                placeholderDefault: "123",
                placeholderAmex: "1234",
                validation: .init(
                    errorEmpty: "Enter security code",
                    errorIncomplete: "Security code incomplete"
                )
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
    static func makeDefaultFields() -> CardFormTexts.Fields {
        .init(
            cardNumber: .init(
                label: "Card number",
                placeholder: "0000 0000 0000 0000",
                validation: .init(
                    errorEmpty: "Enter a card number",
                    errorIncomplete: "Card number is incomplete",
                    errorInvalid: "Card number is invalid",
                    errorSellerExclusion: "%@ is not accepted",
                    errorTypeNotAllowed: "%@ cards are not accepted"
                )
            ),
            cardHolder: .init(
                label: "Cardholder name",
                placeholder: "e.g. JOHN DOE",
                helperText: "As shown on card",
                validation: .init(
                    errorEmpty: "Enter a name",
                    errorIncomplete: "Name is too short",
                    errorInvalidFormat: "Invalid characters"
                )
            ),
            expiration: .init(
                label: "Expiration",
                placeholder: "MM/YY",
                validation: .init(
                    errorEmpty: "Enter expiration",
                    errorIncomplete: "Expiration incomplete",
                    errorInvalid: "Expiration invalid"
                )
            ),
            cvv: .init(
                label: "Security code",
                placeholderDefault: "123",
                placeholderAmex: "1234",
                validation: .init(
                    errorEmpty: "Enter security code",
                    errorIncomplete: "Security code incomplete"
                )
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
