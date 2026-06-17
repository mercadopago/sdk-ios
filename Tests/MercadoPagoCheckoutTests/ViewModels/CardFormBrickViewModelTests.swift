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

    private func makeProcessData() -> OrderTransactionProcessData {
        OrderTransactionProcessData(
            id: "ORD01",
            status: "processed",
            statusDetail: "accredited",
            totalAmount: "100.00",
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
}
