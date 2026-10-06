import Foundation

package protocol NativeErrorTransporting: Sendable {
    func send(_ report: NativeErrorReport) async throws
}

package final class NativeErrorTransport: NativeErrorTransporting {
    package static let endpoint = URL(string: "https://api.mercadopago.com/op-frontend-metrics/v2/error-metric")!

    private let endpoint: URL
    private let redirectDelegate: NativeErrorRedirectDelegate
    private let session: URLSession

    package init(configuration: URLSessionConfiguration? = nil) {
        endpoint = Self.endpoint
        redirectDelegate = NativeErrorRedirectDelegate()

        let configuration = configuration ?? .ephemeral
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        configuration.httpCookieStorage = nil
        configuration.urlCredentialStorage = nil
        configuration.httpAdditionalHeaders = nil
        configuration.httpShouldSetCookies = false
        configuration.httpCookieAcceptPolicy = .never
        configuration.waitsForConnectivity = false
        configuration.httpMaximumConnectionsPerHost = 1
        configuration.timeoutIntervalForRequest = 2
        configuration.timeoutIntervalForResource = 3

        session = URLSession(
            configuration: configuration,
            delegate: redirectDelegate,
            delegateQueue: nil
        )
    }

    package func send(_ report: NativeErrorReport) async throws {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(report)
        request.timeoutInterval = 2

        let response = try await perform(request)
        guard (response as? HTTPURLResponse)?.statusCode == 202 else {
            throw URLError(.badServerResponse)
        }
    }

    private func perform(_ request: URLRequest) async throws -> URLResponse {
        try await withCheckedThrowingContinuation { continuation in
            session.dataTask(with: request) { _, response, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let response {
                    continuation.resume(returning: response)
                } else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                }
            }.resume()
        }
    }

    deinit {
        session.invalidateAndCancel()
    }
}

private final class NativeErrorRedirectDelegate: NSObject, URLSessionTaskDelegate, @unchecked Sendable {
    func urlSession(
        _: URLSession,
        task _: URLSessionTask,
        willPerformHTTPRedirection _: HTTPURLResponse,
        newRequest _: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        completionHandler(nil)
    }
}
