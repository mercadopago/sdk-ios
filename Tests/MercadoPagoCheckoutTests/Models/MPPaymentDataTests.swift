//
//  MPPaymentDataTests.swift
//  MercadoPagoSDK
//
//  Created by SDK on 23/04/26.
//

@testable import MercadoPagoCheckout
import XCTest

final class MPPaymentDataTests: XCTestCase {
    // MARK: - Convenience init (internal, with defaults)

    func test_init_withNoArguments_shouldUseDefaults() {
        // Arrange / Act
        let data = MPPaymentData()

        // Assert
        XCTAssertNil(data.transactionAmount)
        XCTAssertEqual(data.token, "")
        XCTAssertNil(data.installment)
        XCTAssertEqual(data.paymentMethodId, "")
        XCTAssertEqual(data.paymentTypeId, "")
        XCTAssertNil(data.issuerId)
        XCTAssertNil(data.payer)
    }

    func test_init_shouldReplaceNilTokenWithEmptyString() {
        // Arrange / Act
        let data = MPPaymentData(token: nil)

        // Assert
        XCTAssertEqual(data.token, "")
    }

    func test_init_shouldReplaceNilPaymentMethodIdWithEmptyString() {
        let data = MPPaymentData(paymentMethodId: nil)
        XCTAssertEqual(data.paymentMethodId, "")
    }

    func test_init_shouldReplaceNilPaymentTypeIdWithEmptyString() {
        let data = MPPaymentData(paymentTypeId: nil)
        XCTAssertEqual(data.paymentTypeId, "")
    }

    func test_init_shouldPreservePassedValues() {
        // Arrange
        let payer = MPPaymentData.Payer(documentType: "CPF", documentNumber: "12345678901")

        // Act
        let data = MPPaymentData(
            transactionAmount: 1000.50,
            token: "tok_abc",
            installment: 3,
            paymentMethodId: "visa",
            paymentTypeId: "credit_card",
            issuerId: "25",
            payer: payer
        )

        // Assert
        XCTAssertEqual(data.transactionAmount, 1000.50)
        XCTAssertEqual(data.token, "tok_abc")
        XCTAssertEqual(data.installment, 3)
        XCTAssertEqual(data.paymentMethodId, "visa")
        XCTAssertEqual(data.paymentTypeId, "credit_card")
        XCTAssertEqual(data.issuerId, "25")
        XCTAssertEqual(data.payer, payer)
    }

    // MARK: - Equatable

    func test_equatable_whenAllFieldsMatch_shouldBeEqual() {
        let a = MPPaymentData(transactionAmount: 100, token: "tok", paymentMethodId: "visa")
        let b = MPPaymentData(transactionAmount: 100, token: "tok", paymentMethodId: "visa")
        XCTAssertEqual(a, b)
    }

    func test_equatable_whenAnyFieldDiffers_shouldNotBeEqual() {
        let base = MPPaymentData(transactionAmount: 100, token: "tok")
        let differentAmount = MPPaymentData(transactionAmount: 200, token: "tok")
        let differentToken = MPPaymentData(transactionAmount: 100, token: "other")

        XCTAssertNotEqual(base, differentAmount)
        XCTAssertNotEqual(base, differentToken)
    }

    // MARK: - Codable round-trip

    func test_codable_roundtrip_shouldPreserveAllFields() throws {
        // Arrange
        let original = MPPaymentData(
            transactionAmount: 1500.75,
            token: "tok_123",
            installment: 6,
            paymentMethodId: "master",
            paymentTypeId: "credit_card",
            issuerId: "10",
            payer: MPPaymentData.Payer(documentType: "DNI", documentNumber: "40123456")
        )

        // Act
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MPPaymentData.self, from: data)

        // Assert
        XCTAssertEqual(decoded, original)
    }

    func test_codable_roundtrip_withOptionalNils_shouldPreserveNils() throws {
        // Arrange
        let original = MPPaymentData(token: "tok")

        // Act
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MPPaymentData.self, from: data)

        // Assert
        XCTAssertEqual(decoded, original)
        XCTAssertNil(decoded.transactionAmount)
        XCTAssertNil(decoded.installment)
        XCTAssertNil(decoded.issuerId)
        XCTAssertNil(decoded.payer)
    }

    func test_codable_encode_shouldProduceExpectedKeys() throws {
        // Arrange -- contract check: keys are the field names, no custom CodingKeys
        let data = MPPaymentData(transactionAmount: 10.0, token: "t", paymentMethodId: "visa")

        // Act
        let json = try JSONEncoder().encode(data)
        let dict = try XCTUnwrap(JSONSerialization.jsonObject(with: json) as? [String: Any])

        // Assert
        XCTAssertEqual(dict["transactionAmount"] as? Double, 10.0)
        XCTAssertEqual(dict["token"] as? String, "t")
        XCTAssertEqual(dict["paymentMethodId"] as? String, "visa")
        XCTAssertEqual(dict["paymentTypeId"] as? String, "")
    }

    func test_codable_decode_shouldAcceptMissingOptionalFields() throws {
        // Arrange -- only required fields present
        let json = #"{"token":"tok_abc","paymentMethodId":"visa","paymentTypeId":"credit_card"}"#
            .data(using: .utf8)!

        // Act
        let decoded = try JSONDecoder().decode(MPPaymentData.self, from: json)

        // Assert
        XCTAssertEqual(decoded.token, "tok_abc")
        XCTAssertEqual(decoded.paymentMethodId, "visa")
        XCTAssertEqual(decoded.paymentTypeId, "credit_card")
        XCTAssertNil(decoded.transactionAmount)
        XCTAssertNil(decoded.installment)
        XCTAssertNil(decoded.issuerId)
        XCTAssertNil(decoded.payer)
    }

    // MARK: - Payer

    func test_payer_equatable_whenFieldsMatch_shouldBeEqual() {
        let a = MPPaymentData.Payer(documentType: "CPF", documentNumber: "123")
        let b = MPPaymentData.Payer(documentType: "CPF", documentNumber: "123")
        XCTAssertEqual(a, b)
    }

    func test_payer_equatable_whenFieldsDiffer_shouldNotBeEqual() {
        let a = MPPaymentData.Payer(documentType: "CPF", documentNumber: "123")
        let b = MPPaymentData.Payer(documentType: "CNPJ", documentNumber: "123")
        XCTAssertNotEqual(a, b)
    }

    func test_payer_codable_roundtrip_shouldPreserveFields() throws {
        // Arrange
        let original = MPPaymentData.Payer(documentType: "DNI", documentNumber: "40123456")

        // Act
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MPPaymentData.Payer.self, from: data)

        // Assert
        XCTAssertEqual(decoded, original)
    }
}
