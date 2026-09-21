//
//  OrderTransactionParamsTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
import XCTest

final class OrderTransactionParamsTests: XCTestCase {
    // MARK: - Helpers

    private func makeCreditParams(
        amount: Decimal = 100.0,
        paymentMethodId: String = "visa",
        token: String = "abc123",
        installments: Int = 1,
        integrationData: OrderTransactionParams.IntegrationData? = nil
    ) -> OrderTransactionParams {
        OrderTransactionParams(
            amount: amount,
            paymentMethodType: .creditCard(
                paymentMethodId: paymentMethodId,
                paymentTypeId: "credit_card",
                token: token,
                installments: installments
            ),
            integrationData: integrationData
        )
    }

    private func makeDebitParams() -> OrderTransactionParams {
        OrderTransactionParams(
            paymentMethodType: .debitCard(
                paymentMethodId: "debvisa",
                paymentTypeId: "debit_card",
                token: "tok_debit"
            )
        )
    }

    private func makeTicketParams(paymentMethodId: String = "pec") -> OrderTransactionParams {
        OrderTransactionParams(paymentMethodType: .ticket(paymentMethodId: paymentMethodId))
    }

    private func encodeToJSON(_ params: OrderTransactionParams) throws -> [String: Any] {
        let data = try JSONEncoder().encode(params)
        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    // MARK: - Amount is owned by the server

    func test_encoding_WhenCredit_ShouldNotSerializeAmount() throws {
        let json = try self.encodeToJSON(self.makeCreditParams(amount: 100.0))
        XCTAssertNil(json["amount"])
    }

    func test_amount_WhenProvided_ShouldStayAvailableLocally() {
        // The review screen still needs the local value, even though it is never sent.
        XCTAssertEqual(self.makeCreditParams(amount: 188.5).amount, 188.5)
    }

    // MARK: - Credit encoding

    func test_encoding_WhenCredit_ShouldUseSnakeCaseKeys() throws {
        let json = try self.encodeToJSON(self.makeCreditParams(paymentMethodId: "master"))
        XCTAssertEqual(json["payment_method_id"] as? String, "master")
        XCTAssertEqual(json["payment_method_type"] as? String, "credit_card")
        XCTAssertNil(json["paymentMethodId"])
    }

    func test_encoding_WhenCredit_ShouldIncludeTokenAndInstallments() throws {
        let json = try self.encodeToJSON(self.makeCreditParams(token: "tok_abc", installments: 3))
        XCTAssertEqual(json["token"] as? String, "tok_abc")
        XCTAssertEqual(json["installments"] as? Int, 3)
    }

    // MARK: - Debit encoding

    func test_encoding_WhenDebit_ShouldSendTokenWithoutInstallments() throws {
        let json = try self.encodeToJSON(self.makeDebitParams())
        XCTAssertEqual(json["payment_method_id"] as? String, "debvisa")
        XCTAssertEqual(json["payment_method_type"] as? String, "debit_card")
        XCTAssertEqual(json["token"] as? String, "tok_debit")
        XCTAssertNil(json["installments"])
    }

    // MARK: - Prepaid encoding

    func test_encoding_WhenPrepaid_ShouldKeepPrepaidWireTypeWithoutInstallments() throws {
        // The contract carries prepaid_card as its own payment_type_id — never remapped to debit.
        let params = OrderTransactionParams(
            paymentMethodType: .debitCard(
                paymentMethodId: "prepvisa",
                paymentTypeId: "prepaid_card",
                token: "tok_prepaid"
            )
        )

        let json = try self.encodeToJSON(params)

        XCTAssertEqual(json["payment_method_id"] as? String, "prepvisa")
        XCTAssertEqual(json["payment_method_type"] as? String, "prepaid_card")
        XCTAssertEqual(json["token"] as? String, "tok_prepaid")
        XCTAssertNil(json["installments"])
    }

    // MARK: - Ticket encoding

    func test_encoding_WhenTicket_ShouldUseFixedTypeWithoutCardFields() throws {
        let json = try self.encodeToJSON(self.makeTicketParams(paymentMethodId: "pec"))
        XCTAssertEqual(json["payment_method_id"] as? String, "pec")
        XCTAssertEqual(json["payment_method_type"] as? String, "ticket")
        XCTAssertNil(json["token"])
        XCTAssertNil(json["installments"])
    }

    // MARK: - Integration data

    func test_encoding_WhenIntegrationDataIsAbsent_ShouldOmitTheKey() throws {
        let json = try self.encodeToJSON(self.makeCreditParams())
        XCTAssertNil(json["integration_data"])
    }

    func test_encoding_WhenIntegrationDataIsPresent_ShouldSendSessionFeatureAndPlatform() throws {
        let params = self.makeCreditParams(
            integrationData: .init(melidataSessionId: "session-123", feature: .payment, app: "com.example.host")
        )

        let json = try self.encodeToJSON(params)
        let integration = try XCTUnwrap(json["integration_data"] as? [String: Any])

        XCTAssertEqual(integration["melidata_session_id"] as? String, "session-123")
        XCTAssertEqual(integration["feature"] as? String, "payment")
        XCTAssertEqual(integration["platform"] as? String, "ios")
        XCTAssertEqual(integration["app"] as? String, "com.example.host")
    }

    func test_encoding_WhenOriginIsCardForm_ShouldSendCardFormFeature() throws {
        let params = self.makeCreditParams(
            integrationData: .init(melidataSessionId: "session-123", feature: .cardForm, app: "com.example.host")
        )

        let json = try self.encodeToJSON(params)
        let integration = try XCTUnwrap(json["integration_data"] as? [String: Any])

        XCTAssertEqual(integration["feature"] as? String, "cardform")
    }

    func test_integrationData_WhenAppIsEmpty_ShouldTreatItAsAbsent() {
        XCTAssertNil(OrderTransactionParams.IntegrationData(melidataSessionId: "s", feature: .payment, app: "").app)
        XCTAssertNil(OrderTransactionParams.IntegrationData(melidataSessionId: "s", feature: .payment, app: nil).app)
    }

    // MARK: - init?(cardTransaction:)

    func test_init_WhenCreditWithInstallments_ShouldBuildCreditCase() throws {
        let transaction = MPPaymentData.CardTransaction(
            transactionAmount: 150,
            token: "tok_xyz",
            installment: 6,
            paymentMethodId: "visa",
            paymentTypeId: "credit_card"
        )

        let params = try XCTUnwrap(OrderTransactionParams(cardTransaction: transaction))

        XCTAssertEqual(params.amount, 150)
        guard case let .creditCard(paymentMethodId, paymentTypeId, token, installments) = params.paymentMethodType else {
            return XCTFail("Expected .creditCard case")
        }
        XCTAssertEqual(paymentMethodId, "visa")
        XCTAssertEqual(paymentTypeId, "credit_card")
        XCTAssertEqual(token, "tok_xyz")
        XCTAssertEqual(installments, 6)
    }

    func test_init_WhenCreditWithoutInstallments_ShouldReturnNil() {
        var transaction = MPPaymentData.CardTransaction(
            transactionAmount: 100,
            token: "tok_credit",
            paymentMethodId: "visa",
            paymentTypeId: "credit_card"
        )
        transaction.installment = nil

        XCTAssertNil(OrderTransactionParams(cardTransaction: transaction))
    }

    func test_init_WhenCreditInstallmentsAreNotPositive_ShouldReturnNil() {
        let transaction = MPPaymentData.CardTransaction(
            transactionAmount: 100,
            token: "tok_credit",
            installment: 0,
            paymentMethodId: "visa",
            paymentTypeId: "credit_card"
        )

        XCTAssertNil(OrderTransactionParams(cardTransaction: transaction))
    }

    func test_init_WhenDebit_ShouldBuildDebitCaseWithoutInstallments() throws {
        var transaction = MPPaymentData.CardTransaction(
            transactionAmount: 100,
            token: "tok_debit",
            paymentMethodId: "debvisa",
            paymentTypeId: "debit_card"
        )
        transaction.installment = nil

        let params = try XCTUnwrap(OrderTransactionParams(cardTransaction: transaction))

        guard case let .debitCard(paymentMethodId, paymentTypeId, token) = params.paymentMethodType else {
            return XCTFail("Expected .debitCard case")
        }
        XCTAssertEqual(paymentMethodId, "debvisa")
        XCTAssertEqual(paymentTypeId, "debit_card")
        XCTAssertEqual(token, "tok_debit")
    }

    func test_init_WhenPrepaid_ShouldBuildCardCaseWithoutInstallments() throws {
        var transaction = MPPaymentData.CardTransaction(
            transactionAmount: 100,
            token: "tok_prepaid",
            paymentMethodId: "prepvisa",
            paymentTypeId: "prepaid_card"
        )
        transaction.installment = nil

        let params = try XCTUnwrap(OrderTransactionParams(cardTransaction: transaction))

        guard case let .debitCard(_, paymentTypeId, _) = params.paymentMethodType else {
            return XCTFail("Expected the no-installments card case")
        }
        XCTAssertEqual(paymentTypeId, "prepaid_card")
        XCTAssertNil(params.paymentMethodType.installments)
    }

    func test_installments_ShouldOnlyBeReportedForCredit() {
        XCTAssertEqual(self.makeCreditParams(installments: 6).paymentMethodType.installments, 6)
        XCTAssertNil(self.makeDebitParams().paymentMethodType.installments)
        XCTAssertNil(self.makeTicketParams().paymentMethodType.installments)
    }

    func test_init_WhenPaymentTypeIsUnknown_ShouldReturnNil() {
        let transaction = MPPaymentData.CardTransaction(
            transactionAmount: 100,
            token: "tok",
            installment: 1,
            paymentMethodId: "pix",
            paymentTypeId: "bank_transfer"
        )

        XCTAssertNil(OrderTransactionParams(cardTransaction: transaction))
    }

    func test_init_WhenTransactionAmountIsNil_ShouldFallBackToZero() throws {
        var transaction = MPPaymentData.CardTransaction(
            token: "tok_debit",
            paymentMethodId: "debvisa",
            paymentTypeId: "debit_card"
        )
        transaction.transactionAmount = nil

        let params = try XCTUnwrap(OrderTransactionParams(cardTransaction: transaction))

        XCTAssertEqual(params.amount, .zero)
    }
}
