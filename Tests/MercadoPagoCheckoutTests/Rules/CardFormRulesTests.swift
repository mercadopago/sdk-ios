//
//  CardFormRulesTests.swift
//  MercadoPagoSDK
//
//  Created by SDK on 03/03/26.
//

@testable import MercadoPagoCheckout
@testable import MPFoundation
import XCTest

final class CardFormRulesTests: XCTestCase {
    // MARK: - Default Validation Data Helpers

    private static func defaultCardNumberValidation() -> CardFormTexts.CardNumberField.Validation {
        .init(
            errorEmpty: MPStrings.CardForm.CardNumber.errorEmpty,
            errorIncomplete: MPStrings.CardForm.CardNumber.errorIncomplete,
            errorInvalid: MPStrings.CardForm.CardNumber.errorInvalid,
            errorMethodNotAllowed: MPStrings.CardForm.CardNumber.errorMethodNotAllowed(brand: "%@"),
            errorTypeNotAllowed: MPStrings.CardForm.CardNumber.errorTypeNotAllowed(cardType: "%@")
        )
    }

    private static func defaultCardHolderValidation() -> CardFormTexts.CardHolderField.Validation {
        .init(
            errorEmpty: MPStrings.CardForm.CardHolder.errorEmpty,
            errorIncomplete: MPStrings.CardForm.CardHolder.errorIncomplete,
            errorInvalid: MPStrings.CardForm.CardHolder.errorInvalid
        )
    }

    private static func defaultExpirationValidation() -> CardFormTexts.ExpirationField.Validation {
        .init(
            errorEmpty: MPStrings.CardForm.Expiration.errorEmpty,
            errorIncomplete: MPStrings.CardForm.Expiration.errorIncomplete,
            errorInvalid: MPStrings.CardForm.Expiration.errorInvalid
        )
    }

    private static func defaultCVVValidation() -> CardFormTexts.CVVField.Validation {
        .init(
            errorEmpty: MPStrings.CardForm.CVV.errorEmpty,
            errorIncomplete: MPStrings.CardForm.CVV.errorIncomplete
        )
    }

    private static func defaultDocumentValidation() -> CardFormTexts.DocumentField.Validation {
        .init(
            errorEmpty: MPStrings.CardForm.Document.errorEmpty,
            errorIncomplete: MPStrings.CardForm.Document.errorIncomplete,
            errorInvalid: MPStrings.CardForm.Document.errorInvalid
        )
    }

    // MARK: - CardNumberRule

