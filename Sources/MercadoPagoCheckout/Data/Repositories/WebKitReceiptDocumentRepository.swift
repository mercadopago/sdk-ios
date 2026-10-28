//
//  WebKitReceiptDocumentRepository.swift
//  MercadoPagoSDK
//

import Foundation
import UIKit
import WebKit

@MainActor
final class WebKitReceiptDocumentRepository: NSObject, ReceiptDocumentRepository {
    private typealias LoadContinuation = CheckedContinuation<Void, Error>

    private static let webPageMIMETypes: Set<String> = ["text/html", "application/xhtml+xml"]

    private var requestedURL: URL?
    private var loadContinuation: LoadContinuation?
    private var timeoutTask: Task<Void, Never>?

    func fetchPDF(from url: URL) async throws -> Data {
        guard self.loadContinuation == nil else { throw Self.receiptError("render_failed") }

        let webView = self.makeWebView()
        self.requestedURL = url
        defer { tearDown(webView) }

        try await self.load(url, in: webView)
        try Task.checkCancellation()
        return try ReceiptPDFRenderer().render(formatter: webView.viewPrintFormatter())
    }

    private func makeWebView() -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = false
        let webView = WKWebView(
            frame: CGRect(x: 0, y: 0, width: 390, height: 844),
            configuration: configuration
        )
        webView.navigationDelegate = self
        webView.isUserInteractionEnabled = false
        return webView
    }

    private func load(_ url: URL, in webView: WKWebView) async throws {
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { (continuation: LoadContinuation) in
                self.loadContinuation = continuation
                self.timeoutTask = Task { [weak self] in
                    try? await Task.sleep(nanoseconds: 15_000_000_000)
                    guard !Task.isCancelled else { return }
                    self?.finishLoading(.failure(Self.receiptError("timed_out", code: .networkTimeout)))
                }
                webView.load(URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData))
            }
        } onCancel: {
            Task { @MainActor [weak self] in
                self?.finishLoading(.failure(CancellationError()))
            }
        }
    }

    private func finishLoading(_ result: Result<Void, Error>) {
        guard let continuation = loadContinuation else { return }
        self.loadContinuation = nil
        self.timeoutTask?.cancel()
        self.timeoutTask = nil
        continuation.resume(with: result)
    }

    /// Receipt failures surface as `MercadoPagoCheckoutError`, with the cause in `errorUserInfo["receipt_reason"]`.
    fileprivate static func receiptError(
        _ reason: String,
        code: MercadoPagoCheckoutError.Code = .serviceError
    ) -> MercadoPagoCheckoutError {
        MercadoPagoCheckoutError(
            code: code,
            localizedDescription: "Status Screen receipt is unavailable",
            userInfo: ["receipt_reason": reason],
            location: .initialization
        )
    }

    private func tearDown(_ webView: WKWebView) {
        webView.stopLoading()
        webView.navigationDelegate = nil
        self.requestedURL = nil
    }
}

extension WebKitReceiptDocumentRepository: WKNavigationDelegate {
    func webView(
        _: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void
    ) {
        guard navigationAction.targetFrame?.isMainFrame != false else {
            decisionHandler(.allow)
            return
        }
        guard navigationAction.request.url == self.requestedURL else {
            self.finishLoading(.failure(Self.receiptError("redirect")))
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    func webView(
        _: WKWebView,
        decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping @MainActor (WKNavigationResponsePolicy) -> Void
    ) {
        guard navigationResponse.isForMainFrame else {
            decisionHandler(.allow)
            return
        }
        if let reason = Self.rejectionReason(for: navigationResponse.response) {
            self.finishLoading(.failure(Self.receiptError(reason)))
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    /// Checked before WebKit parses the document, so an oversized page is refused before any layout
    /// or rendering runs on the main thread. Responses without `Content-Length` (chunked) still fall
    /// back to the page limit that `ReceiptPDFRenderer` enforces after layout and before drawing.
    static func rejectionReason(for response: URLResponse) -> String? {
        guard let response = response as? HTTPURLResponse, (200 ... 299).contains(response.statusCode) else {
            return "invalid_response"
        }
        guard let mimeType = response.mimeType?.lowercased(), Self.webPageMIMETypes.contains(mimeType) else {
            return "unsupported_content"
        }
        guard response.expectedContentLength <= Int64(ReceiptPDFRenderer.maximumPDFBytes) else {
            return "file_too_large"
        }
        return nil
    }

    func webView(_: WKWebView, didFinish _: WKNavigation?) {
        self.finishLoading(.success(()))
    }

    func webView(_: WKWebView, didFail _: WKNavigation?, withError _: Error) {
        self.finishLoading(.failure(Self.receiptError("invalid_response")))
    }

    func webView(_: WKWebView, didFailProvisionalNavigation _: WKNavigation?, withError _: Error) {
        self.finishLoading(.failure(Self.receiptError("invalid_response")))
    }

    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation _: WKNavigation?) {
        self.finishLoading(.failure(Self.receiptError("redirect")))
        webView.stopLoading()
    }

    func webViewWebContentProcessDidTerminate(_: WKWebView) {
        self.finishLoading(.failure(Self.receiptError("render_failed")))
    }
}

@MainActor
struct ReceiptPDFRenderer {
    nonisolated static let maximumPDFBytes = 10_485_760
    static let maximumPageCount = 20
    nonisolated static let pdfSignature = Data("%PDF-".utf8)

    func render(formatter: UIPrintFormatter) throws -> Data {
        let renderer = ReceiptPageRenderer()
        renderer.addPrintFormatter(formatter, startingAtPageAt: 0)
        let pageCount = renderer.numberOfPages
        guard pageCount > 0, pageCount <= Self.maximumPageCount else {
            throw WebKitReceiptDocumentRepository.receiptError("render_failed")
        }

        let output = NSMutableData()
        UIGraphicsBeginPDFContextToData(output, renderer.paperRect, nil)
        for pageIndex in 0 ..< pageCount {
            UIGraphicsBeginPDFPageWithInfo(renderer.paperRect, nil)
            renderer.drawPage(at: pageIndex, in: renderer.paperRect)
        }
        UIGraphicsEndPDFContext()

        let data = output as Data
        guard data.starts(with: Self.pdfSignature) else {
            throw WebKitReceiptDocumentRepository.receiptError("render_failed")
        }
        guard data.count <= Self.maximumPDFBytes else {
            throw WebKitReceiptDocumentRepository.receiptError("file_too_large")
        }
        return data
    }
}

private final class ReceiptPageRenderer: UIPrintPageRenderer {
    private static let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)

    override var paperRect: CGRect { Self.page }
    override var printableRect: CGRect { Self.page.insetBy(dx: 36, dy: 36) }
}
