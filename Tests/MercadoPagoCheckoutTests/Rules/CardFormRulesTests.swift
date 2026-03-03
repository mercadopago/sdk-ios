//
//  CardFormRulesTests.swift
//  MercadoPagoSDK
//
//  Created by SDK on 03/03/26.
//

import XCTest
@testable import MercadoPagoCheckout

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
}
