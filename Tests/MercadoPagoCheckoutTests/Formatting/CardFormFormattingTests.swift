//
//  CardFormFormattingTests.swift
//  MercadoPagoSDK
//
//  Created by SDK on 09/03/26.
//

@testable import MercadoPagoCheckout
import XCTest

final class CardFormFormattingTests: XCTestCase {
    // MARK: - CardNumberFormatter (default maxLength = 16)

    func test_cardNumberFormatter_default_shouldLimitTo19Digits() {
        // Arrange
        let formatter = CardNumberFormatter()

        // Act — 22 digits provided, only 19 should be accepted
        let result = formatter.formatOnChange("1234567890123456789012")

        // Assert
        let digits = result.filter(\.isNumber)
        XCTAssertEqual(digits.count, 19)
    }

    func test_cardNumberFormatter_default_shouldApply16DigitMask() {
        // Arrange
        let formatter = CardNumberFormatter()

        // Act
        let result = formatter.formatOnChange("1234567890123456")

        // Assert — "#### #### #### ####" pattern
        XCTAssertEqual(result, "1234 5678 9012 3456")
    }

    func test_cardNumberFormatter_default_whenInputAlreadyFormatted_shouldPreserveOutput() {
        // Arrange — simulates user pasting a formatted card number
        let formatter = CardNumberFormatter()

        // Act
        let result = formatter.formatOnChange("1234 5678 9012 3456")

        // Assert
        XCTAssertEqual(result, "1234 5678 9012 3456")
    }

    func test_cardNumberFormatter_default_whenPartialInput_shouldFormatWithoutTrailingSpace() {
        // Arrange
        let formatter = CardNumberFormatter()

        // Act — 5 digits
        let result = formatter.formatOnChange("12345")

        // Assert
        XCTAssertEqual(result, "1234 5")
    }

    func test_cardNumberFormatter_default_whenEmpty_shouldReturnEmpty() {
        // Arrange
        let formatter = CardNumberFormatter()

        // Act
        let result = formatter.formatOnChange("")

        // Assert
        XCTAssertEqual(result, "")
    }

    // MARK: - CardNumberFormatter (maxLength = 19 — e.g. Maestro)

    func test_cardNumberFormatter_whenMaxLength19_shouldLimitTo19Digits() {
        // Arrange
        let formatter = CardNumberFormatter(maxLength: 19)

        // Act — 20 digits provided, only 19 should be accepted
        let result = formatter.formatOnChange("12345678901234567890")

        // Assert
        let digits = result.filter(\.isNumber)
        XCTAssertEqual(digits.count, 19)
    }

    func test_cardNumberFormatter_whenMaxLength19_shouldApply19DigitMask() {
        // Arrange
        let formatter = CardNumberFormatter(maxLength: 19)

        // Act
        let result = formatter.formatOnChange("1234567890123456789")

        // Assert — "#### #### #### #### ###" pattern
        XCTAssertEqual(result, "1234 5678 9012 3456 789")
    }

    func test_cardNumberFormatter_whenMaxLength19_shouldNotLimitAt16() {
        // Arrange
        let formatter = CardNumberFormatter(maxLength: 19)

        // Act — 17 digits: should not be cut at 16
        let result = formatter.formatOnChange("12345678901234567")

        // Assert
        let digits = result.filter(\.isNumber)
        XCTAssertEqual(digits.count, 17)
    }
}
