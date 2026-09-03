import Foundation

package protocol NativeErrorTransporting: Sendable {
    func send(_ report: NativeErrorReport) async throws -> Bool
}

package final class NativeErrorTransport: NativeErrorTransporting, @unchecked Sendable {
    package static let endpoint = URL(string: "https://api.mercadopago.com/op-frontend-metrics/v2/error-metric")!

    private let endpoint: URL
    private let encoder: JSONEncoder
    private let redirectDelegate: NativeErrorRedirectDelegate
    private let session: URLSession

    package init(
        endpoint: URL = NativeErrorTransport.endpoint,
        configuration: URLSessionConfiguration? = nil,
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.endpoint = endpoint
        self.encoder = encoder
        self.redirectDelegate = NativeErrorRedirectDelegate()

        let configuration = configuration ?? .ephemeral
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        configuration.httpCookieStorage = nil
        configuration.urlCredentialStorage = nil
        configuration.httpShouldSetCookies = false
        configuration.httpCookieAcceptPolicy = .never
        configuration.waitsForConnectivity = false
        configuration.httpMaximumConnectionsPerHost = 1
        configuration.timeoutIntervalForRequest = 2
        configuration.timeoutIntervalForResource = 3

        self.session = URLSession(
            configuration: configuration,
            delegate: redirectDelegate,
            delegateQueue: nil
        )
    }

    package func send(_ report: NativeErrorReport) async throws -> Bool {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(report)
        request.timeoutInterval = 2

        let response = try await perform(request)
        return (response as? HTTPURLResponse)?.statusCode == 202
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
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        completionHandler(nil)
    }

}
