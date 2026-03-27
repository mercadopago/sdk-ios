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

// MARK: - DocumentFormatter (numeric type — default)

final class DocumentFormatterNumericTests: XCTestCase {
    func test_documentFormatter_numericType_withMask_shouldApplyMaskAndStripLetters() {
        // Arrange — CPF mask
        let formatter = DocumentFormatter(mask: "###.###.###-##", maxLength: 11, isNumericType: true)

        // Act
        let result = formatter.formatOnChange("12345678901")

        // Assert
        XCTAssertEqual(result, "123.456.789-01")
    }

    func test_documentFormatter_numericType_withMask_shouldIgnoreLettersInInput() {
        // Arrange
        let formatter = DocumentFormatter(mask: "###.###.###-##", maxLength: 11, isNumericType: true)

        // Act — input contains letters that should be stripped
        let result = formatter.formatOnChange("123ABC456789D01")

        // Assert — only digits used
        XCTAssertEqual(result, "123.456.789-01")
    }

    func test_documentFormatter_numericType_withoutMask_shouldReturnDigitsOnly() {
        // Arrange
        let formatter = DocumentFormatter(maxLength: 10, isNumericType: true)

        // Act
        let result = formatter.formatOnChange("abc123def456")

        // Assert
        XCTAssertEqual(result, "123456")
    }

    func test_documentFormatter_numericType_withoutMask_shouldRespectMaxLength() {
        // Arrange
        let formatter = DocumentFormatter(maxLength: 5, isNumericType: true)

        // Act
        let result = formatter.formatOnChange("123456789")

        // Assert
        XCTAssertEqual(result, "12345")
    }
}

// MARK: - DocumentFormatter (string type — alphanumeric)

final class DocumentFormatterStringTests: XCTestCase {
    func test_documentFormatter_stringType_withAlphanumericMask_shouldAcceptLettersAndDigits() {
        // Arrange — mask with A (alphanumeric) and # (digit-only) positions
        let formatter = DocumentFormatter(mask: "AA.AAA.AAA/AAAA-##", maxLength: 14, isNumericType: false)

        // Act
        let result = formatter.formatOnChange("AB123456CDEF12")

        // Assert
        XCTAssertEqual(result, "AB.123.456/CDEF-12")
    }

    func test_documentFormatter_stringType_withAlphanumericMask_shouldStripSpecialChars() {
        // Arrange
        let formatter = DocumentFormatter(mask: "AA.AAA.AAA/AAAA-##", maxLength: 14, isNumericType: false)

        // Act — input contains special characters that should be stripped
        let result = formatter.formatOnChange("AB!123@456#CDEF$12")

        // Assert — special chars removed, letters and digits preserved
        XCTAssertEqual(result, "AB.123.456/CDEF-12")
    }

    func test_documentFormatter_stringType_digitPositionInMask_shouldSkipLetters() {
        // Arrange — mask ends with ## (digit-only)
        let formatter = DocumentFormatter(mask: "AA-##", maxLength: 4, isNumericType: false)

        // Act — user types "AB" then "12" for the digit positions
        let result = formatter.formatOnChange("AB12")

        // Assert
        XCTAssertEqual(result, "AB-12")
    }

    func test_documentFormatter_stringType_withoutMask_shouldReturnAlphanumericOnly() {
        // Arrange
        let formatter = DocumentFormatter(maxLength: 20, isNumericType: false)

        // Act
        let result = formatter.formatOnChange("AB!123@def#456")

        // Assert — special chars removed
        XCTAssertEqual(result, "AB123def456")
    }

    func test_documentFormatter_stringType_withoutMask_shouldRespectMaxLength() {
        // Arrange
        let formatter = DocumentFormatter(maxLength: 5, isNumericType: false)

        // Act
        let result = formatter.formatOnChange("ABCDEFGHIJ")

        // Assert
        XCTAssertEqual(result, "ABCDE")
    }

    func test_documentFormatter_stringType_whenEmpty_shouldReturnEmpty() {
        // Arrange
        let formatter = DocumentFormatter(mask: "AA.AAA", maxLength: 5, isNumericType: false)

        // Act
        let result = formatter.formatOnChange("")

        // Assert
        XCTAssertEqual(result, "")
    }
}
