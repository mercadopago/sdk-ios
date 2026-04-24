//
//  CardFormDataTests.swift
//  MercadoPagoSDK
//
//  Created by SDK on 06/03/26.
//

@testable import MercadoPagoCheckout
@testable import MPFoundation
import XCTest

final class CardFormDataTests: XCTestCase {
    // MARK: - isFormValid

    func test_isFormValid_whenAllFieldsValid_shouldReturnTrue() {
        // Arrange
        var form = CardFormData(fields: CardFormInitializationOutputStub.makeDefaultFields())
        form.cardNumber = "4111111111111111"
        form.cardHolder = "John Doe"
        form.expirationDate = "0130"
        form.securityCode = "123"
        form.documentHolder = "12345678901"

        // Assert
        XCTAssertTrue(form.isFormValid(isSecurityCodeMandatory: true))
    }

    func test_isFormValid_whenSecurityCodeEmptyAndMandatory_shouldReturnFalse() {
        // Arrange
        var form = CardFormData(fields: CardFormInitializationOutputStub.makeDefaultFields())
        form.cardNumber = "4111111111111111"
        form.cardHolder = "John Doe"
        form.expirationDate = "0130"
        // securityCode stays empty (default "")
        form.documentHolder = "12345678901"

        // Assert
        XCTAssertFalse(form.isFormValid(isSecurityCodeMandatory: true))
    }

    func test_isFormValid_whenSecurityCodeNotMandatory_withEmptyCode_shouldReturnTrue() {
        // Arrange
        var form = CardFormData(fields: CardFormInitializationOutputStub.makeDefaultFields())
        form.cardNumber = "4111111111111111"
        form.cardHolder = "John Doe"
        form.expirationDate = "0130"
        // securityCode stays empty (default "")
        form.documentHolder = "12345678901"

        // Assert
        XCTAssertTrue(form.isFormValid(isSecurityCodeMandatory: false))
    }

    func test_isFormValid_whenSecurityCodeMandatory_withEmptyCode_shouldReturnFalse() {
        // Arrange
        var form = CardFormData(fields: CardFormInitializationOutputStub.makeDefaultFields())
        form.cardNumber = "4111111111111111"
        form.cardHolder = "John Doe"
        form.expirationDate = "0130"
        form.documentHolder = "12345678901"

        // Assert — empty security code is invalid when mandatory
        XCTAssertFalse(form.isFormValid(isSecurityCodeMandatory: true))
    }

    // MARK: - cancelledFormContext

    //
    // Covers the private field state-machine — how each validation error maps
    // to the public `CardFormUserCancelledContext.FieldState.State` cases
    // (.valid/.empty/.incomplete/.invalid/.cardBrandNotAccepted/.cardTypeNotAccepted).
    // This is the state the SDK reports to the seller on cancel, so drift
    // here is a silent regression in seller-visible behavior.
    //
    // The state machine compares validation error messages against `MPStrings`
    // directly, so these tests build the form with real `MPStrings` strings
    // via `makeFormWithRealStrings()` instead of the generic stub.

    func test_cancelledFormContext_whenAllFieldsValid_shouldReportEveryFieldValid() {
        // Arrange
        var form = Self.makeFormWithRealStrings()
        form.cardNumber = "4111 1111 1111 1111"
        form.cardHolder = "Maria Lopez"
        form.expirationDate = "1230" // MM=12, YY=30 (future)
        form.securityCode = "123"
        form.documentHolder = "12345678901"

        // Act
        let context = form.cancelledFormContext

        // Assert
        for fieldState in context.fields {
            XCTAssertEqual(fieldState.state, .valid, "field \(fieldState.field) should be valid")
        }
    }

    func test_cancelledFormContext_whenAllFieldsEmpty_shouldReportEveryFieldEmpty() {
        // Arrange -- defaults to "" everywhere
        let form = Self.makeFormWithRealStrings()

        // Act
        let context = form.cancelledFormContext

        // Assert
        for fieldState in context.fields {
            XCTAssertEqual(fieldState.state, .empty, "field \(fieldState.field) should be empty")
        }
    }

    // MARK: - cancelledFormContext — external errors on card number (seller exclusions)

    func test_cancelledFormContext_whenPaymentMethodNotAllowed_shouldReportCardBrandNotAccepted() {
        // Arrange -- user typed a valid Visa number but the seller does not accept Visa
        var form = Self.makeFormWithRealStrings()
        form.cardNumber = "4111 1111 1111 1111"
        form.setCardNumberExternalError(.paymentMethodNotAllowed("visa"))

        // Act
        let context = form.cancelledFormContext
        let cardNumberState = context.fields.first { $0.field == .cardNumber }?.state

        // Assert
        XCTAssertEqual(cardNumberState, .cardBrandNotAccepted(brand: .visa))
    }

    func test_cancelledFormContext_whenPaymentTypeNotAllowed_shouldReportCardTypeNotAccepted() {
        // Arrange -- user typed a valid number but the seller does not accept credit cards
        var form = Self.makeFormWithRealStrings()
        form.cardNumber = "4111 1111 1111 1111"
        form.setCardNumberExternalError(.paymentTypeNotAllowed(.credit))

        // Act
        let context = form.cancelledFormContext
        let cardNumberState = context.fields.first { $0.field == .cardNumber }?.state

        // Assert
        XCTAssertEqual(cardNumberState, .cardTypeNotAccepted(cardType: .credit))
    }

