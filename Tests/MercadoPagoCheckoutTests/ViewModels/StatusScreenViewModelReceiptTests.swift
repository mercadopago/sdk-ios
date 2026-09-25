//
//  StatusScreenViewModelReceiptTests.swift
//  MercadoPagoSDK
//

import Combine
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
        let sut = self.makeSUT(behavior: .success(self.pdfData))

        sut.viewModel.prepareReceipt(from: self.remoteURL)
        XCTAssertTrue(sut.viewModel.isPreparingReceipt)
        await self.waitForReceiptState(of: sut.viewModel) { $0 != .preparing }

        XCTAssertEqual(sut.viewModel.sharedReceipt?.url.lastPathComponent, "ticket.pdf")
        XCTAssertEqual(sut.repository.requestedURLs, [self.remoteURL])
    }

    func test_prepareReceipt_WhenRepositoryFails_ShouldReturnToIdle() async {
        let sut = self.makeSUT(behavior: .failure(self.makeError()))

        sut.viewModel.prepareReceipt(from: self.remoteURL)
        await self.waitForReceiptState(of: sut.viewModel) { $0 != .preparing }

        XCTAssertEqual(sut.viewModel.receiptState, .idle)
    }

    func test_prepareReceipt_WhenAlreadyPreparing_ShouldGenerateOnlyOnce() async {
        let sut = self.makeSUT(behavior: .suspended(self.pdfData))

        sut.viewModel.prepareReceipt(from: self.remoteURL)
        await sut.repository.waitUntilCalled()
        sut.viewModel.prepareReceipt(from: self.remoteURL)

        XCTAssertEqual(sut.repository.requestedURLs.count, 1)
        sut.repository.resume()
        await self.waitForReceiptState(of: sut.viewModel) { $0 != .preparing }
    }

    func test_prepareReceipt_WhenSharing_ShouldIgnoreNewRequest() async throws {
        let (sut, sharedURL) = try await self.makeSharingSUT()

        sut.viewModel.prepareReceipt(from: self.remoteURL)

        XCTAssertEqual(sut.repository.requestedURLs.count, 1)
        XCTAssertEqual(sut.viewModel.sharedReceipt?.url, sharedURL)
    }

    func test_finishSharing_WhenSharing_ShouldDeleteFileAndReturnToIdle() async throws {
        let (sut, sharedURL) = try await self.makeSharingSUT()

        sut.viewModel.finishSharing()

        XCTAssertEqual(sut.viewModel.receiptState, .idle)
        XCTAssertFalse(FileManager.default.fileExists(atPath: sharedURL.path))
    }

    func test_cancelReceipt_WhenPreparing_ShouldReturnToIdleAndIgnoreLateResult() async {
        let sut = self.makeSUT(behavior: .suspended(self.pdfData))
        sut.viewModel.prepareReceipt(from: self.remoteURL)
        await sut.repository.waitUntilCalled()

        sut.viewModel.cancelReceipt()
        XCTAssertEqual(sut.viewModel.receiptState, .idle)

        let lateChange = self.expectation(description: "No state change after cancellation")
        lateChange.isInverted = true
        let cancellable = sut.viewModel.$receiptState.dropFirst().sink { _ in lateChange.fulfill() }
        sut.repository.resume()
        await self.fulfillment(of: [lateChange], timeout: 0.2)
        cancellable.cancel()
    }

    func test_cancelReceipt_WhenSharing_ShouldKeepSharedFile() async throws {
        let (sut, sharedURL) = try await self.makeSharingSUT()

        sut.viewModel.cancelReceipt()

        XCTAssertEqual(sut.viewModel.sharedReceipt?.url, sharedURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: sharedURL.path))
    }
}

private extension StatusScreenViewModelReceiptTests {
    typealias SUT = (
        viewModel: StatusScreenViewModel,
        repository: MockReceiptDocumentRepository
    )

    func makeSUT(behavior: MockReceiptDocumentRepository.Behavior) -> SUT {
        let repository = MockReceiptDocumentRepository(behavior: behavior)
        let viewModel = StatusScreenViewModel(
            orderID: "ORDER-TEST",
            clientToken: "client-token",
            lastFourDigits: "0000",
            sellerInfo: nil,
            paymentTypeId: "ticket",
            useCase: MockStatusScreenUseCase(behavior: .failure(self.makeError())),
            receiptUseCase: GenerateReceiptDocumentUseCase(pdfRepository: repository, webPageRepository: repository)
        )
        return (viewModel, repository)
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
        let reached = self.expectation(description: "Receipt state reached")
        let cancellable = viewModel.$receiptState.first(where: predicate).sink { _ in reached.fulfill() }
        await self.fulfillment(of: [reached], timeout: 1)
        cancellable.cancel()
    }
}
