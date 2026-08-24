//
//  ReviewConfirmViewModelTests.swift
//  MercadoPagoSDK
//

import CommonTests
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
          "footer": { "button": { "label": "Pagar" }, "total_amount": 110, "currency_symbol": "$" }
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
        processResult: Result<OrderTransactionProcessData, Error>? = nil,
        orderRepository: MockOrderTransactionRepository? = nil,
        analytics: MockAnalytics? = nil,
        paymentParams: OrderTransactionParams? = nil,
        cardDetails: ReviewConfirmCardDetails? = nil
    ) async -> ReviewConfirmViewModel {
        let fetchRepository = MockReviewConfirmRepository()
        if let fetchResult { await fetchRepository.setResult(fetchResult) }
        let repository = orderRepository ?? MockOrderTransactionRepository()
        if let processResult { await repository.setResult(processResult) }

        return ReviewConfirmViewModel(
            fetchReviewConfirmUseCase: FetchReviewConfirmUseCase(repository: fetchRepository),
            orderTransactionUseCase: OrderTransactionUseCase(repository: repository),
            order: MPOrder(orderId: "ORDER-1", clientToken: "client-token"),
            paymentParams: paymentParams ?? self.makeParams(),
            reviewConfirmConfig: .reviewAndConfirm(onPaymentMethodChangeRequested: nil, onEmailChangeRequested: nil),
            sellerInfo: nil,
            cardDetails: cardDetails ?? .init(
                bin: nil,
                issuerId: nil,
                lastFourDigits: nil,
                installmentAmount: nil
            ),
            analytics: analytics ?? MockAnalytics()
        )
    }

    // MARK: - load

    func test_load_whenSuccess_shouldPublishSuccessState() async throws {
        // Arrange
        let sut = try await makeSUT(fetchResult: .success(makeResponse()))

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
        let sut = await makeSUT(fetchResult: .failure(URLError(.notConnectedToInternet)))

        // Act
        await sut.load()

        // Assert
        guard case .error = sut.screenState else { return XCTFail("Expected .error") }
    }

    // MARK: - confirm

    func test_confirm_whenSuccess_shouldReturnProcessData() async throws {
        // Arrange
        let sut = await makeSUT(processResult: .success(makeProcessData()))

        // Act
        let processData = try await sut.confirm()

        // Assert
        XCTAssertEqual(processData.id, "ORD01")
    }

    func test_confirm_whenReviewWasLoaded_shouldUseReviewedTotalAmount() async throws {
        // Arrange
        let orderRepository = MockOrderTransactionRepository()
        let sut = try await makeSUT(
            fetchResult: .success(makeResponse()),
            processResult: .success(makeProcessData()),
            orderRepository: orderRepository
        )
        await sut.load()

        // Act
        _ = try await sut.confirm()

        // Assert
        let params = await orderRepository.lastParams
        XCTAssertEqual(params?.amount, 110)
    }

    func test_confirm_whenFails_shouldThrow() async {
        // Arrange
        let sut = await makeSUT(processResult: .failure(URLError(.timedOut)))

        // Act / Assert
        do {
            _ = try await sut.confirm()
            XCTFail("Expected confirm() to throw")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    // MARK: - Tracking

    func test_load_whenSuccessful_shouldTrackReviewConfirmWithDisplayedAmount() async throws {
        // Arrange
        let analytics = MockAnalytics()
        let sut = try await makeSUT(fetchResult: .success(makeResponse()), analytics: analytics)

        // Act
        await sut.load()
        await analytics.mock.waitForSend()

        // Assert
        let messages = await analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.trackView(ReviewConfirmAnalyticsPath.initialize)))
        XCTAssertTrue(messages.contains(.setEventData([
            "type": "ticket",
            "payment_method_id": "rapipago",
            "payment_type_id": "ticket",
            "issuer_id": "NOT_APPLY",
            "card_id": "NOT_APPLY",
            "transaction_amount": Decimal(110),
            "installments": 0
        ])))
    }

    func test_confirm_shouldTrackContinue() async throws {
        // Arrange
        let analytics = MockAnalytics()
        let sut = await makeSUT(processResult: .success(makeProcessData()), analytics: analytics)

        // Act
        _ = try await sut.confirm()
        await analytics.mock.waitForSend()

        // Assert
        let messages = await analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.track(path: ReviewConfirmAnalyticsPath.continuePayment)))
        XCTAssertTrue(messages.contains(.send))
    }

    func test_goBack_shouldTrackBack() async {
        // Arrange
        let analytics = MockAnalytics()
        let sut = await makeSUT(analytics: analytics)

        // Act
        sut.goBack()
        await analytics.mock.waitForSend()

        // Assert
        let messages = await analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.track(path: ReviewConfirmAnalyticsPath.back)))
        XCTAssertTrue(messages.contains(.send))
    }

    func test_modifyPaymentMethod_shouldTrackCurrentPaymentMethod() async {
        // Arrange
        let analytics = MockAnalytics()
        let sut = await makeSUT(analytics: analytics)

        // Act
        sut.modifyPaymentMethod()
        await analytics.mock.waitForSend()

        // Assert
        let messages = await analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.track(path: ReviewConfirmAnalyticsPath.paymentMethodChanged)))
        XCTAssertTrue(messages.contains(.setEventData([
            "type": "ticket",
            "payment_method_id": "rapipago",
            "payment_type_id": "ticket",
            "issuer_id": "NOT_APPLY",
            "card_id": "NOT_APPLY",
            "transaction_amount": Decimal(100),
            "installments": 0
        ])))
    }

    func test_modifyPaymentMethod_whenSavedCard_shouldTrackCardData() async {
        // Arrange
        let analytics = MockAnalytics()
        let sut = await makeSUT(
            analytics: analytics,
            paymentParams: .init(
                amount: 100,
                paymentMethodType: .card(
                    paymentMethodId: "visa",
                    paymentTypeId: "credit_card",
                    token: "token",
                    installments: 3
                )
            ),
            cardDetails: .init(
                bin: "402918",
                issuerId: 5,
                lastFourDigits: "7814",
                installmentAmount: nil,
                cardId: "card-123"
            )
        )

        // Act
        sut.modifyPaymentMethod()
        await analytics.mock.waitForSend()

        // Assert
        let messages = await analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.setEventData([
            "type": "credit_card",
            "payment_method_id": "visa",
            "payment_type_id": "credit_card",
            "issuer_id": "5",
            "card_id": "card-123",
            "transaction_amount": Decimal(100),
            "installments": 3
        ])))
    }

    func test_modifyEmail_shouldTrackEmailFieldChanged() async {
        // Arrange
        let analytics = MockAnalytics()
        let sut = await makeSUT(analytics: analytics)

        // Act
        sut.modifyEmail()
        await analytics.mock.waitForSend()

        // Assert
        let messages = await analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.track(path: ReviewConfirmAnalyticsPath.payerFieldChanged)))
        XCTAssertTrue(messages.contains(.setEventData(["changed_field": "email"])))
    }
}
