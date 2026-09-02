import XCTest
@testable import MPCore

final class NativeErrorTransportTests: XCTestCase {
    override func tearDown() {
        NativeErrorURLProtocol.handler = nil
        super.tearDown()
    }

    func testSendsExactlyOneCredentialFreePOSTAndAcceptsOnly202() async throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [NativeErrorURLProtocol.self]
        configuration.httpAdditionalHeaders = [
            "Authorization": "Bearer must-not-escape",
            "Cookie": "session=must-not-escape",
            "X-Public-Key": "must-not-escape"
        ]
        configuration.httpCookieStorage = .shared
        configuration.urlCredentialStorage = .shared
        configuration.urlCache = .shared
        let transport = NativeErrorTransport(configuration: configuration)
        let lock = NSLock()
        var attempts = 0
        NativeErrorURLProtocol.handler = { request in
            lock.lock()
            attempts += 1
            lock.unlock()
            XCTAssertEqual(request.url, NativeErrorTransport.endpoint)
            XCTAssertEqual(request.url?.scheme, "https")
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
            XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
            XCTAssertNil(request.value(forHTTPHeaderField: "X-Public-Key"))
            XCTAssertNil(request.value(forHTTPHeaderField: "Cookie"))
            XCTAssertNil(request.url?.query)
            return (HTTPURLResponse(url: request.url!, statusCode: 202, httpVersion: nil, headerFields: nil)!, Data())
        }

        let accepted = try await transport.send(report())
        XCTAssertTrue(accepted)
        XCTAssertEqual(attempts, 1)
    }

    func testNon202IsNotAcceptedAndIsNotRetried() async throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [NativeErrorURLProtocol.self]
        let transport = NativeErrorTransport(configuration: configuration)
        var attempts = 0
        NativeErrorURLProtocol.handler = { request in
            attempts += 1
            return (HTTPURLResponse(url: request.url!, statusCode: 503, httpVersion: nil, headerFields: nil)!, Data())
        }

        let accepted = try await transport.send(report())
        XCTAssertFalse(accepted)
        XCTAssertEqual(attempts, 1)
    }

    private func report() -> NativeErrorReport {
        NativeErrorReport(pending: .init(
            eventID: UUID(),
            occurredAt: Date(),
            environment: .init(sdkVersion: "1.0.0", siteID: "MLB", osVersion: "18.6"),
            error: .init(operation: .installments, code: .requestTimeout)
        ))
    }
}

private final class NativeErrorURLProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        do {
            let (response, data) = try Self.handler!(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
