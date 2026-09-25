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
        let loaded = expectation(description: "Web page finished loading")
        let navigationDelegate = WebViewNavigationDelegate(onCompletion: loaded.fulfill)
        webView.navigationDelegate = navigationDelegate
        webView.loadHTMLString("<html><body><h1>Comprovante</h1></body></html>", baseURL: nil)

        await fulfillment(of: [loaded], timeout: 15)
        withExtendedLifetime(navigationDelegate) {}
        XCTAssertNil(navigationDelegate.error)
        let data = try ReceiptPDFRenderer().render(formatter: webView.viewPrintFormatter())

        XCTAssertTrue(data.starts(with: ReceiptPDFRenderer.pdfSignature))
    }
}

@MainActor
private final class WebViewNavigationDelegate: NSObject, WKNavigationDelegate {
    private let onCompletion: () -> Void
    private(set) var error: Error?
    private var didComplete = false

    init(onCompletion: @escaping () -> Void) {
        self.onCompletion = onCompletion
    }

    func webView(_: WKWebView, didFinish _: WKNavigation?) {
        self.complete()
    }

    func webView(_: WKWebView, didFail _: WKNavigation?, withError error: Error) {
        self.complete(error: error)
    }

    func webView(_: WKWebView, didFailProvisionalNavigation _: WKNavigation?, withError error: Error) {
        self.complete(error: error)
    }

    private func complete(error: Error? = nil) {
        guard !self.didComplete else { return }
        self.didComplete = true
        self.error = error
        self.onCompletion()
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
