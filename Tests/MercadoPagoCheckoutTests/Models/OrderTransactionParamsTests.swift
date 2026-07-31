//
//  OrderTransactionParamsTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
import XCTest

final class OrderTransactionParamsTests: XCTestCase {
    // MARK: - Helpers

    private func makeCardParams(
        amount: Decimal = 100.0,
        paymentMethodId: String = "visa",
        paymentTypeId: String = "credit_card",
        token: String = "abc123",
        installments: Int = 1
    ) -> OrderTransactionParams {
        OrderTransactionParams(
            amount: amount,
            paymentMethodType: .card(paymentMethodId: paymentMethodId, paymentTypeId: paymentTypeId, token: token, installments: installments)
        )
    }

    private func makeTicketParams(
        amount: Decimal = 100.0,
        paymentMethodId: String = "pec"
    ) -> OrderTransactionParams {
        OrderTransactionParams(
            amount: amount,
            paymentMethodType: .ticket(paymentMethodId: paymentMethodId)
        )
    }

    private func encodeToJSON(_ params: OrderTransactionParams) throws -> [String: Any] {
        let data = try JSONEncoder().encode(params)
        return try JSONSerialization.jsonObject(with: data) as! [String: Any]
    }

    // MARK: - Amount Encoding

    func testEncoding_amountInteger_formatsToTwoDecimalPlaces() throws {
        let json = try encodeToJSON(makeCardParams(amount: 100.0))
        XCTAssertEqual(json["amount"] as? String, "100.00")
    }

    func testEncoding_amountWithOneDecimal_formatsToTwoDecimalPlaces() throws {
        let json = try encodeToJSON(makeCardParams(amount: 99.9))
        XCTAssertEqual(json["amount"] as? String, "99.90")
    }

    func testEncoding_amountWithTwoDecimals_preservesValue() throws {
        let json = try encodeToJSON(makeCardParams(amount: 10.90))
        XCTAssertEqual(json["amount"] as? String, "10.90")
    }

    func testEncoding_amountDecimalSum_doesNotProduceRoundingArtifacts() throws {
        let amount: Decimal = 0.1 + 0.2
        let json = try encodeToJSON(makeCardParams(amount: amount))
        XCTAssertEqual(json["amount"] as? String, "0.30")
    }

    func testEncoding_amountZero_formatsCorrectly() throws {
        let json = try encodeToJSON(makeCardParams(amount: 0.0))
        XCTAssertEqual(json["amount"] as? String, "0.00")
    }

    // MARK: - Card encoding

    func testEncoding_card_paymentMethodId_usesSnakeCaseKey() throws {
        let json = try encodeToJSON(makeCardParams(paymentMethodId: "master"))
        XCTAssertEqual(json["payment_method_id"] as? String, "master")
        XCTAssertNil(json["paymentMethodId"])
    }

    func testEncoding_card_token_preservesValue() throws {
        let json = try encodeToJSON(makeCardParams(token: "tok_abc"))
        XCTAssertEqual(json["token"] as? String, "tok_abc")
    }

    func testEncoding_card_installments_encodesAsInt() throws {
        let json = try encodeToJSON(makeCardParams(installments: 3))
        XCTAssertEqual(json["installments"] as? Int, 3)
    }

    // MARK: - Ticket encoding

    func testEncoding_ticket_paymentMethodId_usesSnakeCaseKey() throws {
        let json = try encodeToJSON(makeTicketParams(paymentMethodId: "pec"))
        XCTAssertEqual(json["payment_method_id"] as? String, "pec")
        XCTAssertNil(json["paymentMethodId"])
    }

    func testEncoding_ticket_doesNotIncludeTokenOrInstallments() throws {
        let json = try encodeToJSON(makeTicketParams())
        XCTAssertNil(json["token"])
        XCTAssertNil(json["installments"])
        XCTAssertNil(json["payment_method_type"])
    }

    func testEncoding_ticket_amountInteger_formatsToTwoDecimalPlaces() throws {
        let json = try encodeToJSON(makeTicketParams(amount: 50.0))
        XCTAssertEqual(json["amount"] as? String, "50.00")
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
        guard case let .card(paymentMethodId, paymentTypeId, token, installments) = params?.paymentMethodType else {
            return XCTFail("Expected .card case")
        }
        XCTAssertEqual(paymentMethodId, "visa")
        XCTAssertEqual(paymentTypeId, "credit_card")
        XCTAssertEqual(token, "tok_xyz")
        XCTAssertEqual(installments, 6)
    }

    func testInit_cardTransaction_whenTransactionAmountNil_returnsNil() {
        var transaction = MPPaymentData.CardTransaction()
        transaction.transactionAmount = nil

        XCTAssertNil(OrderTransactionParams(cardTransaction: transaction))
    }

    func testInit_cardTransaction_whenInstallmentNil_returnsNil() {
        var transaction = MPPaymentData.CardTransaction(transactionAmount: 100)
        transaction.installment = nil

        XCTAssertNil(OrderTransactionParams(cardTransaction: transaction))
    }
}
