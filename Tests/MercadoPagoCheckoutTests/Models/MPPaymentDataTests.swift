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
            installment: 3,
            paymentMethodId: "visa",
            paymentTypeId: "credit_card"
        )
        XCTAssertEqual(data.installment, 3)
        XCTAssertEqual(data.paymentMethodId, "visa")
        XCTAssertEqual(data.paymentTypeId, "credit_card")
        XCTAssertNil(data.payer)
    }

    func test_cardTransaction_codable_roundtrip() throws {
        let original = MPPaymentData.CardTransaction(
            installment: 6,
            paymentMethodId: "master",
            paymentTypeId: "credit_card",
            payer: .init(documentType: "DNI", documentNumber: "40123456")
        )
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MPPaymentData.CardTransaction.self, from: encoded)
        XCTAssertEqual(decoded, original)
    }

    func test_cardTransaction_codable_missingOptionalFields_shouldNotFail() throws {
        let json = #"{"token":"tok","paymentMethodId":"visa","paymentTypeId":"credit_card","orderId":"","orderStatus":""}"#.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(MPPaymentData.CardTransaction.self, from: json)
        XCTAssertNil(decoded.installment)
        XCTAssertNil(decoded.payer)
    }

    func test_cardTransaction_equatable_sameValues_shouldBeEqual() {
        let a = MPPaymentData.CardTransaction(paymentMethodId: "visa", paymentTypeId: "credit_card")
        let b = MPPaymentData.CardTransaction(paymentMethodId: "visa", paymentTypeId: "credit_card")
        XCTAssertEqual(a, b)
    }

    // MARK: - Payment

    func test_paymentInit_WhenOnlyRequiredArgumentsProvided_ShouldPreserveDefaults() {
        let sut = makeSUT()

        XCTAssertEqual(sut.orderId, "order_test")
        XCTAssertEqual(sut.orderStatus, "")
        XCTAssertEqual(sut.paymentMethodId, "")
        XCTAssertEqual(sut.paymentTypeId, "")
        assertNewPaymentFieldsAreNil(sut)
    }

    func test_paymentDecode_WhenLegacyJSON_ShouldIgnoreAmountAndDefaultNewFields() throws {
        let json = Data("""
        {
            "orderId": "order_legacy",
            "orderStatus": "processed",
            "transactionAmount": 123456789012345678.91,
            "paymentMethodId": "visa",
            "paymentTypeId": "credit_card"
        }
        """.utf8)

        let decoded = try JSONDecoder().decode(MPPaymentData.Payment.self, from: json)

        XCTAssertEqual(decoded.orderId, "order_legacy")
        XCTAssertEqual(decoded.orderStatus, "processed")
        XCTAssertEqual(decoded.paymentMethodId, "visa")
        XCTAssertEqual(decoded.paymentTypeId, "credit_card")
        assertNewPaymentFieldsAreNil(decoded)
    }

    func test_paymentCodable_WhenAllFieldsProvided_ShouldRoundTrip() throws {
        let original = MPPaymentData.Payment(
            orderId: "order_test",
            orderStatus: "action_required",
            paymentMethodId: "rapipago",
            paymentTypeId: "ticket",
            orderStatusDetail: "waiting_payment"
        )

        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MPPaymentData.Payment.self, from: encoded)

        XCTAssertEqual(decoded, original)
        XCTAssertEqual(decoded.orderStatusDetail, "waiting_payment")
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
            paymentMethodId: "visa", paymentTypeId: "credit_card"
        )
        XCTAssertNil(txn as? MPPaymentData.CardSave)
    }
}

private extension MPPaymentDataTests {
    func makeSUT() -> MPPaymentData.Payment {
        MPPaymentData.Payment(orderId: "order_test")
    }

    func assertNewPaymentFieldsAreNil(
        _ payment: MPPaymentData.Payment,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertNil(payment.orderStatusDetail, file: file, line: line)
    }
}
