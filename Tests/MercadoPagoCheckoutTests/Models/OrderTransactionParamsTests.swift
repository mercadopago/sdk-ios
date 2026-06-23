//
//  OrderTransactionParamsTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
import XCTest

final class OrderTransactionParamsTests: XCTestCase {
    // MARK: - Helpers

    private func makeParams(
        amount: Decimal = 100.0,
        paymentMethodId: String = "visa",
        paymentMethodType: String = "credit_card",
        token: String = "abc123",
        installments: Int = 1
    ) -> OrderTransactionParams {
        OrderTransactionParams(
            amount: amount,
            paymentMethodId: paymentMethodId,
            paymentMethodType: paymentMethodType,
            token: token,
            installments: installments
        )
    }

    private func encodeToJSON(_ params: OrderTransactionParams) throws -> [String: Any] {
        let data = try JSONEncoder().encode(params)
        return try JSONSerialization.jsonObject(with: data) as! [String: Any]
    }

    // MARK: - Amount Encoding

    func testEncoding_amountInteger_formatsToTwoDecimalPlaces() throws {
        let json = try encodeToJSON(makeParams(amount: 100.0))
        XCTAssertEqual(json["amount"] as? String, "100.00")
    }

    func testEncoding_amountWithOneDecimal_formatsToTwoDecimalPlaces() throws {
        let json = try encodeToJSON(makeParams(amount: 99.9))
        XCTAssertEqual(json["amount"] as? String, "99.90")
    }

    func testEncoding_amountWithTwoDecimals_preservesValue() throws {
        let json = try encodeToJSON(makeParams(amount: 10.90))
        XCTAssertEqual(json["amount"] as? String, "10.90")
    }

    func testEncoding_amountDecimalSum_doesNotProduceRoundingArtifacts() throws {
        let amount: Decimal = 0.1 + 0.2
        let json = try encodeToJSON(makeParams(amount: amount))
        XCTAssertEqual(json["amount"] as? String, "0.30")
    }

    func testEncoding_amountZero_formatsCorrectly() throws {
        let json = try encodeToJSON(makeParams(amount: 0.0))
        XCTAssertEqual(json["amount"] as? String, "0.00")
    }

    // MARK: - CodingKeys (snake_case)

    func testEncoding_paymentMethodId_usesSnakeCaseKey() throws {
        let json = try encodeToJSON(makeParams(paymentMethodId: "master"))
        XCTAssertEqual(json["payment_method_id"] as? String, "master")
        XCTAssertNil(json["paymentMethodId"])
    }

    func testEncoding_paymentMethodType_usesSnakeCaseKey() throws {
        let json = try encodeToJSON(makeParams(paymentMethodType: "credit_card"))
        XCTAssertEqual(json["payment_method_type"] as? String, "credit_card")
        XCTAssertNil(json["paymentMethodType"])
    }

    func testEncoding_token_preservesValue() throws {
        let json = try encodeToJSON(makeParams(token: "tok_abc"))
        XCTAssertEqual(json["token"] as? String, "tok_abc")
    }

    func testEncoding_installments_encodesAsInt() throws {
        let json = try encodeToJSON(makeParams(installments: 3))
        XCTAssertEqual(json["installments"] as? Int, 3)
    }

    // MARK: - init?(cardTransaction:)

    func testInit_cardTransaction_whenAllFieldsPresent_returnsParams() {
        let transaction = MPPaymentData.CardTransaction(
            transactionAmount: 150,
            token: "tok_xyz",
            installment: 6,
            paymentMethodId: "visa",
            paymentTypeId: "credit_card"
        )

        let params = OrderTransactionParams(cardTransaction: transaction)

        XCTAssertNotNil(params)
        XCTAssertEqual(params?.amount, 150)
        XCTAssertEqual(params?.token, "tok_xyz")
        XCTAssertEqual(params?.installments, 6)
        XCTAssertEqual(params?.paymentMethodId, "visa")
        XCTAssertEqual(params?.paymentMethodType, "credit_card")
    }

    func testInit_cardTransaction_whenTransactionAmountNil_returnsNil() {
        var transaction = MPPaymentData.CardTransaction()
        transaction.transactionAmount = nil

        let params = OrderTransactionParams(cardTransaction: transaction)

        XCTAssertNil(params)
    }

    func testInit_cardTransaction_whenInstallmentNil_returnsNil() {
        var transaction = MPPaymentData.CardTransaction(transactionAmount: 100)
        transaction.installment = nil

        let params = OrderTransactionParams(cardTransaction: transaction)

        XCTAssertNil(params)
    }

    func testInit_cardTransaction_mapsPaymentTypeIdToPaymentMethodType() {
        let transaction = MPPaymentData.CardTransaction(
            transactionAmount: 100,
            installment: 1,
            paymentMethodId: "master",
            paymentTypeId: "debit_card"
        )

        let params = OrderTransactionParams(cardTransaction: transaction)

        XCTAssertEqual(params?.paymentMethodType, "debit_card")
    }
}
