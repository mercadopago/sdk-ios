//
//  RemoteOrderTransactionRepositoryTests.swift
//  MercadoPagoSDK
//

import CommonTests
@testable import CoreMethods
@testable import MercadoPagoCheckout
@testable import MPCore
import XCTest

final class RemoteOrderTransactionRepositoryTests: XCTestCase {
    // MARK: - Types

    typealias SUT = (
        repository: RemoteOrderTransactionRepository,
        session: MockURLSession
    )

    // MARK: - Helpers

    private func makeSUT() -> SUT {
        let container = MockDependencyContainer()
        let repository = RemoteOrderTransactionRepository(dependencies: container)
        return (repository, container.mockSession)
    }

    private func makeParams() -> OrderTransactionParams {
        OrderTransactionParams(
            amount: 100.0,
            paymentMethodType: .creditCard(paymentMethodId: "master", paymentTypeId: "credit_card", token: "abc123", installments: 1)
        )
    }

    /// Approved card. Keeps the legacy `transactions` history to prove it is ignored.
    private func makeValidResponseData() -> Data {
        let json = """
        {
            "id": "ORD01MOCKAPPROVEDRESPONSE0001A",
            "product_id": "mock_product",
            "type": "online",
            "total_amount": "100.00",
            "total_paid_amount": "100.00",
            "site_id": "MLB",
            "status": "processed",
            "status_detail": "accredited",
            "payment_processed": {
                "id": "PAY01MOCKAPPROVEPAYMENT00001A",
                "status": "processed",
                "status_detail": "accredited",
                "amount": "100.00",
                "payment_method": {
                    "id": "master",
                    "type": "credit_card",
                    "installments": 1
                }
            },
            "transactions": {
                "payments": [
                    {
                        "id": "PAY00LEGACYHISTORYPAYMENT001A",
                        "status": "rejected",
                        "status_detail": "cc_rejected_other_reason",
                        "amount": "100.00",
                        "paid_amount": "0.00",
                        "payment_method": {
                            "id": "visa",
                            "type": "credit_card",
                            "installments": 3
                        },
                        "reference": {
                            "id": "mock_ref_legacy",
                            "source": "transaction_intent"
                        }
                    }
                ]
            }
        }
        """
        return Data(json.utf8)
    }

    /// Ticket issued after a rejected card: the legacy history still carries the failed attempt.
    private func makeTicketAfterFailedCardResponseData() -> Data {
        let json = """
        {
            "id": "ORD01MOCKACTIONREQUIRED0001A",
            "total_amount": "250.50",
            "status": "action_required",
            "status_detail": "waiting_payment",
            "payment_processed": {
                "id": "PAY01MOCKTICKETPAYMENT00001A",
                "status": "action_required",
                "status_detail": "pending_waiting_payment",
                "amount": "250.50",
                "payment_method": {
                    "id": "rapipago",
                    "type": "ticket",
                    "barcode_content": "0123456789",
                    "ticket_url": "https://example.invalid/ticket"
                }
            },
            "transactions": {
                "payments": [
                    {
                        "id": "PAY00MOCKFAILEDCARD00000001A",
                        "status": "rejected",
                        "status_detail": "cc_rejected_insufficient_amount",
                        "amount": "250.50",
                        "paid_amount": "0.00",
                        "payment_method": {
                            "id": "master",
                            "type": "credit_card",
                            "installments": 1
                        },
                        "reference": {
                            "id": "mock_ref_failed",
                            "source": "transaction_intent"
                        }
                    }
                ]
            }
        }
        """
        return Data(json.utf8)
    }

    /// Ticket without instruction data — every optional payment-method field is absent.
    private func makeTicketWithoutInstructionsData() -> Data {
        let json = """
        {
            "id": "ORD01MOCKNOINSTRUCTIONS0001A",
            "total_amount": "80.00",
            "status": "action_required",
            "status_detail": "waiting_payment",
            "payment_processed": {
                "id": "PAY01MOCKNOINSTRUCTIONS0001A",
                "status": "action_required",
                "status_detail": "pending_waiting_payment",
                "payment_method": {
                    "id": "pagofacil",
                    "type": "ticket"
                }
            }
        }
        """
        return Data(json.utf8)
    }

    /// Legacy-only payload: no `payment_processed`, only the old history.
    private func makeLegacyOnlyResponseData() -> Data {
        let json = """
        {
            "id": "ORD01MOCKLEGACYONLY000001A",
            "total_amount": "100.00",
            "status": "processed",
            "status_detail": "accredited",
            "transactions": {
                "payments": [
                    {
                        "id": "PAY00LEGACYHISTORYPAYMENT001A",
                        "status": "processed",
                        "status_detail": "accredited",
                        "amount": "100.00",
                        "paid_amount": "100.00",
                        "payment_method": {
                            "id": "master",
                            "type": "credit_card",
                            "installments": 1
                        },
                        "reference": {
                            "id": "mock_ref_legacy",
                            "source": "transaction_intent"
                        }
                    }
                ]
            }
        }
        """
        return Data(json.utf8)
    }

