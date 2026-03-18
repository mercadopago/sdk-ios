//
//  CardFormDataTests.swift
//  MercadoPagoSDK
//
//  Created by SDK on 06/03/26.
//

@testable import MercadoPagoCheckout
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
}
