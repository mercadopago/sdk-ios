//
//  CardFormValidateTests.swift
//  MercadoPagoSDK
//
//  Created by SDK on 22/04/26.
//

@testable import MercadoPagoCheckout
@testable import MPFoundation
import XCTest

final class CardFormValidateTests: XCTestCase {
    // MARK: - Fixtures

    private static func cvvValidation() -> CardFormFields.CVVField.Validation {
        .init(
            errorEmpty: "cvv.empty",
            errorIncomplete: "cvv.incomplete",
            errorInvalid: "cvv.invalid"
        )
    }

    private static func cardHolderValidation() -> CardFormFields.CardHolderField.Validation {
        .init(
            errorEmpty: "holder.empty",
            errorIncomplete: "holder.incomplete",
            errorInvalid: "holder.invalid"
        )
    }

    private static func expirationValidation() -> CardFormFields.ExpirationField.Validation {
        .init(
            errorEmpty: "exp.empty",
            errorIncomplete: "exp.incomplete",
            errorInvalid: "exp.invalid"
        )
    }

    // MARK: - wrappedValue setter

    func test_wrappedValue_whenSetToValid_shouldClearErrors() {
        // Arrange
        var validator = CardFormValidate(
            wrappedValue: "",
            SecurityCodeRule(validation: Self.cvvValidation())
        )
        XCTAssertEqual(validator.errorMessages, ["cvv.empty"])

        // Act
        validator.wrappedValue = "123"

        // Assert
        XCTAssertEqual(validator.wrappedValue, "123")
        XCTAssertEqual(validator.errorMessages, [])
    }

    func test_wrappedValue_whenSetToInvalid_shouldPopulateErrors() {
        // Arrange -- starts valid
        var validator = CardFormValidate(
            wrappedValue: "123",
            SecurityCodeRule(validation: Self.cvvValidation())
        )
        XCTAssertEqual(validator.errorMessages, [])

        // Act -- too few digits
        validator.wrappedValue = "12"

        // Assert
        XCTAssertEqual(validator.errorMessages, ["cvv.incomplete"])
    }

    func test_wrappedValue_whenSetRepeatedly_shouldReflectLatestValidation() {
        // Arrange
        var validator = CardFormValidate(
            wrappedValue: "",
            SecurityCodeRule(validation: Self.cvvValidation())
        )

        // Act / Assert -- errors evolve as the user types
        validator.wrappedValue = "1"
        XCTAssertEqual(validator.errorMessages, ["cvv.incomplete"])

        validator.wrappedValue = "12"
        XCTAssertEqual(validator.errorMessages, ["cvv.incomplete"])

        validator.wrappedValue = "123"
        XCTAssertEqual(validator.errorMessages, [])

        validator.wrappedValue = ""
        XCTAssertEqual(validator.errorMessages, ["cvv.empty"])
    }

    // MARK: - Multiple rules

    func test_errorMessages_whenMultipleRulesFail_shouldPreserveRuleOrder() {
        // Arrange
        let validator = CardFormValidate(
            wrappedValue: "",
            CardHolderRule(validation: Self.cardHolderValidation()),
            SecurityCodeRule(validation: Self.cvvValidation())
        )

        // Assert
        XCTAssertEqual(validator.errorMessages, ["holder.empty", "cvv.empty"])
    }

    func test_errorMessages_whenSomeRulesPass_shouldIncludeOnlyFailing() {
        // Arrange
        let validator = CardFormValidate(
            wrappedValue: "Maria",
            CardHolderRule(validation: Self.cardHolderValidation()),
            ExpirationDateRule(validation: Self.expirationValidation())
        )

        // Assert
        XCTAssertEqual(validator.errorMessages, ["exp.empty"])
    }

    // MARK: - liveErrorMessages (validateLive)

    func test_liveErrorMessages_whenRuleDoesNotOverrideValidateLive_shouldBeEmpty() {
        // Arrange
        let validator = CardFormValidate(
            wrappedValue: "1",
            SecurityCodeRule(validation: Self.cvvValidation())
        )

        // Assert
        XCTAssertEqual(validator.errorMessages, ["cvv.incomplete"])
        XCTAssertEqual(validator.liveErrorMessages, [])
    }

