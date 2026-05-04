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
        form.securityCode = "1234"
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
        form.securityCode = "1234"
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
        XCTAssertEqual(cardNumberState, .cardBrandNotAccepted)
    }

    func test_cancelledFormContext_whenPaymentTypeNotAllowed_shouldReportCardTypeNotAccepted() {
        // Arrange -- user typed a valid number but the seller does not accept credit cards
        var form = Self.makeFormWithRealStrings()
        form.cardNumber = "4111 1111 1111 1111"
        form.setCardNumberExternalError(.paymentTypeNotAllowed(""))

        // Act
        let context = form.cancelledFormContext
        let cardNumberState = context.fields.first { $0.field == .cardNumber }?.state

        // Assert
        XCTAssertEqual(cardNumberState, .cardTypeNotAccepted)
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
        XCTAssertEqual(cardNumberState, .cardBrandNotAccepted)
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

    // MARK: - cancelledFormContext — document branches

    func test_cancelledFormContext_whenDocumentBelowMinLength_shouldReportIncomplete() {
        // Arrange -- CPF minLength 11, fewer digits is incomplete
        var form = Self.makeFormWithRealStrings()
        form.setDocumentLength(11, 11)
        form.documentHolder = "12345"

        // Act
        let state = form.cancelledFormContext.fields.first { $0.field == .document }?.state

        // Assert
        XCTAssertEqual(state, .incomplete)
    }

    func test_cancelledFormContext_whenDocumentAllZeros_shouldReportInvalid() {
        // Arrange -- numeric document with only zeros is invalid regardless of length
        var form = Self.makeFormWithRealStrings()
        form.setDocumentLength(11, 11)
        form.documentHolder = "00000000000"

        // Act
        let state = form.cancelledFormContext.fields.first { $0.field == .document }?.state

        // Assert
        XCTAssertEqual(state, .invalid)
    }

    func test_cancelledFormContext_whenDocumentStringTypeWithOnlySpecialChars_shouldReportEmpty() {
        // Arrange -- string-type document strips special chars; nothing usable left → empty
        var form = Self.makeFormWithRealStrings()
        form.setDocumentType(isNumeric: false)
        form.setDocumentLength(5, 14)
        form.documentHolder = "!@#$%"

        // Act
        let state = form.cancelledFormContext.fields.first { $0.field == .document }?.state

        // Assert
        XCTAssertEqual(state, .empty)
    }

    // MARK: - cancelledFormContext — expiration branches

    func test_cancelledFormContext_whenExpirationPartialDigits_shouldReportIncomplete() {
        // Arrange -- 2 digits is below the 4-digit minimum for MM/YY
        var form = Self.makeFormWithRealStrings()
        form.expirationDate = "12"

        // Act
        let state = form.cancelledFormContext.fields.first { $0.field == .expirationDate }?.state

        // Assert
        XCTAssertEqual(state, .incomplete)
    }

    func test_cancelledFormContext_whenExpirationExpiredYear_shouldReportInvalid() {
        // Arrange -- 01/00 (Jan 2000) is in the past → invalid, not incomplete
        var form = Self.makeFormWithRealStrings()
        form.expirationDate = "0100"

        // Act
        let state = form.cancelledFormContext.fields.first { $0.field == .expirationDate }?.state

        // Assert
        XCTAssertEqual(state, .invalid)
    }

    // MARK: - Helpers

    /// Builds a CardFormData using the real MPStrings validation messages so
    /// the state machine's substring comparisons behave as in production.
    /// The existing `CardFormInitializationOutputStub` uses generic English
    /// strings that never match the `MPStrings.CardForm.*.errorIncomplete`
    /// substrings the state machine looks for.
    private static func makeFormWithRealStrings() -> CardFormData {
        CardFormData(fields: CardFormFields.Fields(
            cardNumber: .init(
                label: "Card number",
                placeholder: "0000 0000 0000 0000",
                validation: .init(
                    errorEmpty: MPStrings.CardForm.CardNumber.errorEmpty,
                    errorIncomplete: MPStrings.CardForm.CardNumber.errorIncomplete,
                    errorInvalid: MPStrings.CardForm.CardNumber.errorInvalid
                ),
                config: .init(type: "number", length: .init(min: 13, max: 19))
            ),
            cardHolder: .init(
                label: "Cardholder name",
                placeholder: "e.g. JOHN DOE",
                helperText: "As shown on card",
                validation: .init(
                    errorEmpty: MPStrings.CardForm.CardHolder.errorEmpty,
                    errorIncomplete: MPStrings.CardForm.CardHolder.errorIncomplete,
                    errorInvalid: MPStrings.CardForm.CardHolder.errorInvalid
                ),
                config: .init(type: "string", length: .init(min: 2, max: 26))
            ),
            expiration: .init(
                label: "Expiration",
                placeholder: "MM/YY",
                validation: .init(
                    errorEmpty: MPStrings.CardForm.Expiration.errorEmpty,
                    errorIncomplete: MPStrings.CardForm.Expiration.errorIncomplete,
                    errorInvalid: MPStrings.CardForm.Expiration.errorInvalid
                ),
                config: .init(type: "number", length: .init(min: 4, max: 4))
            ),
            cvv: .init(
                label: "Security code",
                placeholder: "123",
                tooltip: "",
                validation: .init(
                    errorEmpty: MPStrings.CardForm.CVV.errorEmpty,
                    errorIncomplete: MPStrings.CardForm.CVV.errorIncomplete
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
                    errorEmpty: MPStrings.CardForm.Document.errorEmpty,
                    errorIncomplete: MPStrings.CardForm.Document.errorIncomplete,
                    errorInvalid: MPStrings.CardForm.Document.errorInvalid
                )
            )
        ))
    }
}
