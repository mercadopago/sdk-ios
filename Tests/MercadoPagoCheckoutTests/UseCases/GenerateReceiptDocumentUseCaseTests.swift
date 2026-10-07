//
//  GenerateReceiptDocumentUseCaseTests.swift
//  MercadoPagoSDK
//

import Foundation
@testable import MercadoPagoCheckout
import XCTest

@MainActor
final class GenerateReceiptDocumentUseCaseTests: XCTestCase {
    private let pdfData = Data("%PDF-1.4 receipt".utf8)
    private let receiptsDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("Receipts")

    override func tearDown() {
        try? FileManager.default.removeItem(at: self.receiptsDirectory)
        super.tearDown()
    }

    func test_execute_WhenURLHasPDFExtension_ShouldUsePDFRepositoryAndSaveFile() async throws {
        let sut = self.makeSUT()
        let url = try XCTUnwrap(URL(string: "https://www.mercadopago.com.ar/ticket.PDF?token=abc"))

        let localURL = try await sut.useCase.execute(from: url, paymentTypeId: "ticket")

        XCTAssertEqual(sut.pdfRepository.requestedURLs, [url])
        XCTAssertTrue(sut.webPageRepository.requestedURLs.isEmpty)
        XCTAssertTrue(localURL.lastPathComponent.hasPrefix("ticket-"))
        XCTAssertEqual(localURL.pathExtension, "pdf")
        XCTAssertEqual(try Data(contentsOf: localURL), self.pdfData)
    }

    func test_execute_WhenURLIsWebPage_ShouldUseWebPageRepository() async throws {
        let sut = self.makeSUT()
        let url = try XCTUnwrap(URL(string: "https://www.mercadopago.com.ar/payments/test/ticket?payment_id=1"))

        _ = try await sut.useCase.execute(from: url, paymentTypeId: "ticket")

        XCTAssertEqual(sut.webPageRepository.requestedURLs, [url])
        XCTAssertTrue(sut.pdfRepository.requestedURLs.isEmpty)
    }

    func test_execute_WhenCancelledWhileFetching_ShouldThrowWithoutSavingFile() async throws {
        let sut = self.makeSUT(behavior: .suspended(self.pdfData))
        let url = try XCTUnwrap(URL(string: "https://www.mercadopago.com.ar/ticket.pdf"))

        let task = Task { try await sut.useCase.execute(from: url, paymentTypeId: "ticket") }
        await sut.pdfRepository.waitUntilCalled()
        task.cancel()
        sut.pdfRepository.resume()

        let result = await task.result
        XCTAssertThrowsError(try result.get()) { XCTAssertTrue($0 is CancellationError) }
        XCTAssertFalse(FileManager.default.fileExists(atPath: self.receiptsDirectory.path))
    }

    func test_fileName_WhenPaymentTypeIsUnsafeOrMissing_ShouldSanitizeOrFallBack() {
        XCTAssertEqual(GenerateReceiptDocumentUseCase.fileName(for: "ticket"), "ticket")
        XCTAssertEqual(GenerateReceiptDocumentUseCase.fileName(for: "Bank_Transfer"), "bank_transfer")
        XCTAssertEqual(GenerateReceiptDocumentUseCase.fileName(for: "../../etc/passwd"), "etcpasswd")
        XCTAssertEqual(GenerateReceiptDocumentUseCase.fileName(for: ""), "receipt")
        XCTAssertEqual(GenerateReceiptDocumentUseCase.fileName(for: nil), "receipt")
    }
}

private extension GenerateReceiptDocumentUseCaseTests {
    typealias SUT = (
        useCase: GenerateReceiptDocumentUseCase,
        pdfRepository: MockReceiptDocumentRepository,
        webPageRepository: MockReceiptDocumentRepository
    )

    func makeSUT(behavior: MockReceiptDocumentRepository.Behavior? = nil) -> SUT {
        let pdfRepository = MockReceiptDocumentRepository(behavior: behavior ?? .success(self.pdfData))
        let webPageRepository = MockReceiptDocumentRepository(behavior: behavior ?? .success(self.pdfData))
        let useCase = GenerateReceiptDocumentUseCase(
            pdfRepository: pdfRepository,
            webPageRepository: webPageRepository
        )
        return (useCase, pdfRepository, webPageRepository)
    }
}
