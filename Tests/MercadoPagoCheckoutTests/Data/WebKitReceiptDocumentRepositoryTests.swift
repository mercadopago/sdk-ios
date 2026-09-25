//
//  WebKitReceiptDocumentRepositoryTests.swift
//  MercadoPagoSDK
//

import Foundation
@testable import MercadoPagoCheckout
import UIKit
import WebKit
import XCTest

@MainActor
final class WebKitReceiptDocumentRepositoryTests: XCTestCase {
    func test_rejectionReason_WhenHTMLResponseIsValid_ShouldAccept() throws {
        let response = try self.makeResponse(contentType: "text/html; charset=utf-8", contentLength: 2048)

        XCTAssertNil(WebKitReceiptDocumentRepository.rejectionReason(for: response))
    }

    func test_rejectionReason_WhenContentLengthIsMissing_ShouldAcceptAndRelyOnPageLimit() throws {
        let response = try self.makeResponse(contentType: "text/html", contentLength: nil)

        XCTAssertNil(WebKitReceiptDocumentRepository.rejectionReason(for: response))
    }

    func test_rejectionReason_WhenDocumentIsOversized_ShouldRejectBeforeRendering() throws {
        let response = try self.makeResponse(
            contentType: "text/html",
            contentLength: ReceiptPDFRenderer.maximumPDFBytes + 1
        )

        XCTAssertEqual(WebKitReceiptDocumentRepository.rejectionReason(for: response), "file_too_large")
    }

    func test_rejectionReason_WhenStatusIsNotSuccess_ShouldRejectAsInvalidResponse() throws {
        let response = try self.makeResponse(statusCode: 500, contentType: "text/html", contentLength: 10)

        XCTAssertEqual(WebKitReceiptDocumentRepository.rejectionReason(for: response), "invalid_response")
    }

    func test_rejectionReason_WhenContentIsNotWebPage_ShouldRejectAsUnsupportedContent() throws {
        let response = try self.makeResponse(contentType: "application/json", contentLength: 10)

        XCTAssertEqual(WebKitReceiptDocumentRepository.rejectionReason(for: response), "unsupported_content")
    }

    func test_render_WhenFormatterHasHTML_ShouldCreateBoundedPDF() throws {
        let formatter = UIMarkupTextPrintFormatter(
            markupText: "<html><body><h1>Comprovante</h1><p>Pagamento aprovado</p></body></html>"
        )

        let data = try ReceiptPDFRenderer().render(formatter: formatter)

        XCTAssertTrue(data.starts(with: ReceiptPDFRenderer.pdfSignature))
        XCTAssertLessThanOrEqual(data.count, ReceiptPDFRenderer.maximumPDFBytes)
    }

    func test_render_WhenWebPageIsLoaded_ShouldCreatePDF() async throws {
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        webView.loadHTMLString("<html><body><h1>Comprovante</h1></body></html>", baseURL: nil)
        let loaded = expectation(for: NSPredicate { object, _ in
            guard let webView = object as? WKWebView else { return false }
            return !webView.isLoading && webView.estimatedProgress >= 1
        }, evaluatedWith: webView)

        await fulfillment(of: [loaded], timeout: 5)
        let data = try ReceiptPDFRenderer().render(formatter: webView.viewPrintFormatter())

        XCTAssertTrue(data.starts(with: ReceiptPDFRenderer.pdfSignature))
    }
}

private extension WebKitReceiptDocumentRepositoryTests {
    func makeResponse(
        statusCode: Int = 200,
        contentType: String,
        contentLength: Int?
    ) throws -> HTTPURLResponse {
        var headers = ["Content-Type": contentType]
        headers["Content-Length"] = contentLength.map(String.init)
        return try XCTUnwrap(HTTPURLResponse(
            url: XCTUnwrap(URL(string: "https://www.mercadopago.com.ar/payments/test/ticket")),
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: headers
        ))
    }
}
