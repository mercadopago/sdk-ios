//
//  CardFormBrickViewModelTrackingTests.swift
//  MercadoPagoSDK
//

import CommonTests
import Foundation
@testable import MercadoPagoCheckout
import XCTest

@MainActor
final class CardFormBrickViewModelTrackingTests: XCTestCase {
    // MARK: - Types

    typealias SUT = (
        viewModel: CardFormBrickViewModel<MPPaymentData.CardSave>,
        repository: MockCardFormInitializationRepository,
        analytics: MockAnalytics,
        errorObservability: MockErrorObservability
    )

    // MARK: - Helpers

    private func makeSUT(
        appearance: MPCheckoutAppearance = .init()
    ) -> SUT {
        let repository = MockCardFormInitializationRepository()
        let useCase = InitializeCardFormUseCase(repository: repository)
        let analytics = MockAnalytics()
        let errorObservability = MockErrorObservability(eventID: "checkout-event")
        let configuration = MPCheckoutConfiguration<MPPaymentData.CardSave>(
            type: .saveCard,
            paymentMethod: [.card()]
        )
        let viewModel = CardFormBrickViewModel<MPPaymentData.CardSave>(
            configuration: configuration,
            appearance: appearance,
            initializeUseCase: useCase,
            analytics: analytics,
            errorObservability: errorObservability
        )
        return (viewModel, repository, analytics, errorObservability)
    }

    // MARK: - trackInitialize

    func test_load_whenSuccess_shouldTrackInitializeEvent() async throws {
        // Arrange
        let sut = self.makeSUT()

        // Act
        try await sut.viewModel.load()
        await sut.analytics.mock.waitForSend()

        // Assert
        let messages = await sut.analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.track(path: CardFormAnalyticsPath.initialize)))
        XCTAssertTrue(messages.contains(.send))
    }

    func test_load_whenSuccess_shouldNotTrackInitializeError() async throws {
        // Arrange
        let sut = self.makeSUT()

        // Act
        try await sut.viewModel.load()
        await sut.analytics.mock.waitForSend()

        // Assert
        let messages = await sut.analytics.mock.getMessages()
        XCTAssertFalse(messages.contains(.track(path: CardFormAnalyticsPath.initializeError)))
    }

    // MARK: - trackInitializeError

    func test_load_whenFailure_shouldTrackInitializeErrorEvent() async {
        // Arrange
        let sut = self.makeSUT()
        sut.repository.shouldThrow = true

        // Act
        do {
            try await sut.viewModel.load()
            XCTFail("Expected load to throw")
        } catch {}

        await sut.analytics.mock.waitForSend()

        // Assert
        let messages = await sut.analytics.mock.getMessages()
        let eventIDs = await sut.analytics.mock.getObservabilityEventIDs()
        XCTAssertTrue(messages.contains(.track(path: CardFormAnalyticsPath.initializeError)))
        XCTAssertTrue(messages.contains(.send))
        XCTAssertEqual(eventIDs, ["checkout-event"])
        XCTAssertEqual(sut.errorObservability.recordedErrors().map(\.operation), [.cardFormInitialization])
    }

    func test_load_whenFailure_shouldTrackUnknownErrorType() async {
        // Arrange
        let sut = self.makeSUT()
        sut.repository.shouldThrow = true

        // Act
        do {
            try await sut.viewModel.load()
            XCTFail("Expected load to throw")
        } catch {}

        await sut.analytics.mock.waitForSend()

        // Assert
        let messages = await sut.analytics.mock.getMessages()
        let expectedData: [String: any Sendable] = ["error_type": "unknown_error"]
        XCTAssertTrue(messages.contains(.setEventData(expectedData)))
    }

    func test_load_whenUnexpectedErrorType_shouldTrackUnknownError() async {
        // Non-APIClientError thrown from repository gets wrapped as unknown_error
        // by InitializeCardFormUseCase (which only maps APIClientError explicitly).
        // Arrange
        let sut = self.makeSUT()
        sut.repository.sequentialResults = [
            .failure(NSError(domain: "custom", code: 42)),
            .failure(NSError(domain: "custom", code: 42))
        ]

        // Act
        do {
            try await sut.viewModel.load()
            XCTFail("Expected load to throw")
        } catch {}

        await sut.analytics.mock.waitForSend()

        // Assert
        let messages = await sut.analytics.mock.getMessages()
        let expectedData: [String: any Sendable] = ["error_type": "unknown_error"]
        XCTAssertTrue(messages.contains(.setEventData(expectedData)))
    }

    // MARK: - trackOrderError

    func test_processOrderFailure_shouldPreserveErrorAndCorrelateOrderEvent() async {
        let order = MPOrder(orderId: "order-99", clientToken: "seller_client_token")
        let configuration = MPCheckoutConfiguration<MPPaymentData.CardTransaction>(
            type: .cardTransaction(order: order),
            paymentMethod: [.card()]
        )
        let repository = MockOrderTransactionRepository()
        let original = MercadoPagoCheckoutError(
            code: .serviceError,
            localizedDescription: "unchanged",
            userInfo: ["status_code": 500],
            location: .orderProcess
        )
        await repository.setResult(.failure(original))
        let analytics = MockAnalytics()
        let observability = MockErrorObservability(eventID: "checkout-event")
        let viewModel = CardFormBrickViewModel<MPPaymentData.CardTransaction>(
            configuration: configuration,
            initializeUseCase: InitializeCardFormUseCase(repository: MockCardFormInitializationRepository()),
            orderUseCase: OrderTransactionUseCase(repository: repository),
            analytics: analytics,
            errorObservability: observability
        )
        let paymentData = MPPaymentData.CardTransaction(
            transactionAmount: 100,
            token: "token",
            installment: 1,
            paymentMethodId: "visa",
            paymentTypeId: "credit_card",
            orderId: "order-99"
        )

        do {
            _ = try await viewModel.processOrderTask(paymentData)
            XCTFail("Expected original error")
        } catch {
            XCTAssertEqual(error.code, original.code)
            XCTAssertEqual(error.errorDescription, original.errorDescription)
        }
        await analytics.mock.waitForSend()

        XCTAssertEqual(observability.recordedErrors().map(\.operation), [.orderSubmission])
        let eventIDs = await analytics.mock.getObservabilityEventIDs()
        XCTAssertEqual(eventIDs, ["checkout-event"])
    }
}
