@testable import CoreMethods
import XCTest

final class SecurityCodeValidationTests: XCTestCase {
    private func makeSUT(maxLength: Int = 3) -> SecurityCodeValidation {
        SecurityCodeValidation(maxLength: maxLength)
    }

    // MARK: - Initialization

    func test_init_defaultErrorIsEmpty() {
        let sut = self.makeSUT()
        XCTAssertEqual(sut.error, .empty)
    }

    // MARK: - Valid codes

    func test_isValid_withExactLength_returnsTrue() {
        let sut = self.makeSUT(maxLength: 3)
        XCTAssertTrue(sut.isValid("123"))
    }

    func test_isValid_withLengthAboveMax_returnsTrue() {
        let sut = self.makeSUT(maxLength: 3)
        XCTAssertTrue(sut.isValid("1234"))
    }

    func test_isValid_withAmexLength4_returnsTrue() {
        let sut = self.makeSUT(maxLength: 4)
        XCTAssertTrue(sut.isValid("1234"))
    }

    // MARK: - Invalid codes

    func test_isValid_withTooShort_returnsFalse() {
        let sut = self.makeSUT(maxLength: 3)
        XCTAssertFalse(sut.isValid("12"))
        XCTAssertEqual(sut.error, .invalidLength)
    }

    func test_isValid_withEmpty_returnsFalse() {
        let sut = self.makeSUT(maxLength: 3)
        XCTAssertFalse(sut.isValid(""))
        XCTAssertEqual(sut.error, .invalidLength)
    }

    func test_isValid_withNonNumericStripped_thenTooShort_returnsFalse() {
        let sut = self.makeSUT(maxLength: 3)
        // "1 2" → stripped → "12" → length 2 < 3
        XCTAssertFalse(sut.isValid("1 2"))
        XCTAssertEqual(sut.error, .invalidLength)
    }
}
