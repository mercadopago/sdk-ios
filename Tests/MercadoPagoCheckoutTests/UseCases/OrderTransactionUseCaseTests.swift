//
//  OrderTransactionUseCaseTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
@testable import MPCore
import XCTest

final class OrderTransactionUseCaseTests: XCTestCase {
    // MARK: - Types

    typealias SUT = (
        useCase: OrderTransactionUseCase,
        repository: MockOrderTransactionRepository
    )

    // MARK: - Helpers

    private func makeSUT() -> SUT {
        let repository = MockOrderTransactionRepository()
        let useCase = OrderTransactionUseCase(repository: repository)
        return (useCase, repository)
    }

    private func makeParams() -> OrderTransactionParams {
        OrderTransactionParams(
            amount: 100.0,
            paymentMethodId: "master",
            paymentMethodType: "credit_card",
            token: "abc123",
            installments: 1
        )
    }

    private func makeProcessData(
        id: String = "ORD01",
        status: String = "processed",
        statusDetail: String = "accredited",
        totalAmount: String = "100.00"
    ) -> OrderTransactionProcessData {
        OrderTransactionProcessData(
            id: id,
            status: status,
            statusDetail: statusDetail,
            totalAmount: totalAmount,
            payments: [
                OrderTransactionProcessData.Payment(
                    id: "PAY01",
                    status: "processed",
                    statusDetail: "accredited",
                    amount: "100.00",
                    paymentMethodId: "master",
                    installments: 1
                )
            ]
        )
    }

    // MARK: - Success

    func test_execute_whenRepositorySucceeds_returnsData() async throws {
        let sut = self.makeSUT()
        let expected = self.makeProcessData()
        await sut.repository.setResult(.success(expected))

        let result = try await sut.useCase.execute(orderId: "ORD01", clientToken: "token", params: self.makeParams())

        XCTAssertEqual(result.id, expected.id)
        XCTAssertEqual(result.status, expected.status)
        XCTAssertEqual(result.statusDetail, expected.statusDetail)
        XCTAssertEqual(result.totalAmount, expected.totalAmount)
    }

    func test_execute_passesOrderIdToRepository() async throws {
        let sut = self.makeSUT()
        await sut.repository.setResult(.success(self.makeProcessData()))

        _ = try await sut.useCase.execute(orderId: "ORD-EXPECTED-123", clientToken: "token", params: self.makeParams())

        let lastOrderId = await sut.repository.lastOrderId
        XCTAssertEqual(lastOrderId, "ORD-EXPECTED-123")
    }

    func test_execute_passesClientTokenToRepository() async throws {
        let sut = self.makeSUT()
        await sut.repository.setResult(.success(self.makeProcessData()))

        _ = try await sut.useCase.execute(orderId: "ORD01", clientToken: "seller_client_token", params: self.makeParams())

        let lastClientToken = await sut.repository.lastClientToken
        XCTAssertEqual(lastClientToken, "seller_client_token")
    }

    func test_execute_passesParamsToRepository() async throws {
        let sut = self.makeSUT()
        let params = self.makeParams()
        await sut.repository.setResult(.success(self.makeProcessData()))

        _ = try await sut.useCase.execute(orderId: "ORD01", clientToken: "token", params: params)

        let lastParams = await sut.repository.lastParams
        XCTAssertEqual(lastParams?.amount, params.amount)
        XCTAssertEqual(lastParams?.installments, params.installments)
    }

    // MARK: - Error Propagation

    func test_execute_whenRepositoryThrowsMercadoPagoCheckoutError_propagatesSameError() async {
        let sut = self.makeSUT()
        let originalError = MercadoPagoCheckoutError(
            code: .serviceError,
            localizedDescription: "service error",
            location: .orderProcess
        )
        await sut.repository.setResult(.failure(originalError))

        do {
            _ = try await sut.useCase.execute(orderId: "ORD01", clientToken: "token", params: self.makeParams())
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error.code, .serviceError)
            XCTAssertEqual(error.locationDescription, MercadoPagoCheckoutError.LocationDescription.orderProcess.rawValue)
        }
    }

    func test_execute_whenRepositoryThrowsUnknownError_wrapsAsUnknown() async {
        struct SomeUnknownError: Error {}
        let sut = self.makeSUT()
        await sut.repository.setResult(.failure(SomeUnknownError()))

        do {
            _ = try await sut.useCase.execute(orderId: "ORD01", clientToken: "token", params: self.makeParams())
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error.code, .unknown)
        }
    }

    func test_execute_whenRepositoryThrowsAPIClientError_wrapsAsServiceError() async throws {
        // Arrange
        let sut = self.makeSUT()
        let errorJSON = Data("""
        {"code": "bad_request", "message": "Required parameters are missing", "error_code": "ORDER_PROCESS"}
        """.utf8)
        let apiErrorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: errorJSON)
        await sut.repository.setResult(.failure(APIClientError.apiError(apiErrorResponse)))

        // Act & Assert
        do {
            _ = try await sut.useCase.execute(orderId: "ORD01", clientToken: "token", params: self.makeParams())
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error.code, .serviceError)
            XCTAssertEqual(error.serviceError?.code, "bad_request")
        }
    }

    func test_execute_callsRepositoryExactlyOnce() async throws {
        let sut = self.makeSUT()
        await sut.repository.setResult(.success(self.makeProcessData()))

        _ = try await sut.useCase.execute(orderId: "ORD01", clientToken: "token", params: self.makeParams())

        let callCount = await sut.repository.callCount
        XCTAssertEqual(callCount, 1)
    }
}
