@testable import CoreMethods
import XCTest

final class CardNumberValidationTests: XCTestCase {
    // MARK: - CardNumber helpers

    func test_getBin_returnsFirst8Digits() {
        XCTAssertEqual(CardNumber.getBin("4111111111111111"), "41111111")
    }

    func test_getBin_withShortNumber_returnsWholeString() {
        XCTAssertEqual(CardNumber.getBin("12345"), "12345")
    }

    func test_getBin_withExactly8Digits_returnsAll() {
        XCTAssertEqual(CardNumber.getBin("41111111"), "41111111")
    }

    // MARK: - Initialization

    func test_init_defaultErrorIsEmpty() {
        let sut = CardNumberValidation(maxLength: 16)
        XCTAssertEqual(sut.error, .empty)
    }

    // MARK: - isValid — length boundaries

    func test_isValid_withTooShortNumber_returnsFalse() {
        let sut = CardNumberValidation(maxLength: 16)
        XCTAssertFalse(sut.isValid("4111111")) // 7 digits, below min 8
        XCTAssertEqual(sut.error, .invalidLength)
    }

    func test_isValid_withTooLongNumber_returnsFalse() {
        let sut = CardNumberValidation(maxLength: 16)
        XCTAssertFalse(sut.isValid("41111111111111111")) // 17 digits, above max
        XCTAssertEqual(sut.error, .invalidLength)
    }

    // MARK: - isValid — Luhn algorithm

    func test_isValid_withValidVisaNumber_returnsTrue() {
        let sut = CardNumberValidation(maxLength: 16)
        XCTAssertTrue(sut.isValid("4111111111111111"))
        XCTAssertEqual(sut.error, .none)
    }

    func test_isValid_withValidMastercardNumber_returnsTrue() {
        let sut = CardNumberValidation(maxLength: 16)
        // 5500005555555559 is a known valid Luhn card for testing digit=9 at odd position
        XCTAssertTrue(sut.isValid("5500005555555559"))
        XCTAssertEqual(sut.error, .none)
    }

    func test_isValid_withInvalidLuhn_returnsFalse() {
        let sut = CardNumberValidation(maxLength: 16)
        XCTAssertFalse(sut.isValid("4111111111111112"))
        XCTAssertEqual(sut.error, .invalidLuhn)
    }

    func test_isValid_withFormattedNumber_stripsSpacesAndValidates() {
        let sut = CardNumberValidation(maxLength: 16)
        XCTAssertTrue(sut.isValid("4111 1111 1111 1111"))
        XCTAssertEqual(sut.error, .none)
    }

    func test_isValid_with19DigitCard_respectsMaxLength() {
        let sut = CardNumberValidation(maxLength: 19)
        // 6011000990139424 is a known Discover test card (16 digits) — valid Luhn
        XCTAssertTrue(sut.isValid("6011000990139424"))
    }
}