    func test_cardNumberRule_whenEmpty_shouldReturnEmptyError() {
        // Arrange
        let rule = CardNumberRule(validation: Self.defaultCardNumberValidation())

        // Act
        let result = rule.validate("")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardNumberRule_whenBelowMinLength_shouldReturnIncompleteError() {
        // Arrange
        var rule = CardNumberRule(validation: Self.defaultCardNumberValidation())
        rule.apply(.cardNumberRange(min: 16, max: 16))

        // Act
        let result = rule.validate("4111 1111 1111")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardNumberRule_whenValidLuhn_shouldReturnNil() {
        // Arrange
        let rule = CardNumberRule(validation: Self.defaultCardNumberValidation())

        // Act -- 4111111111111111 is a valid Luhn number
        let result = rule.validate("4111 1111 1111 1111")

        // Assert
        XCTAssertNil(result)
    }

    func test_cardNumberRule_whenInvalidLuhn_shouldReturnInvalidError() {
        // Arrange
        let rule = CardNumberRule(validation: Self.defaultCardNumberValidation())

        // Act -- invalid Luhn
        let result = rule.validate("4111 1111 1111 1112")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardNumberRule_whenAllDigitsSame_shouldReturnInvalidError() {
        // Arrange
        let rule = CardNumberRule(validation: Self.defaultCardNumberValidation())

        // Act -- all digits repeated (1111111111111111)
        let result = rule.validate("1111 1111 1111 1111")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardNumberRule_whenAllDigitsSameDifferentDigit_shouldReturnInvalidError() {
        // Arrange
        let rule = CardNumberRule(validation: Self.defaultCardNumberValidation())

        // Act -- all digits repeated (4444444444444444)
        let result = rule.validate("4444 4444 4444 4444")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardNumberRule_whenPaymentMethodNotAllowed_shouldReturnSellerExclusionError() {
        // Arrange
        var rule = CardNumberRule(validation: Self.defaultCardNumberValidation())
        rule.apply(.cardNumberExternalError(.paymentMethodNotAllowed("visa")))

        // Act
        let result = rule.validate("4111 1111 1111 1111")

        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.contains("visa") == true)
    }

    func test_cardNumberRule_whenPaymentTypeNotAllowedCredit_shouldReturnTypeNotAllowedError() {
        // Arrange
        var rule = CardNumberRule(validation: Self.defaultCardNumberValidation())
        rule.apply(.cardNumberExternalError(.paymentTypeNotAllowed(.credit)))

        // Act
        let result = rule.validate("4111 1111 1111 1111")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardNumberRule_whenPaymentTypeNotAllowedDebit_shouldReturnTypeNotAllowedError() {
        // Arrange
        var rule = CardNumberRule(validation: Self.defaultCardNumberValidation())
        rule.apply(.cardNumberExternalError(.paymentTypeNotAllowed(.debit)))

        // Act
        let result = rule.validate("4111 1111 1111 1111")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardNumberRule_whenPaymentTypeNotAllowedPrepaid_shouldReturnTypeNotAllowedError() {
        // Arrange
        var rule = CardNumberRule(validation: Self.defaultCardNumberValidation())
        rule.apply(.cardNumberExternalError(.paymentTypeNotAllowed(.prepaid)))

        // Act
        let result = rule.validate("4111 1111 1111 1111")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardNumberRule_whenPaymentTypeNotAllowedNil_shouldReturnInvalidError() {
        // Arrange
        var rule = CardNumberRule(validation: Self.defaultCardNumberValidation())
        rule.apply(.cardNumberExternalError(.paymentTypeNotAllowed(nil)))

        // Act
        let result = rule.validate("4111 1111 1111 1111")

        // Assert -- nil card type should use generic invalid error (not a broken sentence)
        XCTAssertNotNil(result)
    }

    func test_cardNumberRule_whenExternalErrorCleared_shouldValidateNormally() {
        // Arrange
        var rule = CardNumberRule(validation: Self.defaultCardNumberValidation())
        rule.apply(.cardNumberExternalError(.paymentMethodNotAllowed("visa")))
        rule.apply(.cardNumberExternalError(nil))

        // Act -- valid Luhn, no external error
        let result = rule.validate("4111 1111 1111 1111")

        // Assert
        XCTAssertNil(result)
    }

    // MARK: - CardNumberRule (validateLive)

    func test_cardNumberRule_validateLive_whenEmpty_shouldReturnNil() {
        // Arrange
        let rule = CardNumberRule(validation: Self.defaultCardNumberValidation())

        // Act
        let result = rule.validateLive("")

        // Assert
        XCTAssertNil(result)
    }

    func test_cardNumberRule_validateLive_whenBelowMinLength_shouldReturnNil() {
        // Arrange -- number with fewer than 13 digits should not trigger live errors
        var rule = CardNumberRule(validation: Self.defaultCardNumberValidation())
        rule.apply(.cardNumberRange(min: 16, max: 16))

        // Act
        let result = rule.validateLive("1111 1111 11")

        // Assert
        XCTAssertNil(result)
    }

    func test_cardNumberRule_validateLive_whenAllDigitsSameAndComplete_shouldReturnInvalidError() {
        // Arrange
        let rule = CardNumberRule(validation: Self.defaultCardNumberValidation())

        // Act
        let result = rule.validateLive("1111 1111 1111 1111")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardNumberRule_validateLive_whenValidNumber_shouldReturnNil() {
        // Arrange
        let rule = CardNumberRule(validation: Self.defaultCardNumberValidation())

        // Act -- 4111111111111111 is a valid non-repeated number
        let result = rule.validateLive("4111 1111 1111 1111")

        // Assert
        XCTAssertNil(result)
    }

    func test_cardNumberRule_validateLive_whenExternalError_shouldReturnError() {
        // Arrange
        var rule = CardNumberRule(validation: Self.defaultCardNumberValidation())
        rule.apply(.cardNumberExternalError(.paymentMethodNotAllowed("visa")))

        // Act
        let result = rule.validateLive("4111 1111 1111 1111")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardNumberRule_validateLive_whenExternalErrorCleared_shouldReturnNil() {
        // Arrange
        var rule = CardNumberRule(validation: Self.defaultCardNumberValidation())
        rule.apply(.cardNumberExternalError(.paymentMethodNotAllowed("visa")))
        rule.apply(.cardNumberExternalError(nil))

        // Act
        let result = rule.validateLive("4111 1111 1111 1111")

        // Assert
        XCTAssertNil(result)
    }

    func test_cardNumberRule_validateLive_whenEmptyWithExternalError_shouldReturnNil() {
        // Arrange -- external error set but field is empty: should not show error
        var rule = CardNumberRule(validation: Self.defaultCardNumberValidation())
        rule.apply(.cardNumberExternalError(.paymentMethodNotAllowed("visa")))

        // Act
        let result = rule.validateLive("")

        // Assert
        XCTAssertNil(result)
    }

    // MARK: - CardHolderRule

    func test_cardHolderRule_whenEmpty_shouldReturnEmptyError() {
        // Arrange
        let rule = CardHolderRule(validation: Self.defaultCardHolderValidation())

        // Act
        let result = rule.validate("")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardHolderRule_whenOnlyWhitespace_shouldReturnEmptyError() {
        // Arrange
        let rule = CardHolderRule(validation: Self.defaultCardHolderValidation())

        // Act
        let result = rule.validate("   ")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardHolderRule_whenSingleChar_shouldReturnIncompleteError() {
        // Arrange
        let rule = CardHolderRule(validation: Self.defaultCardHolderValidation())

        // Act
        let result = rule.validate("A")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardHolderRule_whenLettersOnly_shouldReturnNil() {
        // Arrange
        let rule = CardHolderRule(validation: Self.defaultCardHolderValidation())

        // Act
        let result = rule.validate("Maria Lopez")

        // Assert
        XCTAssertNil(result)
    }

    func test_cardHolderRule_whenLettersAndNumbers_shouldReturnNil() {
        // Arrange
        let rule = CardHolderRule(validation: Self.defaultCardHolderValidation())

        // Act
        let result = rule.validate("John 2nd")

        // Assert
        XCTAssertNil(result)
    }

    func test_cardHolderRule_whenSpecialCharacters_shouldReturnInvalidFormatError() {
        // Arrange
        let rule = CardHolderRule(validation: Self.defaultCardHolderValidation())

        // Act
        let result = rule.validate("Maria @Lopez")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardHolderRule_whenHashCharacter_shouldReturnInvalidFormatError() {
        // Arrange
        let rule = CardHolderRule(validation: Self.defaultCardHolderValidation())

        // Act
        let result = rule.validate("Jo#hn")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardHolderRule_whenAccentedLetters_shouldReturnNil() {
        // Arrange
        let rule = CardHolderRule(validation: Self.defaultCardHolderValidation())

        // Act
        let result = rule.validate("María López")

        // Assert
        XCTAssertNil(result)
    }

    // MARK: - CardType

    func test_cardType_initFromCreditPaymentTypeId_shouldReturnCredit() {
        // Act
        let type_ = MercadoPagoCheckout.CardType(paymentTypeId: "credit_card")

        // Assert
        XCTAssertEqual(type_, .credit)
    }

    func test_cardType_initFromDebitPaymentTypeId_shouldReturnDebit() {
        // Act
        let type_ = MercadoPagoCheckout.CardType(paymentTypeId: "debit_card")

        // Assert
        XCTAssertEqual(type_, .debit)
    }

    func test_cardType_initFromPrepaidPaymentTypeId_shouldReturnPrepaid() {
        // Act
        let type_ = MercadoPagoCheckout.CardType(paymentTypeId: "prepaid_card")

        // Assert
        XCTAssertEqual(type_, .prepaid)
    }

    func test_cardType_initFromUnknownPaymentTypeId_shouldReturnNil() {
        // Act
        let type_ = MercadoPagoCheckout.CardType(paymentTypeId: "unknown_type")

        // Assert
        XCTAssertNil(type_)
    }

    func test_cardType_initFromNilPaymentTypeId_shouldReturnNil() {
        // Act
        let type_ = MercadoPagoCheckout.CardType(paymentTypeId: nil)

        // Assert
        XCTAssertNil(type_)
    }

    func test_cardType_paymentTypeIdRoundtrip_shouldMatchOriginal() {
        // Arrange / Act / Assert
        for cardType in [MercadoPagoCheckout.CardType.credit, .debit, .prepaid] {
            let roundtripped = MercadoPagoCheckout.CardType(paymentTypeId: cardType.paymentTypeId)
            XCTAssertEqual(roundtripped, cardType)
        }
    }

    // MARK: - SecurityCodeRule

    func test_securityCodeRule_whenEmpty_shouldReturnEmptyError() {
        // Arrange
        let rule = SecurityCodeRule(validation: Self.defaultCVVValidation())

        // Act
        let result = rule.validate("")

        // Assert
        XCTAssertEqual(result, MPStrings.CardForm.CVV.errorEmpty)
    }

    func test_securityCodeRule_whenIncomplete_shouldReturnIncompleteError() {
        // Arrange -- default length is 3
        let rule = SecurityCodeRule(validation: Self.defaultCVVValidation())

        // Act
        let result = rule.validate("12")

        // Assert
        XCTAssertEqual(result, MPStrings.CardForm.CVV.errorIncomplete)
    }

    func test_securityCodeRule_whenCompleteWithDefaultLength_shouldReturnNil() {
        // Arrange
        let rule = SecurityCodeRule(validation: Self.defaultCVVValidation())

        // Act
        let result = rule.validate("123")

        // Assert
        XCTAssertNil(result)
    }

    func test_securityCodeRule_whenAmexLengthApplied_withFourDigits_shouldReturnNil() {
        // Arrange
        var rule = SecurityCodeRule(validation: Self.defaultCVVValidation())
        rule.apply(.securityCodeLength(4))

        // Act
        let result = rule.validate("1234")

        // Assert
        XCTAssertNil(result)
    }

    func test_securityCodeRule_whenAmexLengthApplied_withThreeDigits_shouldReturnIncompleteError() {
        // Arrange
        var rule = SecurityCodeRule(validation: Self.defaultCVVValidation())
        rule.apply(.securityCodeLength(4))

        // Act
        let result = rule.validate("123")

        // Assert
        XCTAssertNotNil(result)
    }

    // MARK: - Custom Validation Texts

    func test_cardNumberRule_usesCustomValidationTexts() {
        // Arrange
        let customValidation = CardFormTexts.CardNumberField.Validation(
            errorEmpty: "CUSTOM_EMPTY",
            errorIncomplete: "CUSTOM_INCOMPLETE",
            errorInvalid: "CUSTOM_INVALID",
            errorMethodNotAllowed: "CUSTOM_EXCLUSION %@",
            errorTypeNotAllowed: "CUSTOM_TYPE %@"
        )
        let rule = CardNumberRule(validation: customValidation)

        // Act / Assert -- empty
        XCTAssertEqual(rule.validate(""), "CUSTOM_EMPTY")

        // Act / Assert -- invalid (all same digits)
        XCTAssertEqual(rule.validate("1111 1111 1111 1111"), "CUSTOM_INVALID")

        // Act / Assert -- incomplete
        var ruleWithRange = CardNumberRule(validation: customValidation)
        ruleWithRange.apply(.cardNumberRange(min: 16, max: 16))
        XCTAssertEqual(ruleWithRange.validate("4111 1111"), "CUSTOM_INCOMPLETE")
    }

    func test_cardHolderRule_usesCustomValidationTexts() {
        // Arrange
        let customValidation = CardFormTexts.CardHolderField.Validation(
            errorEmpty: "CUSTOM_EMPTY",
            errorIncomplete: "CUSTOM_INCOMPLETE",
            errorInvalid: "CUSTOM_FORMAT"
        )
        let rule = CardHolderRule(validation: customValidation)

        // Act / Assert -- empty
        XCTAssertEqual(rule.validate(""), "CUSTOM_EMPTY")

        // Act / Assert -- incomplete (single char)
        XCTAssertEqual(rule.validate("A"), "CUSTOM_INCOMPLETE")

        // Act / Assert -- invalid format
        XCTAssertEqual(rule.validate("Jo@hn"), "CUSTOM_FORMAT")
    }

    func test_expirationDateRule_usesCustomValidationTexts() {
        // Arrange
        let customValidation = CardFormTexts.ExpirationField.Validation(
            errorEmpty: "CUSTOM_EMPTY",
            errorIncomplete: "CUSTOM_INCOMPLETE",
            errorInvalid: "CUSTOM_INVALID"
        )
        let rule = ExpirationDateRule(validation: customValidation)

        // Act / Assert -- empty
        XCTAssertEqual(rule.validate(""), "CUSTOM_EMPTY")

        // Act / Assert -- incomplete (only 2 digits)
        XCTAssertEqual(rule.validate("12"), "CUSTOM_INCOMPLETE")

        // Act / Assert -- invalid (month 13)
        XCTAssertEqual(rule.validate("1399"), "CUSTOM_INVALID")
    }

    func test_securityCodeRule_usesCustomValidationTexts() {
        // Arrange
        let customValidation = CardFormTexts.CVVField.Validation(
            errorEmpty: "CUSTOM_EMPTY",
            errorIncomplete: "CUSTOM_INCOMPLETE"
        )
        let rule = SecurityCodeRule(validation: customValidation)

        // Act / Assert -- empty
        XCTAssertEqual(rule.validate(""), "CUSTOM_EMPTY")

        // Act / Assert -- incomplete
        XCTAssertEqual(rule.validate("12"), "CUSTOM_INCOMPLETE")
    }

    func test_documentRule_usesCustomValidationTexts() {
        // Arrange
        let customValidation = CardFormTexts.DocumentField.Validation(
            errorEmpty: "CUSTOM_EMPTY",
            errorIncomplete: "CUSTOM_INCOMPLETE",
            errorInvalid: "CUSTOM_INVALID"
        )
        let rule = DocumentRule(validation: customValidation)

        // Act / Assert -- empty
        XCTAssertEqual(rule.validate(""), "CUSTOM_EMPTY")

        // Act / Assert -- invalid (all zeros)
        var ruleWithLen = DocumentRule(validation: customValidation)
        ruleWithLen.apply(.documentLength(min: 3, max: 3))
        XCTAssertEqual(ruleWithLen.validate("000"), "CUSTOM_INVALID")
    }

    // MARK: - DocumentRule (string/alphanumeric type)

    func test_documentRule_stringType_whenEmpty_shouldReturnEmptyError() {
        // Arrange
        var rule = DocumentRule(validation: Self.defaultDocumentValidation())
        rule.apply(.documentType(isNumeric: false))

        // Act
        let result = rule.validate("")

        // Assert
        XCTAssertEqual(result, MPStrings.CardForm.Document.errorEmpty)
    }

    func test_documentRule_stringType_whenValidAlphanumeric_shouldReturnNil() {
        // Arrange
        var rule = DocumentRule(validation: Self.defaultDocumentValidation())
        rule.apply(.documentType(isNumeric: false))
        rule.apply(.documentLength(min: 5, max: 14))

        // Act — "AB123" has 5 alphanumeric chars, within range
        let result = rule.validate("AB.123")

        // Assert
        XCTAssertNil(result)
    }

    func test_documentRule_stringType_whenAllZeros_shouldReturnNil() {
        // Arrange — all-zeros is only invalid for numeric type, not string type
        var rule = DocumentRule(validation: Self.defaultDocumentValidation())
        rule.apply(.documentType(isNumeric: false))
        rule.apply(.documentLength(min: 3, max: 3))

        // Act
        let result = rule.validate("000")

        // Assert
        XCTAssertNil(result)
    }

    func test_documentRule_stringType_whenIncomplete_shouldReturnIncompleteError() {
        // Arrange
        var rule = DocumentRule(validation: Self.defaultDocumentValidation())
        rule.apply(.documentType(isNumeric: false))
        rule.apply(.documentLength(min: 5, max: 14))

        // Act — "AB" has only 2 alphanumeric chars, below min
        let result = rule.validate("AB")

        // Assert
        XCTAssertEqual(result, MPStrings.CardForm.Document.errorIncomplete)
    }

    func test_documentRule_stringType_whenOnlySpecialChars_shouldReturnEmptyError() {
        // Arrange — special chars are stripped, leaving nothing — must return errorEmpty not errorIncomplete
        var rule = DocumentRule(validation: Self.defaultDocumentValidation())
        rule.apply(.documentType(isNumeric: false))

        // Act
        let result = rule.validate("!@#$%")

        // Assert
        XCTAssertEqual(result, MPStrings.CardForm.Document.errorEmpty)
    }

    func test_documentRule_whenTypeToggledFromNumericToString_allZerosShouldBecomeValid() {
        // Arrange
        var rule = DocumentRule(validation: Self.defaultDocumentValidation())
        rule.apply(.documentLength(min: 3, max: 3))

        // Act / Assert — numeric type: all zeros invalid
        XCTAssertEqual(rule.validate("000"), MPStrings.CardForm.Document.errorInvalid)

        // Act — switch to string type
        rule.apply(.documentType(isNumeric: false))

        // Assert — string type: all zeros valid
        XCTAssertNil(rule.validate("000"))
    }
}
