//
//  RemoteReceiptPDFRepositoryTests.swift
//  MercadoPagoSDK
//

import CommonTests
import Foundation
@testable import MercadoPagoCheckout
import XCTest

@MainActor
final class RemoteReceiptPDFRepositoryTests: XCTestCase {
    private let url = URL(string: "https://www.mercadopago.com.ar/payments/test/ticket.pdf")!
    private let pdfBody = Data("%PDF-1.4 receipt".utf8)

    func test_fetchPDF_WhenBodyHasPDFSignature_ShouldReturnBytesWhateverTheContentType() async throws {
        for contentType in ["application/pdf", "application/json"] {
            let sut = await self.makeSUT(statusCode: 200, contentType: contentType, body: self.pdfBody)

            let data = try await sut.fetchPDF(from: self.url)

            XCTAssertEqual(data, self.pdfBody, contentType)
        }
    }

    func test_fetchPDF_WhenBodyIsNotPDF_ShouldThrowUnsupportedContent() async {
        let sut = await self.makeSUT(statusCode: 200, contentType: "application/pdf", body: Data("<html>".utf8))

        await self.assertThrows(reason: "unsupported_content", sut)
    }

    func test_fetchPDF_WhenServerRedirects_ShouldThrowRedirect() async {
        let sut = await self.makeSUT(statusCode: 302, contentType: "text/html", body: Data())

        await self.assertThrows(reason: "redirect", sut)
    }

    func test_fetchPDF_WhenServerFails_ShouldThrowInvalidResponse() async {
        let sut = await self.makeSUT(statusCode: 500, contentType: "application/json", body: Data())

        await self.assertThrows(reason: "invalid_response", sut)
    }

    func test_fetchPDF_WhenFileIsTooLarge_ShouldThrowFileTooLarge() async {
        var body = ReceiptPDFRenderer.pdfSignature
        body.append(Data(count: ReceiptPDFRenderer.maximumPDFBytes))
        let sut = await self.makeSUT(statusCode: 200, contentType: "application/pdf", body: body)

        await self.assertThrows(reason: "file_too_large", sut)
    }
}

private extension RemoteReceiptPDFRepositoryTests {
    func makeSUT(statusCode: Int, contentType: String, body: Data) async -> RemoteReceiptPDFRepository {
        let session = MockURLSession()
        await session.mock.setData(body)
        await session.mock.setResponse(HTTPURLResponse(
            url: self.url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": contentType]
        )!)
        return RemoteReceiptPDFRepository(session: session)
    }

    func assertThrows(
        reason expected: String,
        _ sut: RemoteReceiptPDFRepository,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        do {
            _ = try await sut.fetchPDF(from: self.url)
            XCTFail("Expected \(expected)", file: file, line: line)
        } catch {
            XCTAssertEqual(error.receiptReason, expected, file: file, line: line)
        }
    }
}
