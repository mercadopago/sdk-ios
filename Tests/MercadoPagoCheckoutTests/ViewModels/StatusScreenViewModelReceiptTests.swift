//
//  StatusScreenViewModelReceiptTests.swift
//  MercadoPagoSDK
//

import Combine
import CommonTests
import Foundation
@testable import MercadoPagoCheckout
import XCTest

/// Runs the view model through the real `GenerateReceiptDocumentUseCase`, so shared receipts are real files.
@MainActor
final class StatusScreenViewModelReceiptTests: XCTestCase {
    private let pdfData = Data("%PDF-1.4 receipt".utf8)
    private let remoteURL = URL(string: "https://www.mercadopago.com.ar/payments/test/ticket")!

    override func tearDown() {
        try? FileManager.default.removeItem(
            at: FileManager.default.temporaryDirectory.appendingPathComponent("Receipts")
        )
        super.tearDown()
    }

    func test_prepareReceipt_WhenRepositorySucceeds_ShouldShareLocalFile() async throws {
        let sut = makeSUT(behavior: .success(pdfData))

        sut.viewModel.prepareReceipt(from: self.remoteURL)
        XCTAssertTrue(sut.viewModel.isPreparingReceipt)
        await waitForReceiptState(of: sut.viewModel) { $0 != .preparing }

        XCTAssertEqual(sut.viewModel.sharedReceipt?.url.lastPathComponent, "ticket.pdf")
        XCTAssertEqual(sut.repository.requestedURLs, [self.remoteURL])
    }

    func test_prepareReceipt_WhenRepositoryFails_ShouldReturnToIdle() async {
        let sut = makeSUT(behavior: .failure(makeError()))

        sut.viewModel.prepareReceipt(from: self.remoteURL)
        await waitForReceiptState(of: sut.viewModel) { $0 != .preparing }
        await sut.analytics.mock.waitForSend(count: 2)

        XCTAssertEqual(sut.viewModel.receiptState, .idle)
        let messages = await sut.analytics.mock.getMessages()
        XCTAssertEqual(messages, [
            .track(path: StatusScreenAnalyticsPath.receipt),
            .setEventData(["outcome": "requested"]),
            .send,
            .track(path: StatusScreenAnalyticsPath.receipt),
            .setEventData(["outcome": "failure"]),
            .send
        ])
    }

    func test_prepareReceipt_WhenAlreadyPreparing_ShouldGenerateOnlyOnce() async {
        let sut = makeSUT(behavior: .suspended(pdfData))

        sut.viewModel.prepareReceipt(from: self.remoteURL)
        await sut.repository.waitUntilCalled()
        sut.viewModel.prepareReceipt(from: self.remoteURL)

        XCTAssertEqual(sut.repository.requestedURLs.count, 1)
        sut.repository.resume()
        await waitForReceiptState(of: sut.viewModel) { $0 != .preparing }
    }

    func test_prepareReceipt_WhenSharing_ShouldIgnoreNewRequest() async throws {
        let (sut, sharedURL) = try await makeSharingSUT()

        sut.viewModel.prepareReceipt(from: self.remoteURL)

        XCTAssertEqual(sut.repository.requestedURLs.count, 1)
        XCTAssertEqual(sut.viewModel.sharedReceipt?.url, sharedURL)
    }

    func test_finishSharing_WhenSharing_ShouldDeleteFileAndReturnToIdle() async throws {
        let (sut, sharedURL) = try await makeSharingSUT()

        sut.viewModel.finishSharing()
        await sut.analytics.mock.waitForSend(count: 3)

        XCTAssertEqual(sut.viewModel.receiptState, .idle)
        XCTAssertFalse(FileManager.default.fileExists(atPath: sharedURL.path))
        let messages = await sut.analytics.mock.getMessages()
        XCTAssertEqual(messages, [
            .track(path: StatusScreenAnalyticsPath.receipt),
            .setEventData(["outcome": "requested"]),
            .send,
            .track(path: StatusScreenAnalyticsPath.receipt),
            .setEventData(["outcome": "success"]),
            .send,
            .track(path: StatusScreenAnalyticsPath.receipt),
            .setEventData(["outcome": "dismissed"]),
            .send
        ])
        let description = String(describing: messages)
        XCTAssertFalse(description.contains(self.remoteURL.absoluteString))
        XCTAssertFalse(description.contains("ticket"))
    }

    func test_cancelReceipt_WhenPreparing_ShouldReturnToIdleAndIgnoreLateResult() async {
        let sut = makeSUT(behavior: .suspended(pdfData))
        sut.viewModel.prepareReceipt(from: self.remoteURL)
        await sut.repository.waitUntilCalled()

        sut.viewModel.cancelReceipt()
        XCTAssertEqual(sut.viewModel.receiptState, .idle)

        let lateChange = expectation(description: "No state change after cancellation")
        lateChange.isInverted = true
        let cancellable = sut.viewModel.$receiptState.dropFirst().sink { _ in lateChange.fulfill() }
        sut.repository.resume()
        await fulfillment(of: [lateChange], timeout: 0.2)
        cancellable.cancel()
    }

    func test_cancelReceipt_WhenSharing_ShouldKeepSharedFile() async throws {
        let (sut, sharedURL) = try await makeSharingSUT()

        sut.viewModel.cancelReceipt()

        XCTAssertEqual(sut.viewModel.sharedReceipt?.url, sharedURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: sharedURL.path))
    }
}

private extension StatusScreenViewModelReceiptTests {
    struct SUT {
        let viewModel: StatusScreenViewModel
        let repository: MockReceiptDocumentRepository
        let analytics: MockAnalytics
    }

    func makeSUT(behavior: MockReceiptDocumentRepository.Behavior) -> SUT {
        let repository = MockReceiptDocumentRepository(behavior: behavior)
        let analytics = MockAnalytics()
        let viewModel = StatusScreenViewModel(
            orderID: "ORDER-TEST",
            clientToken: "client-token",
            lastFourDigits: "0000",
            sellerInfo: nil,
            paymentTypeId: "ticket",
            useCase: MockStatusScreenUseCase(behavior: .failure(makeError())),
            receiptUseCase: GenerateReceiptDocumentUseCase(pdfRepository: repository, webPageRepository: repository),
            analytics: analytics
        )
        return SUT(viewModel: viewModel, repository: repository, analytics: analytics)
    }

    /// A view model already sharing a generated receipt, plus that receipt's local file.
    func makeSharingSUT() async throws -> (SUT, URL) {
        let sut = self.makeSUT(behavior: .success(self.pdfData))
        sut.viewModel.prepareReceipt(from: self.remoteURL)
        await self.waitForReceiptState(of: sut.viewModel) { $0 != .preparing }
        return try (sut, XCTUnwrap(sut.viewModel.sharedReceipt?.url))
    }

    func makeError() -> MercadoPagoCheckoutError {
        MercadoPagoCheckoutError(code: .serviceError, localizedDescription: "Unavailable", location: .initialization)
    }

    func waitForReceiptState(
        of viewModel: StatusScreenViewModel,
        where predicate: @escaping (StatusScreenViewModel.ReceiptState) -> Bool
    ) async {
        let reached = expectation(description: "Receipt state reached")
        let cancellable = viewModel.$receiptState.first(where: predicate).sink { _ in reached.fulfill() }
        await fulfillment(of: [reached], timeout: 1)
        cancellable.cancel()
    }
}
