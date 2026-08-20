//
//  PaymentBrickViewModelReviewConfirmTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
import XCTest

@MainActor
final class PaymentBrickViewModelReviewConfirmTests: XCTestCase {
    // MARK: - Helpers

    private func makeOrder() -> MPOrder {
        MPOrder(orderId: "ORDER-1", clientToken: "client-token")
    }

    private func makeParams() -> OrderTransactionParams {
        OrderTransactionParams(amount: 100, paymentMethodType: .ticket(paymentMethodId: "rapipago"))
    }

    private func makeSUT(screenConfigs: [ScreenConfig] = []) -> PaymentBrickViewModel<MPPaymentData.Payment> {
        let configuration = MPCheckoutConfiguration<MPPaymentData.Payment>(
            type: .payment(order: self.makeOrder()),
            paymentMethod: [.card()],
            screenConfigs: screenConfigs
        )
        return PaymentBrickViewModel<MPPaymentData.Payment>(configuration: configuration)
    }

    private func makeCardDetails(
        bin: String? = "411111",
        issuerId: Int? = nil,
        lastFourDigits: String? = nil,
        installmentAmount: String? = nil
    ) -> ReviewConfirmCardDetails {
        .init(bin: bin, issuerId: issuerId, lastFourDigits: lastFourDigits, installmentAmount: installmentAmount)
    }

    private func makeSUT(
        screenConfigs: [ScreenConfig],
        repository: MockPaymentBrickRepository
    ) -> PaymentBrickViewModel<MPPaymentData.Payment> {
        let configuration = MPCheckoutConfiguration<MPPaymentData.Payment>(
            type: .payment(order: self.makeOrder()),
            paymentMethod: [.card()],
            screenConfigs: screenConfigs
        )
        return PaymentBrickViewModel<MPPaymentData.Payment>(
            configuration: configuration,
            fetchInitializationUseCase: FetchPaymentBrickInitializationUseCase(repository: repository)
        )
    }

    // MARK: - load screens parameter

    func test_load_whenReviewAndConfirmConfigured_shouldForwardScreensParameter() async throws {
        // Arrange
        let repository = MockPaymentBrickRepository()
        let sut = self.makeSUT(
            screenConfigs: [.reviewAndConfirm(seller: nil, onPaymentMethodChangeRequested: nil, onEmailChangeRequested: nil)],
            repository: repository
        )

        // Act
        try await sut.load()

        // Assert
        XCTAssertEqual(repository.capturedScreens, "REVIEW_AND_CONFIRM")
    }

    func test_load_whenNoOptionalScreens_shouldForwardNilScreensParameter() async throws {
        // Arrange
        let repository = MockPaymentBrickRepository()
        let sut = self.makeSUT(screenConfigs: [], repository: repository)

        // Act
        try await sut.load()

        // Assert
        XCTAssertNil(repository.capturedScreens)
    }

    // MARK: - reviewConfirmInput

    func test_reviewConfirmInput_whenNotConfigured_shouldReturnNil() {
        // Arrange
        let sut = self.makeSUT()

        // Act
        let input = sut.reviewConfirmInput(for: self.makeParams(), cardDetails: self.makeCardDetails())

        // Assert
        XCTAssertNil(input)
    }

    func test_reviewConfirmInput_whenConfigured_shouldReturnInputWithOrderAndParams() throws {
        // Arrange
        let params = self.makeParams()
        let sut = self.makeSUT(
            screenConfigs: [.reviewAndConfirm(seller: nil, onPaymentMethodChangeRequested: nil, onEmailChangeRequested: nil)]
        )

        // Act
        let input = try XCTUnwrap(
            sut.reviewConfirmInput(
                for: params,
                cardDetails: self.makeCardDetails(bin: "411111", issuerId: 25, lastFourDigits: "4567")
            )
        )

        // Assert
        XCTAssertEqual(input.order.orderId, "ORDER-1")
        XCTAssertEqual(input.order.clientToken, "client-token")
        XCTAssertEqual(input.cardDetails.bin, "411111")
        XCTAssertEqual(input.cardDetails.issuerId, 25)
        XCTAssertEqual(input.cardDetails.lastFourDigits, "4567")
    }

