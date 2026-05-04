@testable import CoreMethods
import XCTest

final class ExpirationDateValidationTests: XCTestCase {
    private func makeSUT() -> ExpirationDateValidation {
        ExpirationDateValidation()
    }

    // MARK: - Initialization

    func test_init_defaultErrorIsEmpty() {
        let sut = self.makeSUT()
        XCTAssertEqual(sut.error, .empty)
    }

    // MARK: - Valid dates

    func test_isValid_withFutureTwoDigitYear_returnsTrue() {
        let sut = self.makeSUT()
        XCTAssertTrue(sut.isValid("12/35"))
        XCTAssertEqual(sut.error, .none)
    }

    func test_isValid_withFutureFourDigitYear_returnsTrue() {
        let sut = self.makeSUT()
        XCTAssertTrue(sut.isValid("12/2035"))
        XCTAssertEqual(sut.error, .none)
    }

    // MARK: - Expired dates

    func test_isValid_withExpiredDate_returnsFalse() {
        let sut = self.makeSUT()
        XCTAssertFalse(sut.isValid("01/20"))
        XCTAssertEqual(sut.error, .expired)
    }

    func test_isValid_withExpiredFourDigitYear_returnsFalse() {
        let sut = self.makeSUT()
        XCTAssertFalse(sut.isValid("01/2020"))
        XCTAssertEqual(sut.error, .expired)
    }

    // MARK: - Invalid format

    func test_isValid_withNoSlash_returnsFalse() {
        let sut = self.makeSUT()
        XCTAssertFalse(sut.isValid("1235"))
        XCTAssertEqual(sut.error, .invalidDate)
    }

    func test_isValid_withNonNumericComponents_returnsFalse() {
        let sut = self.makeSUT()
        XCTAssertFalse(sut.isValid("AB/CD"))
        XCTAssertEqual(sut.error, .invalidDate)
    }

    func test_isValid_withEmptyString_returnsFalse() {
        let sut = self.makeSUT()
        XCTAssertFalse(sut.isValid(""))
        XCTAssertEqual(sut.error, .invalidDate)
    }

    // MARK: - Invalid month

    func test_isValid_withMonthZero_returnsFalse() {
        let sut = self.makeSUT()
        XCTAssertFalse(sut.isValid("00/35"))
        XCTAssertEqual(sut.error, .invalidDate)
    }

    func test_isValid_withMonth13_returnsFalse() {
        let sut = self.makeSUT()
        XCTAssertFalse(sut.isValid("13/35"))
        XCTAssertEqual(sut.error, .invalidDate)
    }

    func test_isValid_withValidBoundaryMonth1_returnsTrue() {
        let sut = self.makeSUT()
        XCTAssertTrue(sut.isValid("01/35"))
        XCTAssertEqual(sut.error, .none)
    }

    func test_isValid_withValidBoundaryMonth12_returnsTrue() {
        let sut = self.makeSUT()
        XCTAssertTrue(sut.isValid("12/35"))
        XCTAssertEqual(sut.error, .none)
    }
}
