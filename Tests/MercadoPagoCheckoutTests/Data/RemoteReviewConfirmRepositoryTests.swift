//
//  RemoteReviewConfirmRepositoryTests.swift
//  MercadoPagoSDK
//

import CommonTests
@testable import MercadoPagoCheckout
@testable import MPCore
import XCTest

final class RemoteReviewConfirmRepositoryTests: XCTestCase {
    // MARK: - Types

    typealias SUT = (
        repository: RemoteReviewConfirmRepository,
        session: MockURLSession
    )

    // MARK: - Helpers

    private let clientToken = "seller_client_token"

    private func makeSUT() -> SUT {
        let container = MockDependencyContainer()
        let repository = RemoteReviewConfirmRepository(dependencies: container)
        return (repository, container.mockSession)
    }

    private func makeRequest() -> ReviewConfirmRequestBody {
        ReviewConfirmRequestBody(
            orderId: "ORDER-1",
            paymentMethodType: "credit_card",
            paymentMethodId: "visa",
            issuerId: "santander",
            bin: "453998",
            productId: "BT7L8CCEVKKG01NFMI70",
            lastFourDigits: "4567",
            installments: 3,
            installmentAmount: "10.00",
            emailChangeEnabled: false,
            sellerInfo: nil
        )
    }

    private func makeValidResponseData() -> Data {
        let json = """
        {
          "header": { "title": "Revisá los datos antes de pagar" },
          "items": [
            {
              "type": "payment_method",
              "label": "Medio de pago",
              "value": "Santander •••• 4567",
              "change_label": "Modificar"
            }
          ],
          "footer": { "button": { "label": "Pagar" }, "total_amount": "$ 110" }
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

    // MARK: - Success

    func testFetchReviewConfirm_whenSuccess_mapsHeaderTitle() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchReviewConfirm(
            request: self.makeRequest(),
            clientToken: self.clientToken
        )

        // Assert
        XCTAssertEqual(result.header.title, "Revisá los datos antes de pagar")
    }

    func testFetchReviewConfirm_whenSuccess_mapsItems() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchReviewConfirm(
            request: self.makeRequest(),
            clientToken: self.clientToken
        )

        // Assert
        XCTAssertEqual(result.items.first?.type, "payment_method")
        XCTAssertEqual(result.items.first?.changeLabel, "Modificar")
    }

    func testFetchReviewConfirm_whenSuccess_mapsFooter() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchReviewConfirm(
            request: self.makeRequest(),
            clientToken: self.clientToken
        )

        // Assert
        XCTAssertEqual(result.footer.button.label, "Pagar")
        XCTAssertEqual(result.footer.totalAmount, "$ 110")
    }

    // MARK: - Request body

    func testEndpoint_encodesRequestBodyWithOrderIdAndPaymentMethodFields() throws {
        // Arrange
        let endpoint = ReviewConfirmEndpoint(clientToken: self.clientToken, requestBody: self.makeRequest())

        // Act
        let body = try XCTUnwrap(endpoint.body)
        let json = try XCTUnwrap(try JSONSerialization.jsonObject(with: body) as? [String: Any])

        // Assert
        XCTAssertEqual(json["order_id"] as? String, "ORDER-1")
        XCTAssertEqual(json["payment_method_type"] as? String, "credit_card")
        XCTAssertEqual(json["bin"] as? String, "453998")
        XCTAssertEqual(json["product_id"] as? String, "BT7L8CCEVKKG01NFMI70")
        XCTAssertEqual(json["email_change_enabled"] as? Bool, false)
    }

    // MARK: - Authorization Header

    func testEndpoint_setsAuthorizationHeaderToClientToken() {
        // Arrange
        let endpoint = ReviewConfirmEndpoint(clientToken: self.clientToken, requestBody: self.makeRequest())

        // Act
        let headers = endpoint.headers

        // Assert
        XCTAssertEqual(headers["Authorization"], "Bearer seller_client_token")
        XCTAssertEqual(headers["Content-Type"], "application/json")
    }

    // MARK: - Error Cases

    func testFetchReviewConfirm_whenNetworkFails_throws() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setError(URLError(.notConnectedToInternet))

        // Act & Assert
        do {
            _ = try await sut.repository.fetchReviewConfirm(request: self.makeRequest(), clientToken: self.clientToken)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testFetchReviewConfirm_whenAPIReturns400_throwsAPIClientError() async {
        // Arrange
        let sut = self.makeSUT()
        let errorBody = Data("""
        {
            "code": "bad_request",
            "message": "Required parameters are missing",
            "error_code": "REVIEW_CONFIRM"
        }
        """.utf8)
        await sut.session.mock.setData(errorBody)
        await sut.session.mock.setResponse(self.makeHTTPResponse(statusCode: 400))

        // Act & Assert
        do {
            _ = try await sut.repository.fetchReviewConfirm(request: self.makeRequest(), clientToken: self.clientToken)
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
