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

    // MARK: - getPlaceholder

    func test_getPlaceholder_whenCPF_shouldReturnBrazilianCPFMask() {
        let type = IdentificationType(id: "CPF", name: "CPF", type: "number", minLenght: 11, maxLenght: 11)
        XCTAssertEqual(type.getPlaceholder(), "999.999.999-99")
    }

    func test_getPlaceholder_whenCNPJ_shouldReturnBrazilianCNPJMask() {
        let type = IdentificationType(id: "CNPJ", name: "CNPJ", type: "number", minLenght: 14, maxLenght: 14)
        XCTAssertEqual(type.getPlaceholder(), "99.999.999/9999-99")
    }

    func test_getPlaceholder_whenUnknownId_shouldReturnEmpty() {
        // Arrange -- documents from other countries (DNI, RUC, …) don't have a placeholder mask
        let type = IdentificationType(id: "DNI", name: "DNI", type: "number", minLenght: 7, maxLenght: 9)
        XCTAssertEqual(type.getPlaceholder(), "")
    }

    // MARK: - getFormat

    func test_getFormat_whenCPF_shouldReturnNumericMask() {
        let type = IdentificationType(id: "CPF", name: "CPF", type: "number", minLenght: 11, maxLenght: 11)
        XCTAssertEqual(type.getFormat(), "###.###.###-##")
    }

    func test_getFormat_whenCNPJ_andNumberType_shouldReturnNumericMask() {
        let type = IdentificationType(id: "CNPJ", name: "CNPJ", type: "number", minLenght: 14, maxLenght: 14)
        XCTAssertEqual(type.getFormat(), "##.###.###/####-##")
    }

    func test_getFormat_whenCNPJ_andStringType_shouldReturnAlphanumericMask() {
        // Arrange -- CNPJ alfanumérico (Receita Federal 2026+): aceita letras nas primeiras 12 posições
        let type = IdentificationType(id: "CNPJ", name: "CNPJ", type: "string", minLenght: 14, maxLenght: 14)
        XCTAssertEqual(type.getFormat(), "AA.AAA.AAA/AAAA-##")
    }

    func test_getFormat_whenUnknownId_shouldReturnEmpty() {
        let type = IdentificationType(id: "DNI", name: "DNI", type: "number", minLenght: 7, maxLenght: 9)
        XCTAssertEqual(type.getFormat(), "")
    }
}
