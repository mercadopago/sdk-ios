//
//  CardFormBrickViewModelReviewConfirmTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
import XCTest

@MainActor
final class CardFormBrickViewModelReviewConfirmTests: XCTestCase {
    // MARK: - Helpers

    private func makeOrder() -> MPOrder {
        MPOrder(orderId: "ORDER-1", clientToken: "client-token")
    }

    private func makeCardTransaction(issuerId: String? = "25") -> MPPaymentData.CardTransaction {
        MPPaymentData.CardTransaction(
            transactionAmount: 100,
            token: "token",
            installment: 3,
            paymentMethodId: "visa",
            paymentTypeId: "credit_card",
            issuerId: issuerId,
            orderId: "ORDER-1"
        )
    }

    private func makeCardTransactionSUT(
        screenConfigs: [ScreenConfig] = [],
        sellerInfo: MPSellerInfo? = nil,
        repository: MockCardFormInitializationRepository = MockCardFormInitializationRepository()
    ) -> CardFormBrickViewModel<MPPaymentData.CardTransaction> {
        let configuration = MPCheckoutConfiguration<MPPaymentData.CardTransaction>(
            type: .cardTransaction(order: self.makeOrder(), sellerInfo: sellerInfo),
            paymentMethod: [.card()],
            screenConfigs: screenConfigs
        )
        return CardFormBrickViewModel<MPPaymentData.CardTransaction>(
            configuration: configuration,
            initializeUseCase: InitializeCardFormUseCase(repository: repository)
        )
    }

    // MARK: - reviewConfirmInput

    func test_reviewConfirmInput_whenNotConfigured_shouldReturnNil() {
        // Arrange
        let sut = self.makeCardTransactionSUT()

        // Act
        let input = sut.reviewConfirmInput(cardTransaction: self.makeCardTransaction(), inputCardData: InputCardData(bin: "41111111", lastFourDigits: "1234"))

        // Assert
        XCTAssertNil(input)
    }

    func test_reviewConfirmInput_whenConfigured_shouldReturnInputWithOrderAndCardDetails() throws {
        // Arrange
        let sut = self.makeCardTransactionSUT(
            screenConfigs: [.reviewAndConfirm(onPaymentMethodChangeRequested: nil, onEmailChangeRequested: nil)]
        )

        // Act
        let input = try XCTUnwrap(
            sut.reviewConfirmInput(cardTransaction: self.makeCardTransaction(), inputCardData: InputCardData(bin: "41111111", lastFourDigits: "1234"))
        )

        // Assert
        XCTAssertEqual(input.order.orderId, "ORDER-1")
        XCTAssertEqual(input.order.clientToken, "client-token")
        XCTAssertEqual(input.cardDetails.bin, "41111111")
        XCTAssertEqual(input.cardDetails.issuerId, 25)
        XCTAssertEqual(input.cardDetails.lastFourDigits, "1234")
    }

    func test_reviewConfirmInput_withSellerInfo_shouldForwardSellerFromCheckoutType() throws {
        // Arrange
        let sellerInfo = MPSellerInfo(name: "Adidas Store", logoUrl: "https://cdn.example.com/logo.png")
        let sut = self.makeCardTransactionSUT(
            screenConfigs: [.reviewAndConfirm(onPaymentMethodChangeRequested: nil, onEmailChangeRequested: nil)],
            sellerInfo: sellerInfo
        )

        // Act
        let input = try XCTUnwrap(
            sut.reviewConfirmInput(
                cardTransaction: self.makeCardTransaction(),
                inputCardData: InputCardData(bin: "41111111", lastFourDigits: "1234")
            )
        )

        // Assert
        XCTAssertEqual(input.sellerInfo, sellerInfo)
    }

    func test_reviewConfirmInput_whenSaveCard_shouldReturnNil() {
        // Arrange — review and confirm only applies to card transactions.
        let configuration = MPCheckoutConfiguration<MPPaymentData.CardSave>(
            type: .saveCard,
            paymentMethod: [.card()],
            screenConfigs: [.reviewAndConfirm(onPaymentMethodChangeRequested: nil, onEmailChangeRequested: nil)]
        )
        let sut = CardFormBrickViewModel<MPPaymentData.CardSave>(configuration: configuration)

        // Act
        let input = sut.reviewConfirmInput(cardTransaction: self.makeCardTransaction(), inputCardData: InputCardData(bin: "41111111", lastFourDigits: "1234"))

        // Assert
        XCTAssertNil(input)
    }

    // MARK: - makeReviewConfirmResult

    func test_makeReviewConfirmResult_shouldFoldOrderStatusIntoCardTransaction() throws {
        // Arrange
        let sut = self.makeCardTransactionSUT()
        let processData = OrderTransactionProcessData(
            id: "ORD01",
            status: "processed",
            statusDetail: "accredited",
            totalAmount: "100.00",
            payments: []
        )

        // Act
        let result = try XCTUnwrap(
            sut.makeReviewConfirmResult(from: processData, paymentData: self.makeCardTransaction())
        )

        // Assert
        XCTAssertEqual(result.orderStatus, "processed")
        XCTAssertEqual(result.orderId, "ORDER-1")
        XCTAssertEqual(result.token, "token")
        XCTAssertEqual(result.installment, 3)
    }

    // MARK: - onPaymentMethodChangeRequested

    func test_onPaymentMethodChangeRequested_whenConfigured_shouldReturnSellerCallback() {
        // Arrange
        let recorder = CallRecorder()
        let sut = self.makeCardTransactionSUT(
            screenConfigs: [.reviewAndConfirm(
                onPaymentMethodChangeRequested: { recorder.events.append("callback") },
                onEmailChangeRequested: nil
            )]
        )

        // Act
        let callback = sut.onPaymentMethodChangeRequested
        callback?()

        // Assert
        XCTAssertEqual(recorder.events, ["callback"])
    }

    func test_onPaymentMethodChangeRequested_whenNotConfigured_shouldReturnNil() {
        // Arrange
        let sut = self.makeCardTransactionSUT()

        // Act / Assert
        XCTAssertNil(sut.onPaymentMethodChangeRequested)
    }
}

@MainActor
private final class CallRecorder {
    var events: [String] = []
}
