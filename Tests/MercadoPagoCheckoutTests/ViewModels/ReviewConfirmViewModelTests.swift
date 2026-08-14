//
//  ReviewConfirmViewModelTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
import XCTest

@MainActor
final class ReviewConfirmViewModelTests: XCTestCase {
    // MARK: - Helpers

    private func makeParams() -> OrderTransactionParams {
        OrderTransactionParams(amount: 100, paymentMethodType: .ticket(paymentMethodId: "rapipago"))
    }

    private func makeResponse() throws -> ReviewConfirmResponse {
        let json = """
        {
          "header": { "title": "Revisá los datos antes de pagar" },
          "items": [
            { "type": "payment_method", "label": "Medio de pago", "value": "Visa •••• 4567" }
          ],
          "footer": { "button": { "label": "Pagar" }, "total_amount": "$ 110" }
        }
        """
        return try JSONDecoder().decode(ReviewConfirmResponse.self, from: Data(json.utf8))
    }

    private func makeProcessData() -> OrderTransactionProcessData {
        OrderTransactionProcessData(
            id: "ORD01",
            status: "processed",
            statusDetail: "accredited",
            totalAmount: "110.00",
            payments: [
                .init(
                    id: "PAY01",
                    status: "processed",
                    statusDetail: "accredited",
                    amount: "110.00",
                    paymentMethodId: "visa",
                    paymentTypeId: "credit_card",
                    installments: 1
                )
            ]
        )
    }

    private func makeSUT(
        fetchResult: Result<ReviewConfirmResponse, Error>? = nil,
        processResult: Result<OrderTransactionProcessData, Error>? = nil
    ) async -> ReviewConfirmViewModel {
        let fetchRepository = MockReviewConfirmRepository()
        if let fetchResult { await fetchRepository.setResult(fetchResult) }
        let orderRepository = MockOrderTransactionRepository()
        if let processResult { await orderRepository.setResult(processResult) }

        return ReviewConfirmViewModel(
            fetchReviewConfirmUseCase: FetchReviewConfirmUseCase(repository: fetchRepository),
            orderTransactionUseCase: OrderTransactionUseCase(repository: orderRepository),
            order: MPOrder(orderId: "ORDER-1", clientToken: "client-token"),
            paymentParams: self.makeParams(),
            reviewConfirmConfig: .reviewAndConfirm(seller: nil, onEmailChangeRequested: nil),
            cardDetails: .init(bin: nil, issuerId: nil, lastFourDigits: nil, installmentAmount: nil)
        )
    }

    // MARK: - load

    func test_load_whenSuccess_shouldPublishSuccessState() async throws {
        // Arrange
        let sut = await self.makeSUT(fetchResult: .success(try self.makeResponse()))

        // Act
        await sut.load()

        // Assert
        guard case let .success(output) = sut.screenState else {
            return XCTFail("Expected .success")
        }
        XCTAssertEqual(output.header.title, "Revisá los datos antes de pagar")
    }

    func test_load_whenFails_shouldPublishErrorState() async {
        // Arrange
        let sut = await self.makeSUT(fetchResult: .failure(URLError(.notConnectedToInternet)))

        // Act
        await sut.load()

        // Assert
        guard case .error = sut.screenState else { return XCTFail("Expected .error") }
    }

    // MARK: - confirm

    func test_confirm_whenSuccess_shouldReturnProcessData() async throws {
        // Arrange
        let sut = await self.makeSUT(processResult: .success(self.makeProcessData()))

        // Act
        let processData = try await sut.confirm()

        // Assert
        XCTAssertEqual(processData.id, "ORD01")
    }

    func test_confirm_whenFails_shouldThrow() async {
        // Arrange
        let sut = await self.makeSUT(processResult: .failure(URLError(.timedOut)))

        // Act / Assert
        do {
            _ = try await sut.confirm()
            XCTFail("Expected confirm() to throw")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
