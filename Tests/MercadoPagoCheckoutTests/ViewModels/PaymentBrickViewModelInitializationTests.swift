//
//  PaymentBrickViewModelInitializationTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
import XCTest

@MainActor
final class PaymentBrickViewModelInitializationTests: XCTestCase {
    // MARK: - Types

    typealias SUT = (
        viewModel: PaymentBrickViewModel<MPPaymentData.Payment>,
        repository: MockPaymentBrickRepository
    )

    // MARK: - load()

    func test_load_setsLoadingDuringFetch() async {
        let sut = self.makeSUT()
        sut.repository.shouldSuspendOnFetch = true

        let task = Task { @MainActor in try? await sut.viewModel.load() }

        while sut.repository.fetchCallCount == 0 {
            await Task.yield()
        }

        guard case .loading = sut.viewModel.screenState else {
            sut.repository.resumeFetch()
            return XCTFail("Expected .loading during fetch, got \(sut.viewModel.screenState)")
        }

        sut.repository.resumeFetch()
        await task.value
    }

    func test_load_onSuccess_setsReadyWithOutput() async throws {
        let sut = self.makeSUT()

        try await sut.viewModel.load()

        guard case let .ready(output) = sut.viewModel.screenState else {
            return XCTFail("Expected .ready, got \(sut.viewModel.screenState)")
        }
        XCTAssertEqual(output, sut.repository.mockOutput)
    }

    func test_load_callsRepositoryOnce() async throws {
        let sut = self.makeSUT()

        try await sut.viewModel.load()

        XCTAssertEqual(sut.repository.fetchCallCount, 1)
    }

    func test_load_forwardsOrderId() async throws {
        let sut = self.makeSUT(orderId: "ORD99")

        try await sut.viewModel.load()

        XCTAssertEqual(sut.repository.capturedOrderId, "ORD99")
    }

    func test_load_forwardsCustomerId() async throws {
        let sut = self.makeSUT(customerId: "CUST01")

        try await sut.viewModel.load()

        XCTAssertEqual(sut.repository.capturedCustomerId, "CUST01")
    }

    func test_load_onRepositoryError_throws() async {
        let sut = self.makeSUT()
        sut.repository.shouldThrow = true

        do {
            try await sut.viewModel.load()
            XCTFail("Expected throw")
        } catch let error as MercadoPagoCheckoutError {
            XCTAssertEqual(error.locationDescription, "initialization")
        }
    }

    func test_load_skipsForNonPaymentCheckoutType() async throws {
        let repository = MockPaymentBrickRepository()
        let configuration = MPCheckoutConfiguration<MPPaymentData.CardSave>(
            type: .saveCard,
            paymentMethod: []
        )
        let viewModel = PaymentBrickViewModel(
            configuration: configuration,
            fetchInitializationUseCase: FetchPaymentBrickInitializationUseCase(repository: repository)
        )

        try await viewModel.load()

        XCTAssertEqual(repository.fetchCallCount, 0)
    }

    // MARK: - Helpers

    private func makeSUT(
        orderId: String = "ORD01",
        customerId: String? = nil,
        cardIds: [String] = []
    ) -> SUT {
        let repository = MockPaymentBrickRepository()
        let order = MPOrder(orderId: orderId, clientToken: "token")
        let configuration = MPCheckoutConfiguration<MPPaymentData.Payment>(
            type: .payment(order: order, cardIds: cardIds, customerId: customerId),
            paymentMethod: []
        )
        let viewModel = PaymentBrickViewModel(
            configuration: configuration,
            fetchInitializationUseCase: FetchPaymentBrickInitializationUseCase(repository: repository)
        )
        return (viewModel, repository)
    }
}
