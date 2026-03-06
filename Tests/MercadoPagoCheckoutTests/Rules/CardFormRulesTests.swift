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
    // MARK: - CardNumberRule

    func test_cardNumberRule_whenEmpty_shouldReturnEmptyError() {
        // Arrange
        let rule = CardNumberRule()

        // Act
        let result = rule.validate("")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardNumberRule_whenBelowMinLength_shouldReturnIncompleteError() {
        // Arrange
        var rule = CardNumberRule()
        rule.apply(.cardNumberRange(min: 16, max: 16))

        // Act
        let result = rule.validate("4111 1111 1111")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardNumberRule_whenValidLuhn_shouldReturnNil() {
        // Arrange
        let rule = CardNumberRule()

        // Act — 4111111111111111 is a valid Luhn number
        let result = rule.validate("4111 1111 1111 1111")

        // Assert
        XCTAssertNil(result)
    }

    func test_cardNumberRule_whenInvalidLuhn_shouldReturnInvalidError() {
        // Arrange
        let rule = CardNumberRule()

        // Act — invalid Luhn
        let result = rule.validate("4111 1111 1111 1112")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardNumberRule_whenAllDigitsSame_shouldReturnInvalidError() {
        // Arrange
        let rule = CardNumberRule()

        // Act — all digits repeated (1111111111111111)
        let result = rule.validate("1111 1111 1111 1111")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardNumberRule_whenAllDigitsSameDifferentDigit_shouldReturnInvalidError() {
        // Arrange
        let rule = CardNumberRule()

        // Act — all digits repeated (4444444444444444)
        let result = rule.validate("4444 4444 4444 4444")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardNumberRule_whenPaymentMethodNotAllowed_shouldReturnSellerExclusionError() {
        // Arrange
        var rule = CardNumberRule()
        rule.apply(.cardNumberExternalError(.paymentMethodNotAllowed("visa")))

        // Act
        let result = rule.validate("4111 1111 1111 1111")

        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.contains("visa") == true)
    }

    func test_cardNumberRule_whenPaymentTypeNotAllowedCredit_shouldReturnTypeNotAllowedError() {
        // Arrange
        var rule = CardNumberRule()
        rule.apply(.cardNumberExternalError(.paymentTypeNotAllowed(.credit)))

        // Act
        let result = rule.validate("4111 1111 1111 1111")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardNumberRule_whenPaymentTypeNotAllowedDebit_shouldReturnTypeNotAllowedError() {
        // Arrange
        var rule = CardNumberRule()
        rule.apply(.cardNumberExternalError(.paymentTypeNotAllowed(.debit)))

        // Act
        let result = rule.validate("4111 1111 1111 1111")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardNumberRule_whenPaymentTypeNotAllowedPrepaid_shouldReturnTypeNotAllowedError() {
        // Arrange
        var rule = CardNumberRule()
        rule.apply(.cardNumberExternalError(.paymentTypeNotAllowed(.prepaid)))

        // Act
        let result = rule.validate("4111 1111 1111 1111")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardNumberRule_whenPaymentTypeNotAllowedNil_shouldReturnInvalidError() {
        // Arrange
        var rule = CardNumberRule()
        rule.apply(.cardNumberExternalError(.paymentTypeNotAllowed(nil)))

        // Act
        let result = rule.validate("4111 1111 1111 1111")

        // Assert — nil card type should use generic invalid error (not a broken sentence)
        XCTAssertNotNil(result)
    }

    func test_cardNumberRule_whenExternalErrorCleared_shouldValidateNormally() {
        // Arrange
        var rule = CardNumberRule()
        rule.apply(.cardNumberExternalError(.paymentMethodNotAllowed("visa")))
        rule.apply(.cardNumberExternalError(nil))

        // Act — valid Luhn, no external error
        let result = rule.validate("4111 1111 1111 1111")

        // Assert
        XCTAssertNil(result)
    }

    // MARK: - CardNumberRule (validateLive)

    func test_cardNumberRule_validateLive_whenEmpty_shouldReturnNil() {
        // Arrange
        let rule = CardNumberRule()

        // Act
        let result = rule.validateLive("")

        // Assert
        XCTAssertNil(result)
    }

    func test_cardNumberRule_validateLive_whenBelowMinLength_shouldReturnNil() {
        // Arrange — number with fewer than 13 digits should not trigger live errors
        var rule = CardNumberRule()
        rule.apply(.cardNumberRange(min: 16, max: 16))

        // Act
        let result = rule.validateLive("1111 1111 11")

        // Assert
        XCTAssertNil(result)
    }

    func test_cardNumberRule_validateLive_whenAllDigitsSameAndComplete_shouldReturnInvalidError() {
        // Arrange
        let rule = CardNumberRule()

        // Act
        let result = rule.validateLive("1111 1111 1111 1111")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardNumberRule_validateLive_whenValidNumber_shouldReturnNil() {
        // Arrange
        let rule = CardNumberRule()

        // Act — 4111111111111111 is a valid non-repeated number
        let result = rule.validateLive("4111 1111 1111 1111")

        // Assert
        XCTAssertNil(result)
    }

    func test_cardNumberRule_validateLive_whenExternalError_shouldReturnError() {
        // Arrange
        var rule = CardNumberRule()
        rule.apply(.cardNumberExternalError(.paymentMethodNotAllowed("visa")))

        // Act
        let result = rule.validateLive("4111 1111 1111 1111")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardNumberRule_validateLive_whenExternalErrorCleared_shouldReturnNil() {
        // Arrange
        var rule = CardNumberRule()
        rule.apply(.cardNumberExternalError(.paymentMethodNotAllowed("visa")))
        rule.apply(.cardNumberExternalError(nil))

        // Act
        let result = rule.validateLive("4111 1111 1111 1111")

        // Assert
        XCTAssertNil(result)
    }

    func test_cardNumberRule_validateLive_whenEmptyWithExternalError_shouldReturnNil() {
        // Arrange — external error set but field is empty: should not show error
        var rule = CardNumberRule()
        rule.apply(.cardNumberExternalError(.paymentMethodNotAllowed("visa")))

        // Act
        let result = rule.validateLive("")

        // Assert
        XCTAssertNil(result)
    }

    // MARK: - CardHolderRule

    func test_cardHolderRule_whenEmpty_shouldReturnEmptyError() {
        // Arrange
        let rule = CardHolderRule()

        // Act
        let result = rule.validate("")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardHolderRule_whenOnlyWhitespace_shouldReturnEmptyError() {
        // Arrange
        let rule = CardHolderRule()

        // Act
        let result = rule.validate("   ")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardHolderRule_whenSingleChar_shouldReturnIncompleteError() {
        // Arrange
        let rule = CardHolderRule()

        // Act
        let result = rule.validate("A")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardHolderRule_whenLettersOnly_shouldReturnNil() {
        // Arrange
        let rule = CardHolderRule()

        // Act
        let result = rule.validate("Maria Lopez")

        // Assert
        XCTAssertNil(result)
    }

    func test_cardHolderRule_whenLettersAndNumbers_shouldReturnNil() {
        // Arrange
        let rule = CardHolderRule()

        // Act
        let result = rule.validate("John 2nd")

        // Assert
        XCTAssertNil(result)
    }

    func test_cardHolderRule_whenSpecialCharacters_shouldReturnInvalidFormatError() {
        // Arrange
        let rule = CardHolderRule()

        // Act
        let result = rule.validate("Maria @Lopez")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardHolderRule_whenHashCharacter_shouldReturnInvalidFormatError() {
        // Arrange
        let rule = CardHolderRule()

        // Act
        let result = rule.validate("Jo#hn")

        // Assert
        XCTAssertNotNil(result)
    }

    func test_cardHolderRule_whenAccentedLetters_shouldReturnNil() {
        // Arrange
        let rule = CardHolderRule()

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
        let rule = SecurityCodeRule()

        // Act
        let result = rule.validate("")

        // Assert
        XCTAssertEqual(result, MPStrings.CardForm.CVV.errorEmpty)
    }

    func test_securityCodeRule_whenIncomplete_shouldReturnIncompleteError() {
        // Arrange — default length is 3
        let rule = SecurityCodeRule()

        // Act
        let result = rule.validate("12")

        // Assert
        XCTAssertEqual(result, MPStrings.CardForm.CVV.errorIncomplete)
    }

    func test_securityCodeRule_whenCompleteWithDefaultLength_shouldReturnNil() {
        // Arrange
        let rule = SecurityCodeRule()

        // Act
        let result = rule.validate("123")

        // Assert
        XCTAssertNil(result)
    }

    func test_securityCodeRule_whenAmexLengthApplied_withFourDigits_shouldReturnNil() {
        // Arrange
        var rule = SecurityCodeRule()
        rule.apply(.securityCodeLength(4))

        // Act
        let result = rule.validate("1234")

        // Assert
        XCTAssertNil(result)
    }

    func test_securityCodeRule_whenAmexLengthApplied_withThreeDigits_shouldReturnIncompleteError() {
        // Arrange
        var rule = SecurityCodeRule()
        rule.apply(.securityCodeLength(4))

        // Act
        let result = rule.validate("123")

        // Assert
        XCTAssertNotNil(result)
    }
}
