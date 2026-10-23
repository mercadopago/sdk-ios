//
//  MPAmountDataTests.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 10/03/26.
//

@testable import MPComponents
@testable import MPFoundation
import XCTest

final class MPAmountDataTests: XCTestCase {
    // MARK: - init(from:)

    func test_initFromDouble_shouldUseCurrencySymbol() {
        // Arrange / Act
        let result = MPAmountData(from: 100.0)

        // Assert
        XCTAssertEqual(result.currencySymbol, MPStrings.Common.currency)
    }

    func test_initFromDouble_withRoundValue_shouldHaveEmptyDecimalPart() {
        // Arrange / Act
        let result = MPAmountData(from: 1000.0)

        // Assert
        XCTAssertEqual(result.decimalPart, "")
    }

    func test_initFromDouble_withNonZeroDecimal_shouldExtractDecimalPart() {
        // Arrange / Act
        let result = MPAmountData(from: 1000.99)

        // Assert
        XCTAssertEqual(result.decimalPart, "99")
    }

    func test_initFromDouble_integerPartShouldNotContainDecimalSeparator() {
        // Arrange
        let formatter = NumberFormatter()
        let separator = formatter.decimalSeparator ?? ","

        // Act
        let result = MPAmountData(from: 1000.0)

        // Assert
        XCTAssertFalse(result.integerPart.contains(separator))
    }

    func test_initFromDouble_shouldProduceEqualResultForSameValue() {
        // Arrange / Act
        let result1 = MPAmountData(from: 500.50)
        let result2 = MPAmountData(from: 500.50)

        // Assert
        XCTAssertEqual(result1, result2)
    }

    // MARK: - init(from:currencySymbol:)

    func test_initFromDecimal_shouldMatchDoubleFormatting() throws {
        // Arrange / Act
        let decimalResult = try MPAmountData(
            from: XCTUnwrap(Decimal(string: "3020.89")),
            currencySymbol: "$"
        )
        let doubleResult = MPAmountData(from: 3020.89, currencySymbol: "$")

        // Assert
        XCTAssertEqual(decimalResult, doubleResult)
    }
}
