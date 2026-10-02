//
//  RemoteReceiptPDFRepository.swift
//  MercadoPagoSDK
//

import Foundation
#if SWIFT_PACKAGE
    import MPCore
#endif

struct RemoteReceiptPDFRepository: ReceiptDocumentRepository {
    private static let defaultSession = URLSession(
        configuration: .ephemeral,
        delegate: RejectRedirectsDelegate(),
        delegateQueue: nil
    )

    private let session: any URLSessionProtocol

    init(session: any URLSessionProtocol = Self.defaultSession) {
        self.session = session
    }

    func fetchPDF(from url: URL) async throws(MercadoPagoCheckoutError) -> Data {
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await self.session.data(for: request)
        } catch let error as URLError {
            throw MercadoPagoCheckoutError(from: .networkError(error), location: .initialization)
        } catch {
            throw MercadoPagoCheckoutError(from: .requestFailed(error), location: .initialization)
        }

        guard let response = response as? HTTPURLResponse else { throw Self.receiptError("invalid_response") }
        if (300 ... 399).contains(response.statusCode) { throw Self.receiptError("redirect") }
        guard (200 ... 299).contains(response.statusCode) else { throw Self.receiptError("invalid_response") }
        guard data.starts(with: ReceiptPDFRenderer.pdfSignature) else { throw Self.receiptError("unsupported_content") }
        guard data.count <= ReceiptPDFRenderer.maximumPDFBytes else { throw Self.receiptError("file_too_large") }
        return data
    }

    /// Receipt failures surface as `MercadoPagoCheckoutError`, with the cause in `errorUserInfo["receipt_reason"]`.
    private static func receiptError(_ reason: String) -> MercadoPagoCheckoutError {
        MercadoPagoCheckoutError(
            code: .serviceError,
            localizedDescription: "Status Screen receipt is unavailable",
            userInfo: ["receipt_reason": reason],
            location: .initialization
        )
    }
}

private final class RejectRedirectsDelegate: NSObject, URLSessionTaskDelegate, Sendable {
    func urlSession(
        _: URLSession,
        task _: URLSessionTask,
        willPerformHTTPRedirection _: HTTPURLResponse,
        newRequest _: URLRequest,
        completionHandler: @escaping @Sendable (URLRequest?) -> Void
    ) {
        completionHandler(nil)
    }
}
