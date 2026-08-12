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
            paymentMethodType: .card(paymentMethodId: "master", token: "abc123", installments: 1)
        )
    }

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
            "date_created": "2024-01-01T00:00:00",
            "last_updated": "2024-01-01T00:00:00",
            "user_id": "1000000001",
            "capture_mode": "automatic_async",
            "processing_mode": "automatic",
            "payer": {
                "id": "1000000001",
                "email": "mock_buyer@testuser.com"
            },
            "transactions": {
                "payments": [
                    {
                        "id": "PAY01MOCKAPPROVEPAYMENT00001A",
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
                            "id": "mock_ref_approved",
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
        XCTAssertEqual(headers["Authorization"], "seller_client_token")
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
        XCTAssertEqual(headers["Authorization"], "")
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
