//
//  FetchReviewConfirmUseCaseTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
@testable import MPCore
import XCTest

final class FetchReviewConfirmUseCaseTests: XCTestCase {
    // MARK: - Helpers

    private func makeSUT() -> (sut: FetchReviewConfirmUseCase, repository: MockReviewConfirmRepository) {
        let repository = MockReviewConfirmRepository()
        let sut = FetchReviewConfirmUseCase(repository: repository)
        return (sut, repository)
    }

    private func makeCardParams(installments: Int = 3) -> OrderTransactionParams {
        OrderTransactionParams(
            amount: 100,
            paymentMethodType: .card(
                paymentMethodId: "visa",
                paymentTypeId: "credit_card",
                token: "tok",
                installments: installments
            )
        )
    }

    private func makeTicketParams() -> OrderTransactionParams {
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

    private func makeConfig(
        onEmailChangeRequested: (@MainActor @Sendable () -> Void)? = nil
    ) -> ScreenConfig {
        .reviewAndConfirm(onEmailChangeRequested: onEmailChangeRequested)
    }

    private func execute(
        sut: FetchReviewConfirmUseCase,
        params: OrderTransactionParams,
        config: ScreenConfig,
        checkoutType: String = "payment",
        sellerInfo: MPSellerInfo? = nil,
        cardDetails: ReviewConfirmCardDetails = .init(
            bin: "453998",
            issuerId: 25,
            lastFourDigits: "4567",
            installmentAmount: 10
        )
    ) async throws -> ReviewConfirmOutput {
        try await sut.execute(
            orderId: "ORDER-1",
            clientToken: "seller_client_token",
            checkoutType: checkoutType,
            paymentParams: params,
            reviewConfirmConfig: config,
            sellerInfo: sellerInfo,
            cardDetails: cardDetails
        )
    }

    // MARK: - Request building — card

    func test_execute_withCard_buildsRequestWithCardFields() async throws {
        // Arrange
        let (sut, repository) = self.makeSUT()
        try await repository.setResult(.success(self.makeResponse()))

        // Act
        _ = try await self.execute(sut: sut, params: self.makeCardParams(), config: self.makeConfig())

        // Assert
        let lastRequest = await repository.lastRequest
        let request = try XCTUnwrap(lastRequest)
        XCTAssertEqual(request.orderId, "ORDER-1")
        XCTAssertEqual(request.paymentMethodType, "credit_card")
        XCTAssertEqual(request.paymentMethodId, "visa")
        XCTAssertEqual(request.bin, "453998")
        XCTAssertEqual(request.issuerId, "25")
        XCTAssertEqual(request.lastFourDigits, "4567")
        XCTAssertEqual(request.installments, 3)
        XCTAssertEqual(request.installmentAmount, "10.00")
        let clientToken = await repository.lastClientToken
        XCTAssertEqual(clientToken, "seller_client_token")
        let checkoutType = await repository.lastCheckoutType
        XCTAssertEqual(checkoutType, "payment")
    }

    func test_execute_withCardWithoutSelectedInstallmentAmount_leavesFieldNil() async throws {
        // Arrange
        let (sut, repository) = self.makeSUT()
        try await repository.setResult(.success(self.makeResponse()))
        let cardDetails = ReviewConfirmCardDetails(
            bin: "453998",
            issuerId: 25,
            lastFourDigits: "4567",
            installmentAmount: nil
        )

        // Act
        _ = try await self.execute(
            sut: sut,
            params: self.makeCardParams(),
            config: self.makeConfig(),
            cardDetails: cardDetails
        )

        // Assert
        let request = await repository.lastRequest
        XCTAssertNil(request?.installmentAmount)
    }

    // MARK: - Request building — ticket

    func test_execute_withTicket_buildsRequestWithoutCardFields() async throws {
        // Arrange
        let (sut, repository) = self.makeSUT()
        try await repository.setResult(.success(self.makeResponse()))

        // Act — pass card fields to prove ticket ignores them
        _ = try await self.execute(sut: sut, params: self.makeTicketParams(), config: self.makeConfig())

        // Assert
        let lastRequest = await repository.lastRequest
        let request = try XCTUnwrap(lastRequest)
        XCTAssertEqual(request.paymentMethodType, "ticket")
        XCTAssertEqual(request.paymentMethodId, "rapipago")
        XCTAssertNil(request.bin)
        XCTAssertNil(request.issuerId)
        XCTAssertNil(request.lastFourDigits)
        XCTAssertNil(request.installments)
        XCTAssertNil(request.installmentAmount)
    }

    // MARK: - email_change_enabled

    func test_execute_withEmailChangeCallback_setsEmailChangeEnabledTrue() async throws {
        // Arrange
        let (sut, repository) = self.makeSUT()
        try await repository.setResult(.success(self.makeResponse()))
        let config = self.makeConfig(onEmailChangeRequested: {})

        // Act
        _ = try await self.execute(sut: sut, params: self.makeTicketParams(), config: config)

        // Assert
        let request = await repository.lastRequest
        XCTAssertEqual(request?.emailChangeEnabled, true)
    }

    func test_execute_withoutEmailChangeCallback_setsEmailChangeEnabledFalse() async throws {
        // Arrange
        let (sut, repository) = self.makeSUT()
        try await repository.setResult(.success(self.makeResponse()))

        // Act
        _ = try await self.execute(sut: sut, params: self.makeTicketParams(), config: self.makeConfig())

        // Assert
        let request = await repository.lastRequest
        XCTAssertEqual(request?.emailChangeEnabled, false)
    }

    // MARK: - seller_info

    func test_execute_withSeller_mapsSellerInfo() async throws {
        // Arrange
        let (sut, repository) = self.makeSUT()
        try await repository.setResult(.success(self.makeResponse()))
        let sellerInfo = MPSellerInfo(name: "Adidas Store", logoUrl: "https://cdn/logo.png")

        // Act
        _ = try await self.execute(
            sut: sut,
            params: self.makeCardParams(),
            config: self.makeConfig(),
            sellerInfo: sellerInfo
        )

        // Assert
        let request = await repository.lastRequest
        XCTAssertEqual(request?.sellerInfo?.name, "Adidas Store")
        XCTAssertEqual(request?.sellerInfo?.iconUrl, "https://cdn/logo.png")
    }

    func test_execute_withoutSeller_leavesSellerInfoNil() async throws {
        // Arrange
        let (sut, repository) = self.makeSUT()
        try await repository.setResult(.success(self.makeResponse()))

        // Act
        _ = try await self.execute(sut: sut, params: self.makeCardParams(), config: self.makeConfig())

        // Assert
        let request = await repository.lastRequest
        XCTAssertNil(request?.sellerInfo)
    }

    // MARK: - Output

    func test_execute_whenSuccess_returnsOutputFromResponse() async throws {
        // Arrange
        let (sut, repository) = self.makeSUT()
        try await repository.setResult(.success(self.makeResponse()))

        // Act
        let output = try await self.execute(sut: sut, params: self.makeCardParams(), config: self.makeConfig())

        // Assert
        XCTAssertEqual(output.header.title, "Revisá los datos antes de pagar")
        XCTAssertEqual(output.footer.button.label, "Pagar")
    }

    // MARK: - Error

    func test_execute_whenRepositoryThrows_throwsMercadoPagoCheckoutError() async {
        // Arrange
        let (sut, repository) = self.makeSUT()
        await repository.setResult(.failure(URLError(.notConnectedToInternet)))

        // Act & Assert
        do {
            _ = try await self.execute(sut: sut, params: self.makeCardParams(), config: self.makeConfig())
            XCTFail("Expected error to be thrown")
        } catch let error as MercadoPagoCheckoutError {
            XCTAssertEqual(error.locationDescription, "initialization")
        } catch {
            XCTFail("Expected MercadoPagoCheckoutError, got \(error)")
        }
    }
}
