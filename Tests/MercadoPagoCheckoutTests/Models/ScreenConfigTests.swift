//
//  ScreenConfigTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
import XCTest

final class ScreenConfigTests: XCTestCase {
    // MARK: - toScreen

    func test_toScreen_withReviewAndConfirm_shouldReturnReviewAndConfirmScreen() {
        // Arrange
        let sut = ScreenConfig.reviewAndConfirm(seller: nil, onPaymentMethodChangeRequested: nil, onEmailChangeRequested: nil)

        // Act / Assert
        XCTAssertEqual(sut.toScreen(), .reviewAndConfirm)
    }

    // MARK: - screensParameter

    func test_screensParameter_whenEmpty_shouldReturnNil() {
        // Arrange
        let sut: [ScreenConfig] = []

        // Act / Assert
        XCTAssertNil(sut.screensParameter)
    }

    func test_screensParameter_withReviewAndConfirm_shouldReturnBackendKey() {
        // Arrange
        let sut: [ScreenConfig] = [.reviewAndConfirm(seller: nil, onPaymentMethodChangeRequested: nil, onEmailChangeRequested: nil)]

        // Act / Assert
        XCTAssertEqual(sut.screensParameter, "REVIEW_AND_CONFIRM")
    }

    // MARK: - reviewAndConfirmConfig

    func test_reviewAndConfirmConfig_whenNotConfigured_shouldReturnNil() {
        // Arrange
        let sut = self.makeConfiguration(screenConfigs: [])

        // Act / Assert
        XCTAssertNil(sut.reviewAndConfirmConfig)
    }

    func test_reviewAndConfirmConfig_whenConfigured_shouldReturnSellerAndCallback() {
        // Arrange
        let seller = MPSellerInfo(name: "Adidas Store", logoUrl: "https://cdn.example.com/logo.png")
        let sut = self.makeConfiguration(
            screenConfigs: [.reviewAndConfirm(seller: seller, onPaymentMethodChangeRequested: nil, onEmailChangeRequested: {})]
        )

        // Act
        guard case let .reviewAndConfirm(returnedSeller, _, onEmailChangeRequested) = sut.reviewAndConfirmConfig else {
            return XCTFail("Expected a reviewAndConfirm config")
        }

        // Assert
        XCTAssertEqual(returnedSeller, seller)
        XCTAssertNotNil(onEmailChangeRequested)
    }

    // MARK: - Builder

    @MainActor
    func test_build_whenWithReviewAndConfirmNotCalled_shouldNotConfigureTheScreen() {
        // Arrange
        let sut = self.makePaymentBuilder()

        // Act
        let checkout = sut.build()

        // Assert
        XCTAssertTrue(checkout.configuration.screenConfigs.isEmpty)
        XCTAssertNil(checkout.configuration.reviewAndConfirmConfig)
    }

    @MainActor
    func test_build_withReviewAndConfirm_shouldForwardSellerToConfiguration() {
        // Arrange
        let seller = MPSellerInfo(name: "Adidas Store")
        let sut = self.makePaymentBuilder()

        // Act
        let checkout = sut.withReviewAndConfirm(seller: seller).build()

        // Assert
        XCTAssertEqual(checkout.configuration.screenConfigs.count, 1)
        guard case let .reviewAndConfirm(returnedSeller, _, _) = checkout.configuration.reviewAndConfirmConfig else {
            return XCTFail("Expected a reviewAndConfirm config")
        }
        XCTAssertEqual(returnedSeller, seller)
    }

    @MainActor
    func test_build_withReviewAndConfirmCalledTwice_shouldKeepOnlyLastConfiguration() {
        // Arrange
        let lastSeller = MPSellerInfo(name: "Last Store")
        let sut = self.makePaymentBuilder()

        // Act
        let checkout = sut
            .withReviewAndConfirm(seller: MPSellerInfo(name: "First Store"))
            .withReviewAndConfirm(seller: lastSeller)
            .build()

        // Assert
        XCTAssertEqual(checkout.configuration.screenConfigs.count, 1)
        guard case let .reviewAndConfirm(returnedSeller, _, _) = checkout.configuration.reviewAndConfirmConfig else {
            return XCTFail("Expected a reviewAndConfirm config")
        }
        XCTAssertEqual(returnedSeller, lastSeller)
    }

    @MainActor
    func test_build_withReviewAndConfirmOnCardTransaction_shouldConfigureTheScreen() {
        // Arrange
        let sut = MercadoPagoCheckout<MPPaymentData.CardTransaction>.Builder(
            checkoutType: .cardTransaction(order: self.makeOrder()),
            checkoutAppearance: .init()
        )

        // Act
        let checkout = sut.withReviewAndConfirm(onPaymentMethodChangeRequested: {}).build()

        // Assert
        XCTAssertNotNil(checkout.configuration.reviewAndConfirmConfig)
    }

    @MainActor
    func test_build_withReviewAndConfirmOnCardTransaction_shouldForwardPaymentMethodChangeCallback() {
        // Arrange
        let sut = MercadoPagoCheckout<MPPaymentData.CardTransaction>.Builder(
            checkoutType: .cardTransaction(order: self.makeOrder()),
            checkoutAppearance: .init()
        )

        // Act
        let checkout = sut.withReviewAndConfirm(onPaymentMethodChangeRequested: {}).build()

        // Assert
        guard case let .reviewAndConfirm(_, onPaymentMethodChangeRequested, _) = checkout.configuration.reviewAndConfirmConfig else {
            return XCTFail("Expected a reviewAndConfirm config")
        }
        XCTAssertNotNil(onPaymentMethodChangeRequested)
    }

    @MainActor
    func test_build_withReviewAndConfirmOnPayment_shouldNotSetPaymentMethodChangeCallback() {
        // Arrange — the Payment flow modifies the method via internal navigation, not a callback.
        let sut = self.makePaymentBuilder()

        // Act
        let checkout = sut.withReviewAndConfirm(seller: nil).build()

        // Assert
        guard case let .reviewAndConfirm(_, onPaymentMethodChangeRequested, _) = checkout.configuration.reviewAndConfirmConfig else {
            return XCTFail("Expected a reviewAndConfirm config")
        }
        XCTAssertNil(onPaymentMethodChangeRequested)
    }

    // MARK: - Helpers

    private func makeOrder() -> MPOrder {
        MPOrder(orderId: "ORD01", clientToken: "client_token")
    }

    @MainActor
    private func makePaymentBuilder() -> MercadoPagoCheckout<MPPaymentData.Payment>.Builder {
        MercadoPagoCheckout<MPPaymentData.Payment>.Builder(
            checkoutType: .payment(order: self.makeOrder()),
            checkoutAppearance: .init()
        )
    }

    private func makeConfiguration(
        screenConfigs: [ScreenConfig]
    ) -> MPCheckoutConfiguration<MPPaymentData.Payment> {
        MPCheckoutConfiguration<MPPaymentData.Payment>(
            type: .payment(order: self.makeOrder()),
            paymentMethod: [],
            screenConfigs: screenConfigs
        )
    }
}
