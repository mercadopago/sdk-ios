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
                    paymentTypeId: "credit_card",
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

    // MARK: - buildPaymentData orderId propagation

    func test_buildPaymentData_cardTransaction_shouldPropagateOrderId() {
        // Arrange
        let order = MPOrder(orderId: "order-42", clientToken: "seller_client_token")
        let configuration = MPCheckoutConfiguration<MPPaymentData.CardTransaction>(
            type: .cardTransaction(order: order),
            paymentMethod: [.card()]
        )
        let viewModel = CardFormBrickViewModel<MPPaymentData.CardTransaction>(
            configuration: configuration,
            initializeUseCase: InitializeCardFormUseCase(repository: MockCardFormInitializationRepository())
        )
        let output = CardFormSubmitResult(
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

    // MARK: - buildPaymentData amount propagation (from BFF, not MPOrder)

    func test_buildPaymentData_cardTransaction_shouldUseAmountFromInitializationResponse() async throws {
        // Arrange
        let order = MPOrder(orderId: "order-42", clientToken: "seller_client_token")
        let configuration = MPCheckoutConfiguration<MPPaymentData.CardTransaction>(
            type: .cardTransaction(order: order),
            paymentMethod: [.card()]
        )
        let repository = MockCardFormInitializationRepository()
        repository.mockData = MockCardFormInitializationRepository.makeDefault(amount: 250.50)
        let viewModel = CardFormBrickViewModel<MPPaymentData.CardTransaction>(
            configuration: configuration,
            initializeUseCase: InitializeCardFormUseCase(repository: repository)
        )
        let output = CardFormSubmitResult(
            token: "token",
            paymentMethodId: "visa",
            paymentTypeId: "credit_card",
            issuerId: nil,
            payer: nil,
            installmentsData: nil
        )

        // Act
        try await viewModel.load()
        let result = viewModel.buildPaymentData(from: output)

        // Assert
        XCTAssertEqual(result?.transactionAmount, 250.50)
    }

    // MARK: - processOrderTask clientToken propagation

    func test_processOrderTask_shouldPropagateClientTokenFromOrderToRepository() async throws {
        // Arrange
        let order = MPOrder(orderId: "order-99", clientToken: "seller_client_token")
        let configuration = MPCheckoutConfiguration<MPPaymentData.CardTransaction>(
            type: .cardTransaction(order: order),
            paymentMethod: [.card()]
        )
        let orderRepository = MockOrderTransactionRepository()
        await orderRepository.setResult(.success(self.makeProcessData()))
        let viewModel = CardFormBrickViewModel<MPPaymentData.CardTransaction>(
            configuration: configuration,
            initializeUseCase: InitializeCardFormUseCase(repository: MockCardFormInitializationRepository()),
            orderUseCase: OrderTransactionUseCase(repository: orderRepository)
        )
        let paymentData = MPPaymentData.CardTransaction(
            transactionAmount: 100.0,
            token: "tok",
            installment: 1,
            paymentMethodId: "visa",
            paymentTypeId: "credit_card",
            orderId: "order-99"
        )

        // Act
        _ = try await viewModel.processOrderTask(paymentData)

        // Assert
        let lastClientToken = await orderRepository.lastClientToken
        XCTAssertEqual(lastClientToken, "seller_client_token")
    }
}
