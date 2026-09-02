//
//  InstallmentsScreenViewModelTrackingTests.swift
//  MercadoPagoSDK
//

import CommonTests
@testable import MercadoPagoCheckout
import SwiftUI
import XCTest

@MainActor
final class InstallmentsScreenViewModelTrackingTests: XCTestCase {
    // MARK: - Types

    typealias SUT = (
        viewModel: InstallmentsScreenViewModel,
        analytics: MockAnalytics,
        errorObservability: MockErrorObservability
    )

    // MARK: - Helpers

    private func makeSUT(
        checkoutType: String = "card_payment_brick",
        installmentsData: MPInstallmentsData = .validMPInstallmentsData
    ) -> SUT {
        let analytics = MockAnalytics()
        let errorObservability = MockErrorObservability(eventID: "checkout-event")
        var data = installmentsData
        let viewModel = InstallmentsScreenViewModel(
            installmentsData: Binding(get: { data }, set: { data = $0 }),
            checkoutType: checkoutType,
            analytics: analytics,
            errorObservability: errorObservability
        )
        return (viewModel, analytics, errorObservability)
    }

    // MARK: - trackInitialize

    func test_trackInitialize_shouldTrackInitializePath() async {
        // Arrange
        let sut = self.makeSUT()

        // Act
        sut.viewModel.trackInitialize(transactionAmount: 500.0, paymentMethodId: "visa", orderId: "")
        await sut.analytics.mock.waitForSend()

        // Assert
        let messages = await sut.analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.trackView(InstallmentAnalyticsPath.initialize)))
        XCTAssertTrue(messages.contains(.send))
    }

    func test_trackInitialize_shouldSendAllFields() async {
        // Arrange
        let sut = self.makeSUT(checkoutType: "card_payment_brick")

        // Act
        sut.viewModel.trackInitialize(transactionAmount: 500.0, paymentMethodId: "visa", orderId: "")
        await sut.analytics.mock.waitForSend()

        // Assert
        let messages = await sut.analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.setEventData([
            "checkout_type": "card_payment_brick",
            "payment_method_id": "visa",
            "payment_type": "credit_card",
            "selection_type": "radio_button",
            "quotas_count": 3,
            "transaction_amount": Decimal(500),
            "order_id": "NOT_APPLY"
        ])))
    }

    // MARK: - trackSelected

    func test_trackSelected_shouldTrackSelectedPath() async {
        // Arrange
        let sut = self.makeSUT()
        let quota = CardPaymentBrickCardData.Installment.Quota.make(installments: 3)

        // Act
        sut.viewModel.trackSelected(quota)
        await sut.analytics.mock.waitForSend()

        // Assert
        let messages = await sut.analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.track(path: InstallmentAnalyticsPath.selected)))
        XCTAssertTrue(messages.contains(.send))
    }

    func test_trackSelected_shouldSendInstallmentsCount() async {
        // Arrange
        let sut = self.makeSUT()
        let quota = CardPaymentBrickCardData.Installment.Quota.make(installments: 6)

        // Act
        sut.viewModel.trackSelected(quota)
        await sut.analytics.mock.waitForSend()

        // Assert
        let messages = await sut.analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.setEventData(["installments": 6])))
    }

    // MARK: - trackSubmit

    func test_trackSubmit_shouldTrackSubmitPath() async {
        // Arrange
        let sut = self.makeSUT()
        let quota = CardPaymentBrickCardData.Installment.Quota.make(
            installments: 3,
            installmentAmount: 333.34,
            totalAmount: 1000.0
        )

        // Act
        sut.viewModel.trackSubmit(quota)
        await sut.analytics.mock.waitForSend()

        // Assert
        let messages = await sut.analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.track(path: InstallmentAnalyticsPath.submit)))
        XCTAssertTrue(messages.contains(.send))
    }

    func test_trackSubmit_shouldSendInstallmentData() async {
        // Arrange
        let sut = self.makeSUT()
        let quota = CardPaymentBrickCardData.Installment.Quota.make(
            installments: 3,
            installmentAmount: 333.34,
            totalAmount: 1000.0
        )

        // Act
        sut.viewModel.trackSubmit(quota)
        await sut.analytics.mock.waitForSend()

        // Assert
        let messages = await sut.analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.setEventData([
            "installments": 3,
            "installment_amount": 333.34 as Decimal,
            "total_amount": Decimal(1000)
        ])))
    }

    // MARK: - trackCanceledError

    func test_trackCanceledError_shouldTrackUserCanceledErrorPath() async {
        // Arrange
        let sut = self.makeSUT()

        // Act
        sut.viewModel.trackCanceledError(errorType: "back_pressed")
        await sut.analytics.mock.waitForSend()

        // Assert
        let messages = await sut.analytics.mock.getMessages()
        let eventIDs = await sut.analytics.mock.getObservabilityEventIDs()
        XCTAssertTrue(messages.contains(.track(path: InstallmentAnalyticsPath.userCanceledError)))
        XCTAssertTrue(messages.contains(.send))
        XCTAssertEqual(eventIDs, ["checkout-event"])
        XCTAssertEqual(sut.errorObservability.recordedErrors().map(\.operation), [.installmentsCancellation])
    }

    func test_trackCanceledError_backPressed_shouldSendBackPressedErrorType() async {
        // Arrange
        let sut = self.makeSUT()

        // Act
        sut.viewModel.trackCanceledError(errorType: "back_pressed")
        await sut.analytics.mock.waitForSend()

        // Assert
        let messages = await sut.analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.setEventData(["error_type": "back_pressed"])))
    }

    func test_trackCanceledError_userDismissed_shouldSendUserDismissedErrorType() async {
        // Arrange
        let sut = self.makeSUT()

        // Act
        sut.viewModel.trackCanceledError(errorType: "user_dismissed")
        await sut.analytics.mock.waitForSend()

        // Assert
        let messages = await sut.analytics.mock.getMessages()
        XCTAssertTrue(messages.contains(.setEventData(["error_type": "user_dismissed"])))
    }

    // MARK: - Chevron: selected + submit in same tap

    func test_chevronTap_shouldFireSelectedThenSubmit() async {
        // Arrange
        let sut = self.makeSUT()
        let quota = CardPaymentBrickCardData.Installment.Quota.make(installments: 3)

        // Act — simulates a Chevron tap: selected fires first, then submit
        sut.viewModel.trackSelected(quota)
        sut.viewModel.trackSubmit(quota)
        await sut.analytics.mock.waitForSend(count: 2)

        // Assert — selected arrives before submit
        let messages = await sut.analytics.mock.getMessages()
        let sendIndices = messages.indices.filter { messages[$0] == .send }
        XCTAssertEqual(sendIndices.count, 2)

        let firstGroup = Array(messages[0 ..< sendIndices[0]])
        XCTAssertTrue(firstGroup.contains(.track(path: InstallmentAnalyticsPath.selected)))
        XCTAssertFalse(firstGroup.contains(.track(path: InstallmentAnalyticsPath.submit)))

        let secondGroup = Array(messages[(sendIndices[0] + 1) ..< sendIndices[1]])
        XCTAssertTrue(secondGroup.contains(.track(path: InstallmentAnalyticsPath.submit)))
        XCTAssertFalse(secondGroup.contains(.track(path: InstallmentAnalyticsPath.selected)))
    }
}