    func test_cancelledFormContext_whenCustomBrandNotAllowed_shouldPreserveCustomIdentifier() {
        // Arrange -- unknown brand id should round-trip through CardBrand.custom
        var form = Self.makeFormWithRealStrings()
        form.cardNumber = "4111 1111 1111 1111"
        form.setCardNumberExternalError(.paymentMethodNotAllowed("sodexo"))

        // Act
        let context = form.cancelledFormContext
        let cardNumberState = context.fields.first { $0.field == .cardNumber }?.state

        // Assert
        XCTAssertEqual(cardNumberState, .cardBrandNotAccepted(brand: .custom("sodexo")))
    }

    // MARK: - cancelledFormContext — incomplete vs invalid disambiguation

    func test_cancelledFormContext_whenCardHolderIncomplete_shouldReportIncomplete() {
        // Arrange -- 1 char: passes "not empty", fails CardHolderRule's 3-char minimum
        var form = Self.makeFormWithRealStrings()
        form.cardHolder = "A"

        // Act
        let context = form.cancelledFormContext
        let state = context.fields.first { $0.field == .cardHolder }?.state

        // Assert
        XCTAssertEqual(state, .incomplete)
    }

    func test_cancelledFormContext_whenCardHolderHasSpecialChars_shouldReportInvalid() {
        // Arrange -- "@" is neither letter/digit/space → CardHolderRule returns errorInvalid
        var form = Self.makeFormWithRealStrings()
        form.cardHolder = "Maria @ Lopez"

        // Act
        let context = form.cancelledFormContext
        let state = context.fields.first { $0.field == .cardHolder }?.state

        // Assert
        XCTAssertEqual(state, .invalid)
    }

    func test_cancelledFormContext_whenExpirationInvalidMonth_shouldReportInvalid() {
        // Arrange -- 13/30: all 4 digits present (not incomplete) but month 13 is invalid
        var form = Self.makeFormWithRealStrings()
        form.expirationDate = "1330"

        // Act
        let context = form.cancelledFormContext
        let state = context.fields.first { $0.field == .expirationDate }?.state

        // Assert
        XCTAssertEqual(state, .invalid)
    }

    func test_cancelledFormContext_whenSecurityCodeIncomplete_shouldReportIncomplete() {
        // Arrange
        var form = Self.makeFormWithRealStrings()
        form.securityCode = "12"

        // Act
        let context = form.cancelledFormContext
        let state = context.fields.first { $0.field == .securityCode }?.state

        // Assert
        XCTAssertEqual(state, .incomplete)
    }

    // MARK: - Helpers

    /// Builds a CardFormData using the real MPStrings validation messages so
    /// the state machine's substring comparisons behave as in production.
    /// The existing `CardFormInitializationOutputStub` uses generic English
    /// strings that never match the `MPStrings.CardForm.*.errorIncomplete`
    /// substrings the state machine looks for.
    private static func makeFormWithRealStrings() -> CardFormData {
        CardFormData(fields: CardFormTexts.Fields(
            cardNumber: .init(
                label: "Card number",
                placeholder: "0000 0000 0000 0000",
                validation: .init(
                    errorEmpty: MPStrings.CardForm.CardNumber.errorEmpty,
                    errorIncomplete: MPStrings.CardForm.CardNumber.errorIncomplete,
                    errorInvalid: MPStrings.CardForm.CardNumber.errorInvalid,
                    errorMethodNotAllowed: MPStrings.CardForm.CardNumber.errorMethodNotAllowed(brand: "%@"),
                    errorTypeNotAllowed: MPStrings.CardForm.CardNumber.errorTypeNotAllowed(cardType: "%@")
                )
            ),
            cardHolder: .init(
                label: "Cardholder name",
                placeholder: "e.g. JOHN DOE",
                helperText: "As shown on card",
                validation: .init(
                    errorEmpty: MPStrings.CardForm.CardHolder.errorEmpty,
                    errorIncomplete: MPStrings.CardForm.CardHolder.errorIncomplete,
                    errorInvalid: MPStrings.CardForm.CardHolder.errorInvalid
                )
            ),
            expiration: .init(
                label: "Expiration",
                placeholder: "MM/YY",
                validation: .init(
                    errorEmpty: MPStrings.CardForm.Expiration.errorEmpty,
                    errorIncomplete: MPStrings.CardForm.Expiration.errorIncomplete,
                    errorInvalid: MPStrings.CardForm.Expiration.errorInvalid
                )
            ),
            cvv: .init(
                label: "Security code",
                placeholderDefault: "123",
                placeholderAmex: "1234",
                validation: .init(
                    errorEmpty: MPStrings.CardForm.CVV.errorEmpty,
                    errorIncomplete: MPStrings.CardForm.CVV.errorIncomplete
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
                    errorEmpty: MPStrings.CardForm.Document.errorEmpty,
                    errorIncomplete: MPStrings.CardForm.Document.errorIncomplete,
                    errorInvalid: MPStrings.CardForm.Document.errorInvalid
                )
            )
        ))
    }
}