    func test_liveErrorMessages_whenCardNumberInvalidLuhnAtMaxLength_shouldPopulate() {
        // Arrange
        let validation = CardFormFields.CardNumberField.Validation(
            errorEmpty: "num.empty",
            errorIncomplete: "num.incomplete",
            errorInvalid: "num.invalid"
        )
        var rule = CardNumberRule(validation: validation)
        rule.apply(.cardNumberRange(min: 16, max: 16))

        // Act
        let validator = CardFormValidate(wrappedValue: "4111 1111 1111 1112", rule)

        // Assert
        XCTAssertEqual(validator.errorMessages, [])
        XCTAssertEqual(validator.liveErrorMessages, ["num.invalid"])
    }

    func test_liveErrorMessages_whenCardNumberBelowMaxLength_shouldBeEmpty() {
        // Arrange
        let validation = CardFormFields.CardNumberField.Validation(
            errorEmpty: "num.empty",
            errorIncomplete: "num.incomplete",
            errorInvalid: "num.invalid"
        )
        var rule = CardNumberRule(validation: validation)
        rule.apply(.cardNumberRange(min: 16, max: 16))

        // Act -- 15 digits
        let validator = CardFormValidate(wrappedValue: "4111 1111 1111 11", rule)

        // Assert
        XCTAssertEqual(validator.liveErrorMessages, [])
    }

    // MARK: - projectedValue

    func test_projectedValue_shouldReturnErrorMessages() {
        // Arrange
        let validator = CardFormValidate(
            wrappedValue: "",
            SecurityCodeRule(validation: Self.cvvValidation())
        )

        // Assert
        XCTAssertEqual(validator.projectedValue, validator.errorMessages)
        XCTAssertEqual(validator.projectedValue, ["cvv.empty"])
    }

    func test_projectedValue_shouldExcludeLiveErrors() {
        // Arrange .
        let validation = CardFormFields.CardNumberField.Validation(
            errorEmpty: "num.empty",
            errorIncomplete: "num.incomplete",
            errorInvalid: "num.invalid"
        )

        // Act
        let validator = CardFormValidate(
            wrappedValue: "4111 1111 1111 1112",
            CardNumberRule(validation: validation)
        )

        // Assert
        XCTAssertEqual(validator.projectedValue, validator.errorMessages)
    }

    // MARK: - update(requirement)

    func test_update_shouldReapplyValidationAfterRequirement() {
        // Arrange
        var validator = CardFormValidate(
            wrappedValue: "123",
            SecurityCodeRule(validation: Self.cvvValidation())
        )
        XCTAssertEqual(validator.errorMessages, [])

        // Act
        validator.update(.securityCodeLength(4))

        // Assert
        XCTAssertEqual(validator.errorMessages, ["cvv.incomplete"])
    }

    func test_update_whenRequirementMakesInvalidValid_shouldClearError() {
        // Arrange
        var validator = CardFormValidate(
            wrappedValue: "123",
            SecurityCodeRule(validation: Self.cvvValidation())
        )
        validator.update(.securityCodeLength(4))
        XCTAssertEqual(validator.errorMessages, ["cvv.incomplete"])

        // Act
        validator.update(.securityCodeLength(3))

        // Assert
        XCTAssertEqual(validator.errorMessages, [])
    }

    func test_update_shouldApplyRequirementToAllRules() {
        // Arrange
        var validator = CardFormValidate(
            wrappedValue: "123",
            SecurityCodeRule(validation: Self.cvvValidation()),
            SecurityCodeRule(validation: Self.cvvValidation())
        )
        XCTAssertEqual(validator.errorMessages, [])

        // Act -- require 4 digits on both rules
        validator.update(.securityCodeLength(4))

        // Assert -- both rules emit "incomplete"
        XCTAssertEqual(validator.errorMessages, ["cvv.incomplete", "cvv.incomplete"])
    }
}
