//
//  MPPaymentDataTests.swift
//  MercadoPagoSDK
//
//  Created by SDK on 23/04/26.
//

@testable import MercadoPagoCheckout
import XCTest

final class MPPaymentDataTests: XCTestCase {
    // MARK: - CardSave

    func test_cardSave_storesToken() {
        let data = MPPaymentData.CardSave(
            token: "tok_save_abc",
            paymentMethodId: "visa",
            paymentTypeId: "credit_card"
        )
        XCTAssertEqual(data.token, "tok_save_abc")
        XCTAssertEqual(data.paymentMethodId, "visa")
    }

    func test_cardSave_codable_roundtrip() throws {
        let original = MPPaymentData.CardSave(
            token: "tok_save",
            paymentMethodId: "master",
            paymentTypeId: "debit_card",
            issuerId: "42"
        )
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MPPaymentData.CardSave.self, from: encoded)
        XCTAssertEqual(decoded, original)
    }

    func test_cardSave_equatable_sameValues_shouldBeEqual() {
        let a = MPPaymentData.CardSave(token: "x", paymentMethodId: "visa", paymentTypeId: "credit_card")
        let b = MPPaymentData.CardSave(token: "x", paymentMethodId: "visa", paymentTypeId: "credit_card")
        XCTAssertEqual(a, b)
    }

    func test_cardSave_equatable_differentToken_shouldNotBeEqual() {
        let a = MPPaymentData.CardSave(token: "x", paymentMethodId: "visa", paymentTypeId: "credit_card")
        let b = MPPaymentData.CardSave(token: "y", paymentMethodId: "visa", paymentTypeId: "credit_card")
        XCTAssertNotEqual(a, b)
    }

    // MARK: - CardTransaction

    func test_cardTransaction_defaultsAndFields() {
        let data = MPPaymentData.CardTransaction(
            transactionAmount: 150.0,
            token: "tok_txn",
            installment: 3,
            paymentMethodId: "visa",
            paymentTypeId: "credit_card"
        )
        XCTAssertEqual(data.transactionAmount, 150.0)
        XCTAssertEqual(data.token, "tok_txn")
        XCTAssertEqual(data.installment, 3)
        XCTAssertEqual(data.paymentMethodId, "visa")
        XCTAssertEqual(data.paymentTypeId, "credit_card")
        XCTAssertEqual(data.issuerId, "")
        XCTAssertNil(data.payer)
    }

    func test_cardTransaction_codable_roundtrip() throws {
        let original = MPPaymentData.CardTransaction(
            transactionAmount: 1500.75,
            token: "tok_123",
            installment: 6,
            paymentMethodId: "master",
            paymentTypeId: "credit_card",
            issuerId: "10",
            payer: .init(documentType: "DNI", documentNumber: "40123456")
        )
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MPPaymentData.CardTransaction.self, from: encoded)
        XCTAssertEqual(decoded, original)
    }

    func test_cardTransaction_codable_missingOptionalFields_shouldNotFail() throws {
        let json = #"{"token":"tok","paymentMethodId":"visa","paymentTypeId":"credit_card","orderId":"","orderStatus":""}"#.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(MPPaymentData.CardTransaction.self, from: json)
        XCTAssertEqual(decoded.token, "tok")
        XCTAssertNil(decoded.transactionAmount)
        XCTAssertNil(decoded.installment)
        XCTAssertNil(decoded.issuerId)
        XCTAssertNil(decoded.payer)
    }

    func test_cardTransaction_equatable_sameValues_shouldBeEqual() {
        let a = MPPaymentData.CardTransaction(token: "t", paymentMethodId: "visa", paymentTypeId: "credit_card")
        let b = MPPaymentData.CardTransaction(token: "t", paymentMethodId: "visa", paymentTypeId: "credit_card")
        XCTAssertEqual(a, b)
    }

    // MARK: - Payer (nested inside CardTransaction)

    func test_payer_codable_roundtrip() throws {
        let original = MPPaymentData.Payer(documentType: "DNI", documentNumber: "40123456")
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MPPaymentData.Payer.self, from: encoded)
        XCTAssertEqual(decoded, original)
    }

    // MARK: - Type identity: CardSave ≠ CardTransaction

    func test_cardSave_isNotCardTransaction() {
        let save: any MPPaymentData.Kind = MPPaymentData.CardSave(
            token: "t", paymentMethodId: "visa", paymentTypeId: "credit_card"
        )
        XCTAssertNil(save as? MPPaymentData.CardTransaction)
    }

    func test_cardTransaction_isNotCardSave() {
        let txn: any MPPaymentData.Kind = MPPaymentData.CardTransaction(
            token: "t", paymentMethodId: "visa", paymentTypeId: "credit_card"
        )
        XCTAssertNil(txn as? MPPaymentData.CardSave)
    }
}
