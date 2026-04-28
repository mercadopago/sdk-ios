//
//  IdentificationTypeCheckoutTests.swift
//  MercadoPagoSDK
//

@testable import CoreMethods
@testable import MercadoPagoCheckout
import UIKit
import XCTest

final class IdentificationTypeCheckoutTests: XCTestCase {
    // MARK: - getKeyboardType

    func test_getKeyboardType_whenNumberType_shouldReturnNumberPad() {
        // Arrange
        let type = IdentificationType(id: "CPF", name: "CPF", type: "number", minLenght: 11, maxLenght: 11)

        // Act / Assert
        XCTAssertEqual(type.getKeyboardType(), .numberPad)
    }

    func test_getKeyboardType_whenStringType_shouldReturnDefault() {
        // Arrange
        let type = IdentificationType(id: "CNPJ", name: "CNPJ", type: "string", minLenght: 14, maxLenght: 14)

        // Act / Assert
        XCTAssertEqual(type.getKeyboardType(), .default)
    }

    func test_getKeyboardType_whenUnknownType_shouldReturnDefault() {
        // Arrange
        let type = IdentificationType(id: "OTHER", name: "Other", type: "numeric", minLenght: 8, maxLenght: 10)

        // Act / Assert
        XCTAssertEqual(type.getKeyboardType(), .default)
    }

    // MARK: - getPlaceholder

    func test_getPlaceholder_whenInitializedWithPlaceholder_shouldReturnIt() {
        let type = IdentificationType(
            id: "CPF", name: "CPF", type: "number",
            minLenght: 11, maxLenght: 11,
            placeholder: "999.999.999-99",
            mask: "###.###.###-##"
        )
        XCTAssertEqual(type.getPlaceholder(), "999.999.999-99")
    }

    func test_getPlaceholder_whenPublicInit_shouldReturnEmpty() {
        let type = IdentificationType(id: "CPF", name: "CPF", type: "number", minLenght: 11, maxLenght: 11)
        XCTAssertEqual(type.getPlaceholder(), "")
    }

    // MARK: - getFormat

    func test_getFormat_whenInitializedWithMask_shouldReturnIt() {
        let type = IdentificationType(
            id: "CPF", name: "CPF", type: "number",
            minLenght: 11, maxLenght: 11,
            placeholder: "999.999.999-99",
            mask: "###.###.###-##"
        )
        XCTAssertEqual(type.getFormat(), "###.###.###-##")
    }

    func test_getFormat_whenPublicInit_shouldReturnEmpty() {
        let type = IdentificationType(id: "DNI", name: "DNI", type: "number", minLenght: 7, maxLenght: 9)
        XCTAssertEqual(type.getFormat(), "")
    }
}
