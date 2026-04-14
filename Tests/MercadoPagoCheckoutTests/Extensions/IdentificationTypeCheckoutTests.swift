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
        let type = IdentificationType(id: "CPF", name: "CPF", type: "number", minLength: 11, maxLength: 11)

        // Act / Assert
        XCTAssertEqual(type.getKeyboardType(), .numberPad)
    }

    func test_getKeyboardType_whenStringType_shouldReturnDefault() {
        // Arrange
        let type = IdentificationType(id: "CNPJ", name: "CNPJ", type: "string", minLength: 14, maxLength: 14)

        // Act / Assert
        XCTAssertEqual(type.getKeyboardType(), .default)
    }

    func test_getKeyboardType_whenUnknownType_shouldReturnDefault() {
        // Arrange
        let type = IdentificationType(id: "OTHER", name: "Other", type: "numeric", minLength: 8, maxLength: 10)

        // Act / Assert
        XCTAssertEqual(type.getKeyboardType(), .default)
    }
}
