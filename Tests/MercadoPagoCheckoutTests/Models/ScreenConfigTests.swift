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
        let sut = ScreenConfig.reviewAndConfirm(onEmailChangeRequested: nil)

        // Act / Assert
        XCTAssertEqual(sut.toScreen(), .reviewAndConfirm)
    }

    func test_toScreen_withStatusScreen_shouldNotEnterCancellationHistory() {
        XCTAssertNil(ScreenConfig.statusScreen(exit: {}).toScreen())
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
        let sut: [ScreenConfig] = [.reviewAndConfirm(onEmailChangeRequested: nil)]

        // Act / Assert
        XCTAssertEqual(sut.screensParameter, "REVIEW_AND_CONFIRM")
    }

    func test_screensParameter_withStatusScreen_shouldReturnBackendKey() {
        XCTAssertEqual([ScreenConfig.statusScreen(exit: {})].screensParameter, "STATUS_SCREEN")
    }

    // MARK: - reviewAndConfirmConfig

    func test_reviewAndConfirmConfig_whenNotConfigured_shouldReturnNil() {
        // Arrange
        let sut = self.makeConfiguration(screenConfigs: [])

        // Act / Assert
        XCTAssertNil(sut.reviewAndConfirmConfig)
    }

    func test_reviewAndConfirmConfig_whenConfigured_shouldReturnCallback() {
        // Arrange
        let sut = self.makeConfiguration(
            screenConfigs: [.reviewAndConfirm(onEmailChangeRequested: {})]
        )

        // Act
        guard case let .reviewAndConfirm(onEmailChangeRequested) = sut.reviewAndConfirmConfig else {
            return XCTFail("Expected a reviewAndConfirm config")
        }

        // Assert
        XCTAssertNotNil(onEmailChangeRequested)
    }

    func test_statusScreenConfig_whenNotConfigured_shouldReturnNil() {
        XCTAssertNil(self.makeConfiguration(screenConfigs: []).statusScreenConfig)
    }

    func test_statusScreenConfig_whenConfigured_shouldReturnStatusScreen() {
        guard case .statusScreen = self.makeConfiguration(
            screenConfigs: [.statusScreen(exit: {})]
        ).statusScreenConfig else {
            return XCTFail("Expected a statusScreen config")
        }
    }

    @MainActor
    func test_statusScreenExit_whenConfigured_shouldReturnCallback() {
        let spy = StatusScreenExitSpy()
        let sut = self.makeConfiguration(screenConfigs: [.statusScreen(exit: spy.call)])

        sut.statusScreenExit?()

        XCTAssertEqual(spy.callCount, 1)
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
        XCTAssertNil(checkout.configuration.statusScreenConfig)
    }

    @MainActor
    func test_build_withSellerInfo_shouldForwardSellerToConfiguration() {
        // Arrange
        let seller = MPSellerInfo(name: "Adidas Store")
        let sut = self.makePaymentBuilder(sellerInfo: seller)

        // Act
        let checkout = sut.withReviewAndConfirm().build()

        // Assert
        XCTAssertEqual(checkout.configuration.screenConfigs.count, 1)
        XCTAssertEqual(checkout.configuration.sellerInfo, seller)
    }

    @MainActor
    func test_build_withReviewAndConfirmCalledTwice_shouldKeepOnlyOneConfiguration() {
        // Arrange
        let sut = self.makePaymentBuilder()

        // Act
        let checkout = sut
            .withReviewAndConfirm()
            .withReviewAndConfirm()
            .build()

        // Assert
        XCTAssertEqual(checkout.configuration.screenConfigs.count, 1)
    }

    @MainActor
    func test_build_withStatusScreenCalledTwice_shouldKeepOnlyOneConfigurationAndUseLatestCallback() {
        let firstSpy = StatusScreenExitSpy()
        let latestSpy = StatusScreenExitSpy()
        let checkout = self.makePaymentBuilder()
            .withStatusScreen(exit: firstSpy.call)
            .withStatusScreen(exit: latestSpy.call)
            .build()

        checkout.configuration.statusScreenExit?()

        XCTAssertEqual(checkout.configuration.screenConfigs.count, 1)
        XCTAssertNotNil(checkout.configuration.statusScreenConfig)
        XCTAssertEqual(firstSpy.callCount, 0)
        XCTAssertEqual(latestSpy.callCount, 1)
    }

    @MainActor
    func test_build_withStatusScreenOnCardTransaction_shouldConfigureTheScreenAndPreserveSellerInfo() {
        let seller = MPSellerInfo(name: "Adidas Store", logoUrl: nil)
        let checkout = MercadoPagoCheckout<MPPaymentData.CardTransaction>.Builder(
            checkoutType: .cardTransaction(order: self.makeOrder(), sellerInfo: seller),
            checkoutAppearance: .init()
        )
        .withStatusScreen(exit: {})
        .build()

        XCTAssertNotNil(checkout.configuration.statusScreenConfig)
        XCTAssertEqual(checkout.configuration.sellerInfo, seller)
    }

    @MainActor
    func test_build_withStatusScreenOnPayment_shouldPreserveIndependentlyNullableSellerInfo() {
        let seller = MPSellerInfo(name: nil, logoUrl: "https://example.com/logo.png")
        let checkout = self.makePaymentBuilder(sellerInfo: seller)
            .withStatusScreen(exit: {})
            .build()

        XCTAssertEqual(checkout.configuration.sellerInfo, seller)
    }

    @MainActor
    func test_build_withReviewAndConfirmOnCardTransaction_shouldConfigureTheScreen() {
        // Arrange
        let sut = MercadoPagoCheckout<MPPaymentData.CardTransaction>.Builder(
            checkoutType: .cardTransaction(order: self.makeOrder()),
            checkoutAppearance: .init()
        )

        // Act
        let checkout = sut.withReviewAndConfirm().build()

        // Assert
        XCTAssertNotNil(checkout.configuration.reviewAndConfirmConfig)
    }

    @MainActor
    func test_build_withReviewAndConfirmOnPayment_shouldForwardEmailChangeCallback() {
        // Arrange — the payer_email row only exists in the Payment (ticket) flow.
        let sut = self.makePaymentBuilder()

        // Act
        let checkout = sut.withReviewAndConfirm(onEmailChangeRequested: {}).build()

        // Assert
        guard case let .reviewAndConfirm(onEmailChangeRequested) = checkout.configuration.reviewAndConfirmConfig else {
            return XCTFail("Expected a reviewAndConfirm config")
        }
        XCTAssertNotNil(onEmailChangeRequested)
    }

    @MainActor
    func test_build_withReviewAndConfirmOnCardTransaction_shouldNotSetEmailChangeCallback() {
        // Arrange — CardTransaction is a card-only flow: it never has a payer_email row, so the
        // builder doesn't even expose onEmailChangeRequested; the config must always carry nil.
        let sut = MercadoPagoCheckout<MPPaymentData.CardTransaction>.Builder(
            checkoutType: .cardTransaction(order: self.makeOrder()),
            checkoutAppearance: .init()
        )

        // Act
        let checkout = sut.withReviewAndConfirm().build()

        // Assert
        guard case let .reviewAndConfirm(onEmailChangeRequested) = checkout.configuration.reviewAndConfirmConfig else {
            return XCTFail("Expected a reviewAndConfirm config")
        }
        XCTAssertNil(onEmailChangeRequested)
    }

    // MARK: - Helpers

    private func makeOrder() -> MPOrder {
        MPOrder(orderId: "ORD01", clientToken: "client_token")
    }

    @MainActor
    private func makePaymentBuilder(
        sellerInfo: MPSellerInfo? = nil
    ) -> MercadoPagoCheckout<MPPaymentData.Payment>.Builder {
        MercadoPagoCheckout<MPPaymentData.Payment>.Builder(
            checkoutType: .payment(order: self.makeOrder(), sellerInfo: sellerInfo),
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

@MainActor
private final class StatusScreenExitSpy {
    private(set) var callCount = 0

    func call() {
        self.callCount += 1
    }
}
