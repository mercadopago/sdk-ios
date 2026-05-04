//
//  MPPaymentDataTests.swift
//  MercadoPagoSDK
//
//  Created by SDK on 23/04/26.
//

@testable import MercadoPagoCheckout
import XCTest

/// Tests the two parts of `MPPaymentData` that carry real logic: the internal
/// convenience init (with its nil-to-empty-string fallbacks) and the Codable
/// contract that backs wire/JSON persistence. Synthesized Equatable and
/// memberwise init are intentionally not retested.
final class MPPaymentDataTests: XCTestCase {
    // MARK: - Convenience init (internal, with defaults)

    func test_init_withNoArguments_shouldUseDefaults() {
        // Arrange / Act
        let data = MPPaymentData()

        // Assert
        XCTAssertNil(data.transactionAmount)
        XCTAssertEqual(data.token, "")
        XCTAssertEqual(data.paymentMethodId, "")
        XCTAssertEqual(data.paymentTypeId, "")
    }

    func test_init_shouldReplaceNilTokenWithEmptyString() {
        XCTAssertEqual(MPPaymentData(token: nil).token, "")
    }

    func test_init_shouldReplaceNilPaymentMethodIdWithEmptyString() {
        XCTAssertEqual(MPPaymentData(paymentMethodId: nil).paymentMethodId, "")
    }

    func test_init_shouldReplaceNilPaymentTypeIdWithEmptyString() {
        XCTAssertEqual(MPPaymentData(paymentTypeId: nil).paymentTypeId, "")
    }

    // MARK: - Codable — wire contract with backend

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

    func test_codable_encode_shouldProduceExpectedKeys() throws {
        // Arrange -- key names are part of the backend wire contract; renaming
        // a property without custom CodingKeys silently changes the payload.
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
        // Arrange -- backend may omit optional fields; decode must not fail.
        let json = #"{"token":"tok_abc","paymentMethodId":"visa","paymentTypeId":"credit_card"}"#
            .data(using: .utf8)!

        // Act
        let decoded = try JSONDecoder().decode(MPPaymentData.self, from: json)

        // Assert
        XCTAssertEqual(decoded.token, "tok_abc")
        XCTAssertNil(decoded.transactionAmount)
        XCTAssertNil(decoded.installment)
        XCTAssertNil(decoded.issuerId)
        XCTAssertNil(decoded.payer)
    }

    // MARK: - Payer — Codable contract (nested type)

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