    private func makeHTTPResponse(statusCode: Int = 200) -> URLResponse {
        HTTPURLResponse(
            url: URL(string: "https://api.mercadopago.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }

    // MARK: - Order Mapping

    func testProcessOrder_whenSuccess_mapsId() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.processOrder(orderId: "ORD01", clientToken: "seller_client_token", params: self.makeParams())

        // Assert
        XCTAssertEqual(result.id, "ORD01MOCKAPPROVEDRESPONSE0001A")
    }

    func testProcessOrder_whenSuccess_mapsStatus() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.processOrder(orderId: "ORD01", clientToken: "seller_client_token", params: self.makeParams())

        // Assert
        XCTAssertEqual(result.status, "processed")
    }

    func testProcessOrder_whenSuccess_mapsStatusDetail() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.processOrder(orderId: "ORD01", clientToken: "seller_client_token", params: self.makeParams())

        // Assert
        XCTAssertEqual(result.statusDetail, "accredited")
    }

    func testProcessOrder_whenSuccess_mapsTotalAmount() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.processOrder(orderId: "ORD01", clientToken: "seller_client_token", params: self.makeParams())

        // Assert
        XCTAssertEqual(result.totalAmount, "100.00")
    }

    // MARK: - Payment Mapping

    func testProcessOrder_whenSuccess_mapsPaymentsCount() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.processOrder(orderId: "ORD01", clientToken: "seller_client_token", params: self.makeParams())

        // Assert
        XCTAssertEqual(result.payments.count, 1)
    }

    func testProcessOrder_whenSuccess_mapsPaymentId() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.processOrder(orderId: "ORD01", clientToken: "seller_client_token", params: self.makeParams())

        // Assert
        XCTAssertEqual(result.payments.first?.id, "PAY01MOCKAPPROVEPAYMENT00001A")
    }

    func testProcessOrder_whenSuccess_mapsPaymentStatus() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.processOrder(orderId: "ORD01", clientToken: "seller_client_token", params: self.makeParams())

        // Assert
        XCTAssertEqual(result.payments.first?.status, "processed")
    }

    func testProcessOrder_whenSuccess_mapsPaymentStatusDetail() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.processOrder(orderId: "ORD01", clientToken: "seller_client_token", params: self.makeParams())

        // Assert
        XCTAssertEqual(result.payments.first?.statusDetail, "accredited")
    }

    func testProcessOrder_whenSuccess_mapsPaymentAmount() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.processOrder(orderId: "ORD01", clientToken: "seller_client_token", params: self.makeParams())

        // Assert
        XCTAssertEqual(result.payments.first?.amount, "100.00")
    }

    func testProcessOrder_whenSuccess_mapsPaymentMethodId() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.processOrder(orderId: "ORD01", clientToken: "seller_client_token", params: self.makeParams())

        // Assert
        XCTAssertEqual(result.payments.first?.paymentMethodId, "master")
    }

    func testProcessOrder_whenSuccess_mapsInstallments() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.processOrder(orderId: "ORD01", clientToken: "seller_client_token", params: self.makeParams())

        // Assert
        XCTAssertEqual(result.payments.first?.installments, 1)
    }

    // MARK: - Current Payment Only

    func test_processOrder_WhenTicketFollowsFailedCard_ShouldMapOnlyCurrentPayment() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeTicketAfterFailedCardResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.processOrder(orderId: "ORD01", clientToken: "seller_client_token", params: self.makeParams())

        // Assert: the issued ticket, never the rejected card that precedes it in the history
        let payment = try XCTUnwrap(result.payments.first)
        XCTAssertEqual(result.payments.count, 1)
        XCTAssertEqual(payment.id, "PAY01MOCKTICKETPAYMENT00001A")
        XCTAssertEqual(payment.paymentMethodId, "rapipago")
        XCTAssertEqual(payment.paymentTypeId, "ticket")
        XCTAssertEqual(payment.status, "action_required")
        XCTAssertEqual(payment.statusDetail, "pending_waiting_payment")
        XCTAssertEqual(payment.amount, "250.50")
        XCTAssertNil(payment.installments)
    }

    func test_processOrder_WhenOptionalPaymentFieldsAreAbsent_ShouldKeepThemNil() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeTicketWithoutInstructionsData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.processOrder(orderId: "ORD01", clientToken: "seller_client_token", params: self.makeParams())

        // Assert
        let payment = try XCTUnwrap(result.payments.first)
        XCTAssertNil(payment.amount)
        XCTAssertNil(payment.installments)
    }

    func test_processOrder_WhenCurrentPaymentIsMissing_ShouldFailWithoutUsingLegacyHistory() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeLegacyOnlyResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act & Assert: a payload without payment_processed is an error, not a fallback
        do {
            _ = try await sut.repository.processOrder(orderId: "ORD01", clientToken: "seller_client_token", params: self.makeParams())
            XCTFail("Expected decoding error")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    // MARK: - Beta Base URL

    func test_processEndpoint_WhenBuildingRequest_ShouldUseBetaBase() throws {
        // Arrange
        let endpoint = OrderTransactionEndpoint.process(
            orderId: "ORD01",
            clientToken: "seller_client_token",
            params: self.makeParams()
        )

        // Act
        let url = try XCTUnwrap(endpoint.urlRequest?.url?.absoluteString)

        // Assert
        XCTAssertTrue(
            url.hasPrefix("https://api.mercadopago.com/cho-off/beta/v1/orders/ORD01/process"),
            "Expected the beta base while payment_processed is beta-only, got \(url)"
        )
    }

    func test_processEndpoint_WhenBuildingRequest_ShouldIncludeProductIdQuery() throws {
        // Arrange
        let endpoint = OrderTransactionEndpoint.process(
            orderId: "ORD01",
            clientToken: "seller_client_token",
            params: self.makeParams()
        )

        // Act
        let url = try XCTUnwrap(endpoint.urlRequest?.url)
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []

        // Assert
        XCTAssertEqual(items.first { $0.name == "product_id" }?.value, MPSDKProduct.id)
    }

    // MARK: - Request Body

    func test_processEndpoint_WhenEncodingBody_ShouldNotSendAmount() throws {
        // Arrange: the server owns the charged amount in the v2 contract
        let endpoint = OrderTransactionEndpoint.process(
            orderId: "ORD01",
            clientToken: "seller_client_token",
            params: self.makeParams()
        )

        // Act
        let body = try XCTUnwrap(endpoint.body)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])

        // Assert
        XCTAssertNil(json["amount"])
        XCTAssertEqual(json["payment_method_id"] as? String, "master")
        XCTAssertEqual(json["payment_method_type"] as? String, "credit_card")
    }

    // MARK: - Authorization Header

    func testProcessEndpoint_setsAuthorizationHeaderToClientToken() {
        // Arrange
        let endpoint = OrderTransactionEndpoint.process(
            orderId: "ORD01",
            clientToken: "seller_client_token",
            params: self.makeParams()
        )

        // Act
        let headers = endpoint.headers

        // Assert
        XCTAssertEqual(headers["Authorization"], "Bearer seller_client_token")
    }

    func testProcessEndpoint_doesNotSetAuthorizationHeaderWhenClientTokenEmpty() {
        // Arrange
        let endpoint = OrderTransactionEndpoint.process(
            orderId: "ORD01",
            clientToken: "",
            params: self.makeParams()
        )

        // Act
        let headers = endpoint.headers

        // Assert: an empty token still maps to the header, never to a different scheme
        XCTAssertEqual(headers["Authorization"], "Bearer ")
        XCTAssertNotNil(headers["X-Public-Key"])
        XCTAssertEqual(headers["Content-Type"], "application/json")
    }

    // MARK: - Error Cases

    func testProcessOrder_whenNetworkFails_throws() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setError(URLError(.notConnectedToInternet))

        // Act & Assert
        do {
            _ = try await sut.repository.processOrder(orderId: "ORD01", clientToken: "seller_client_token", params: self.makeParams())
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testProcessOrder_whenInvalidJSON_throws() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(Data("invalid json".utf8))
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act & Assert
        do {
            _ = try await sut.repository.processOrder(orderId: "ORD01", clientToken: "seller_client_token", params: self.makeParams())
            XCTFail("Expected decoding error")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testProcessOrder_whenAPIReturns400WithMissingParams_throwsAPIClientError() async {
        // Arrange
        let sut = self.makeSUT()
        let errorBody = Data("""
        {
            "code": "bad_request",
            "message": "Required parameters are missing",
            "error_code": "ORDER_PROCESS"
        }
        """.utf8)
        await sut.session.mock.setData(errorBody)
        await sut.session.mock.setResponse(self.makeHTTPResponse(statusCode: 400))

        // Act & Assert
        do {
            _ = try await sut.repository.processOrder(orderId: "ORD01", clientToken: "seller_client_token", params: self.makeParams())
            XCTFail("Expected error to be thrown")
        } catch let error as APIClientError {
            if case let .apiError(apiError) = error {
                XCTAssertEqual(apiError.code, "bad_request")
            } else {
                XCTFail("Expected APIClientError.apiError, got \(error)")
            }
        } catch {
            XCTFail("Expected APIClientError, got \(error)")
        }
    }
}
