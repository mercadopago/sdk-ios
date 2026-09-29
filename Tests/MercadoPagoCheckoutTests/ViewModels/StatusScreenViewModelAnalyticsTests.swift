//
//  StatusScreenViewModelAnalyticsTests.swift
//  MercadoPagoSDK
//

import CommonTests
import Foundation
@testable import MercadoPagoCheckout
import XCTest

@MainActor
final class StatusScreenViewModelAnalyticsTests: XCTestCase {
    func test_load_WhenUseCaseSucceeds_ShouldTrackStartedAndSuccess() async {
        let analytics = MockAnalytics()
        let sut = makeSUT(behavior: .success(makeSensitiveOutput()), analytics: analytics)

        await sut.viewModel.load()
        await analytics.mock.waitForSend(count: 2)

        let messages = await analytics.mock.getMessages()
        XCTAssertEqual(messages, [
            .track(path: StatusScreenAnalyticsPath.load),
            .setEventData(["outcome": "started"]),
            .send,
            .track(path: StatusScreenAnalyticsPath.load),
            .setEventData(["outcome": "success", "status_type": "approved"]),
            .send
        ])
    }

    func test_load_WhenUseCaseFails_ShouldTrackStartedAndFailure() async {
        let analytics = MockAnalytics()
        let error = MercadoPagoCheckoutError(
            code: .serviceError,
            localizedDescription: "Service failure",
            location: .initialization
        )
        let sut = makeSUT(behavior: .failure(error), analytics: analytics)

        await sut.viewModel.load()
        await analytics.mock.waitForSend(count: 2)

        let messages = await analytics.mock.getMessages()
        XCTAssertEqual(messages, [
            .track(path: StatusScreenAnalyticsPath.load),
            .setEventData(["outcome": "started"]),
            .send,
            .track(path: StatusScreenAnalyticsPath.load),
            .setEventData(["outcome": "failure"]),
            .send
        ])
    }

    func test_load_WhenCancelled_ShouldTrackStartedAndCancelled() async {
        let analytics = MockAnalytics()
        let sut = makeSUT(behavior: .suspended(makeSensitiveOutput()), analytics: analytics)
        let load = Task { await sut.viewModel.load() }
        await sut.useCase.waitUntilCalled()

        load.cancel()
        await sut.useCase.resume()
        await load.value
        await analytics.mock.waitForSend(count: 2)

        let messages = await analytics.mock.getMessages()
        XCTAssertEqual(messages, [
            .track(path: StatusScreenAnalyticsPath.load),
            .setEventData(["outcome": "started"]),
            .send,
            .track(path: StatusScreenAnalyticsPath.load),
            .setEventData(["outcome": "cancelled"]),
            .send
        ])
    }

    func test_actions_ShouldTrackOnlyCategoricalRedactedPayloads() async {
        let analytics = MockAnalytics()
        let sut = makeSUT(behavior: .success(makeSensitiveOutput()), analytics: analytics)

        await sut.viewModel.load()
        await analytics.mock.waitForSend(count: 2)
        sut.viewModel.trackRender()
        sut.viewModel.trackClose(source: .back)
        await analytics.mock.waitForSend(count: 4)

        let messages = await analytics.mock.getMessages()
        XCTAssertEqual(Array(messages.suffix(6)), [
            .trackView(StatusScreenAnalyticsPath.render),
            .setEventData(["status_type": "approved"]),
            .send,
            .track(path: StatusScreenAnalyticsPath.close),
            .setEventData(["source": "back", "status_type": "approved"]),
            .send
        ])

        let description = String(describing: messages)
        XCTAssertFalse(description.contains("ORD-PRIVATE-123"))
        XCTAssertFalse(description.contains("client-secret"))
        XCTAssertFalse(description.contains("1234"))
        XCTAssertFalse(description.contains("Seller private name"))
        XCTAssertFalse(description.contains("private.example"))
        XCTAssertFalse(description.contains("1234567890123456"))
    }

    func test_repeatedRenderAndClose_ShouldTrackEachOnlyOnce() async {
        let analytics = MockAnalytics()
        let sut = makeSUT(behavior: .success(makeSensitiveOutput()), analytics: analytics)

        await sut.viewModel.load()
        await analytics.mock.waitForSend(count: 2)
        sut.viewModel.trackRender()
        sut.viewModel.trackRender()
        sut.viewModel.trackClose(source: .back)
        sut.viewModel.trackClose(source: .dismiss)
        await analytics.mock.waitForSend(count: 4)

        let messages = await analytics.mock.getMessages()
        XCTAssertEqual(Array(messages.suffix(6)), [
            .trackView(StatusScreenAnalyticsPath.render),
            .setEventData(["status_type": "approved"]),
            .send,
            .track(path: StatusScreenAnalyticsPath.close),
            .setEventData(["source": "back", "status_type": "approved"]),
            .send
        ])
    }
}

private extension StatusScreenViewModelAnalyticsTests {
    func makeSUT(
        behavior: MockStatusScreenUseCase.Behavior,
        analytics: MockAnalytics
    ) -> (viewModel: StatusScreenViewModel, useCase: MockStatusScreenUseCase) {
        let useCase = MockStatusScreenUseCase(behavior: behavior)
        let viewModel = StatusScreenViewModel(
            orderID: "ORD-PRIVATE-123",
            clientToken: "client-secret",
            lastFourDigits: "1234",
            sellerInfo: MPSellerInfo(
                name: "Seller private name",
                logoUrl: "https://private.example/icon.png"
            ),
            paymentTypeId: "ticket",
            useCase: useCase,
            analytics: analytics
        )
        return (viewModel, useCase)
    }

    func makeSensitiveOutput() -> StatusScreenOutput {
        StatusScreenOutput(
            statusType: "approved",
            header: .init(
                title: "Approved",
                iconURL: URL(string: "https://private.example/status.png")!
            ),
            body: [
                .listItem(.init(title: "Seller private name", subtitle: nil, leading: nil)),
                .barcode(.init(
                    content: "1234567890123456",
                    codeFormatted: "1234 5678 9012 3456",
                    copyLabel: "Copy",
                    copyFeedback: "Copied"
                ))
            ],
            footerButtons: [.init(label: "Back", action: .back, style: nil)]
        )
    }
}