    func test_reviewConfirmInput_withNilBin_shouldReturnInputWithNilBin() throws {
        // Arrange
        let sut = self.makeSUT(
            screenConfigs: [.reviewAndConfirm(seller: nil, onPaymentMethodChangeRequested: nil, onEmailChangeRequested: nil)]
        )

        // Act
        let input = try XCTUnwrap(
            sut.reviewConfirmInput(for: self.makeParams(), cardDetails: self.makeCardDetails(bin: nil))
        )

        // Assert
        XCTAssertNil(input.cardDetails.bin)
    }

    // MARK: - makePaymentResult

    private func makeProcessData(payments: [OrderTransactionProcessData.Payment]) -> OrderTransactionProcessData {
        OrderTransactionProcessData(
            id: "ORD01",
            status: "processed",
            statusDetail: "accredited",
            totalAmount: "110.00",
            payments: payments
        )
    }

    private func makePayment() -> OrderTransactionProcessData.Payment {
        .init(
            id: "PAY01",
            status: "processed",
            statusDetail: "accredited",
            amount: "110.00",
            paymentMethodId: "visa",
            paymentTypeId: "credit_card",
            installments: 1
        )
    }

    func test_makePaymentResult_whenSuccess_shouldMapProcessDataIntoPayment() throws {
        // Arrange
        let sut = self.makeSUT()
        let processData = self.makeProcessData(payments: [self.makePayment()])

        // Act
        let payment = try sut.makePaymentResult(from: processData)

        // Assert
        XCTAssertEqual(payment.orderId, "ORDER-1")
        XCTAssertEqual(payment.orderStatus, "processed")
        XCTAssertEqual(payment.transactionAmount, Decimal(string: "110.00"))
        XCTAssertEqual(payment.paymentMethodId, "visa")
        XCTAssertEqual(payment.paymentTypeId, "credit_card")
    }

    func test_makePaymentResult_whenNoPayments_shouldThrow() {
        // Arrange
        let sut = self.makeSUT()
        let processData = self.makeProcessData(payments: [])

        // Act / Assert
        do {
            _ = try sut.makePaymentResult(from: processData)
            XCTFail("Expected makePaymentResult to throw")
        } catch {
            XCTAssertEqual(error.code, .serviceError)
        }
    }

    // MARK: - onEmailChangeRequested

    func test_onEmailChangeRequested_whenConfigured_shouldReturnSellerCallback() {
        // Arrange
        let recorder = PaymentBrickCallRecorder()
        let sut = self.makeSUT(
            screenConfigs: [.reviewAndConfirm(
                seller: nil,
                onPaymentMethodChangeRequested: nil,
                onEmailChangeRequested: { recorder.events.append("callback") }
            )]
        )

        // Act
        let callback = sut.onEmailChangeRequested
        callback?()

        // Assert
        XCTAssertEqual(recorder.events, ["callback"])
    }

    func test_onEmailChangeRequested_whenNotConfigured_shouldReturnNil() {
        // Arrange
        let sut = self.makeSUT()

        // Act / Assert
        XCTAssertNil(sut.onEmailChangeRequested)
    }

    func test_onEmailChangeRequested_whenReviewAndConfirmWithoutEmailCallback_shouldReturnNil() {
        // Arrange
        let sut = self.makeSUT(
            screenConfigs: [.reviewAndConfirm(seller: nil, onPaymentMethodChangeRequested: nil, onEmailChangeRequested: nil)]
        )

        // Act / Assert
        XCTAssertNil(sut.onEmailChangeRequested)
    }
}

@MainActor
private final class PaymentBrickCallRecorder {
    var events: [String] = []
}
