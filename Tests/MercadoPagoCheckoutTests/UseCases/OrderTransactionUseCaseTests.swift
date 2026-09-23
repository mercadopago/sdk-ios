//
//  OrderTransactionUseCaseTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
@testable import MPAnalytics
@testable import MPCore
import XCTest

final class OrderTransactionUseCaseTests: XCTestCase {
    // MARK: - Types

    typealias SUT = (
        useCase: OrderTransactionUseCase,
        repository: MockOrderTransactionRepository
    )

    // MARK: - Helpers

    private func makeSUT(
        feature: OrderTransactionParams.IntegrationData.Feature = .payment,
        hostAppIdentifier: String = "com.example.host"
    ) -> SUT {
        let repository = MockOrderTransactionRepository()
        let useCase = OrderTransactionUseCase(
            repository: repository,
            feature: feature,
            hostAppIdentifier: hostAppIdentifier
        )
        return (useCase, repository)
    }

    // MARK: - Traceability

    func test_execute_WhenProcessing_ShouldAttachCapturedSessionFeatureAndApp() async throws {
        let sut = self.makeSUT()
        await sut.repository.setResult(.success(self.makeProcessData()))

        _ = try await sut.useCase.execute(orderId: "ORD01", clientToken: "token", params: self.makeParams())

        let sentParams = await sut.repository.lastParams
        let integration = try XCTUnwrap(sentParams?.integrationData)
        let expectedSession = await MPAnalyticsConfiguration.shared.sessionID
        XCTAssertEqual(integration.melidataSessionId, expectedSession)
        XCTAssertEqual(integration.feature, .payment)
        XCTAssertEqual(integration.platform, "ios")
        XCTAssertEqual(integration.app, "com.example.host")
    }

    func test_execute_WhenOriginIsCardForm_ShouldAttachCardFormFeature() async throws {
        let sut = self.makeSUT(feature: .cardForm)
        await sut.repository.setResult(.success(self.makeProcessData()))

        _ = try await sut.useCase.execute(orderId: "ORD01", clientToken: "token", params: self.makeParams())

        let sentParams = await sut.repository.lastParams
        XCTAssertEqual(sentParams?.integrationData?.feature, .cardForm)
    }

    func test_execute_WhenHostAppIsEmpty_ShouldOmitAppWithoutBlocking() async throws {
        let sut = self.makeSUT(hostAppIdentifier: "")
        await sut.repository.setResult(.success(self.makeProcessData()))

        let result = try await sut.useCase.execute(orderId: "ORD01", clientToken: "token", params: self.makeParams())

        let sentParams = await sut.repository.lastParams
        let integration = try XCTUnwrap(sentParams?.integrationData)
        XCTAssertNil(integration.app)
        XCTAssertEqual(result.id, "ORD01")
    }

    private func makeParams() -> OrderTransactionParams {
        OrderTransactionParams(
            amount: 100.0,
            paymentMethodType: .creditCard(paymentMethodId: "master", paymentTypeId: "credit_card", token: "abc123", installments: 1)
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
                    paymentTypeId: "credit_card",
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
        XCTAssertEqual(lastParams?.paymentMethodType, params.paymentMethodType)
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
