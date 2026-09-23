//
//  PaymentBrickViewModelSavedCardTokenizationTests.swift
//  MercadoPagoSDK
//

@testable import CoreMethods
@testable import MercadoPagoCheckout
import XCTest

@MainActor
final class PaymentBrickViewModelSavedCardTokenizationTests: XCTestCase {
    // MARK: - Types

    typealias SUT = (viewModel: PaymentBrickViewModel<MPPaymentData.Payment>, service: MockCheckoutService)

    private enum CardTokenStub {
        static let valid = CardToken(
            token: "test_token_12345",
            publicKey: nil,
            bin: nil,
            expirationMonth: nil,
            expirationYear: nil,
            lastFourDigits: nil,
            cardHolder: nil,
            status: nil,
            dateCreated: nil,
            dateLastUpdated: nil,
            dateDue: nil,
            luhnValidation: nil,
            liveMode: nil,
            requireEsc: nil,
            cardNumberLength: nil,
            securityCodeLength: nil,
            truncCardNumber: nil
        )
    }

    // MARK: - tokenizeSavedCard(cardId:)

    func test_tokenizeSavedCard_sendsCardIdWithEmptySecurityCode_andReturnsToken() async throws {
        let sut = self.makeSUT()
        await sut.service.setCreateCardTokenResult(.success(CardTokenStub.valid))

        let token = try await sut.viewModel.tokenizeSavedCard(cardId: "card-9999")

        XCTAssertEqual(token, CardTokenStub.valid.token)
        let capturedParams = await sut.service.capturedCardParams
        XCTAssertEqual(capturedParams?.cardId, "card-9999")
        XCTAssertEqual(capturedParams?.securityCode, "")
    }

    func test_tokenizeSavedCard_onFailure_throwsError() async {
        let sut = self.makeSUT()
        let expectedError = MercadoPagoCheckoutError(code: .serviceError, localizedDescription: "failed", location: .tokenization)
        await sut.service.setCreateCardTokenResult(.failure(expectedError))

        do {
            _ = try await sut.viewModel.tokenizeSavedCard(cardId: "card-9999")
            XCTFail("Should not throw error")
        } catch {
            XCTAssertEqual(error.code, expectedError.code)
        }
    }

    // MARK: - Helpers

    private func makeSUT() -> SUT {
        let service = MockCheckoutService()
        let order = MPOrder(orderId: "ORD01", clientToken: "seller_client_token")
        let configuration = MPCheckoutConfiguration<MPPaymentData.Payment>(
            type: MercadoPagoCheckout<MPPaymentData.Payment>.CheckoutType(kind: .payment(order: order, sellerInfo: nil)),
            paymentMethod: [.card()]
        )
        let viewModel = PaymentBrickViewModel(
            configuration: configuration,
            securityCodeUseCase: SecurityCodeUseCase(service: service)
        )
        return (viewModel, service)
    }
}
