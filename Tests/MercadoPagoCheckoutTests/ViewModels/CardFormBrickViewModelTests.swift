//
//  CardFormBrickViewModelTests.swift
//  MercadoPagoSDK
//

import Foundation
@testable import MercadoPagoCheckout
import XCTest

@MainActor
final class CardFormBrickViewModelTests: XCTestCase {
    // MARK: - Types

    typealias SUT = (
        viewModel: CardFormBrickViewModel<MPPaymentData.CardSave>,
        repository: MockCardFormInitializationRepository
    )

    // MARK: - Helpers

    private func makeSUT() -> SUT {
        let repository = MockCardFormInitializationRepository()
        let useCase = InitializeCardFormUseCase(repository: repository)
        let configuration = MPCheckoutConfiguration<MPPaymentData.CardSave>(
            type: .saveCard,
            paymentMethod: [.card()]
        )
        let viewModel = CardFormBrickViewModel<MPPaymentData.CardSave>(
            configuration: configuration,
            initializeUseCase: useCase
        )
        return (viewModel, repository)
    }

    // MARK: - load() retry

    func test_load_whenFirstAttemptSucceeds_shouldCallRepositoryOnce() async throws {
        // Arrange
        let sut = self.makeSUT()

        // Act
        try await sut.viewModel.load()

        // Assert
        XCTAssertEqual(sut.repository.fetchCallCount, 1)
        if case .ready = sut.viewModel.screenState {} else {
            XCTFail("Expected screenState .ready")
        }
    }

    func test_load_whenFirstAttemptFails_shouldRetryAndSucceed() async throws {
        // Arrange
        let sut = self.makeSUT()
        sut.repository.sequentialResults = [
            .failure(NSError(domain: "network", code: -1)),
            .success(MockCardFormInitializationRepository.makeDefault())
        ]

        // Act
        try await sut.viewModel.load()

        // Assert
        XCTAssertEqual(sut.repository.fetchCallCount, 2)
        if case .ready = sut.viewModel.screenState {} else {
            XCTFail("Expected screenState .ready after retry")
        }
    }

    func test_load_whenAllAttemptsFail_shouldThrowErrorAfter2Calls() async {
        // Arrange
        let sut = self.makeSUT()
        sut.repository.shouldThrow = true

        // Act & Assert
        do {
            try await sut.viewModel.load()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(sut.repository.fetchCallCount, 2)
        }
    }

    // MARK: - buildPaymentData orderId propagation

    func test_buildPaymentData_cardTransaction_shouldPropagateOrderId() {
        // Arrange
        let order = MPOrder(amount: 100.0, payer: .init(email: "test@mp.com"), orderId: "order-42")
        let configuration = MPCheckoutConfiguration<MPPaymentData.CardTransaction>(
            type: .cardTransaction(order: order),
            paymentMethod: [.card()]
        )
        let viewModel = CardFormBrickViewModel<MPPaymentData.CardTransaction>(
            configuration: configuration,
            initializeUseCase: InitializeCardFormUseCase(repository: MockCardFormInitializationRepository())
        )
        let output = CardFormOutput(
            token: "token",
            paymentMethodId: "visa",
            paymentTypeId: "credit_card",
            issuerId: nil,
            payer: nil,
            installmentsData: nil
        )

        // Act
        let result = viewModel.buildPaymentData(from: output)

        // Assert
        XCTAssertEqual(result?.orderId, "order-42")
    }
}
