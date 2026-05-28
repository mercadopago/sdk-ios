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
        analytics: MockAnalytics
    )

    // MARK: - Helpers

    private func makeSUT(
        appearance: MPCheckoutAppearance = .init()
    ) -> SUT {
        let repository = MockCardFormInitializationRepository()
        let useCase = InitializeCardFormUseCase(repository: repository)
        let analytics = MockAnalytics()
        let configuration = MPCheckoutConfiguration<MPPaymentData.CardSave>(
            type: .saveCard,
            paymentMethod: [.card()]
        )
        let viewModel = CardFormBrickViewModel<MPPaymentData.CardSave>(
            configuration: configuration,
            appearance: appearance,
            initializeUseCase: useCase,
            analytics: analytics
        )
        return (viewModel, repository, analytics)
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
        XCTAssertTrue(messages.contains(.track(path: CardFormAnalyticsPath.initializeError)))
        XCTAssertTrue(messages.contains(.send))
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
}
