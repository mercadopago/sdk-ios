//
//  NetworkServiceTests.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 29/01/25.
//

@testable import MPCore
import XCTest

// MARK: - Test Doubles

class MockURLProtocol: URLProtocol {
    nonisolated(unsafe) static var mockResponses: [URL: (data: Data?, response: URLResponse?, error: Error?)] = [:]

    static func setMockResponse(for url: URL, data: Data?, response: URLResponse?, error: Error?) {
        self.mockResponses[url] = (data, response, error)
    }

    static func reset() {
        self.mockResponses = [:]
    }

    override class func canInit(with _: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let url = request.url,
              let mockResponse = MockURLProtocol.mockResponses[url] else {
            client?.urlProtocol(self, didFailWithError: APIClientError.invalidURL)
            return
        }

        if let error = mockResponse.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        if let response = mockResponse.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let data = mockResponse.data {
            client?.urlProtocol(self, didLoad: data)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

// MARK: - SUT Factory

private extension NetworkServiceTests {
    typealias SUT = NetworkService

    func makeSUT(
        file _: StaticString = #filePath,
        line _: UInt = #line
    ) -> SUT {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        return NetworkService(session: session)
    }

    func makeURL() -> URL {
        return URL(string: "https://api.test.com/test")!
    }

    func makeHTTPResponse(for url: URL, statusCode: Int = 200) -> HTTPURLResponse {
        return HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }
}

private struct ResponseMock: Codable, Sendable {
    let id: String
    let value: Int
}

// MARK: - Tests

final class NetworkServiceTests: XCTestCase {
    override func setUp() {
        super.setUp()
        MockURLProtocol.reset()
    }

    func test_request_withValidEndpoint_shouldReturnDecodedResponse() throws {
        // Given
        let sut = self.makeSUT()
        let endpoint = EndpointMock()
        let url = self.makeURL()
        let expectedResponse = ResponseMock(id: "123", value: 456)
        let responseData = try JSONEncoder().encode(expectedResponse)

        MockURLProtocol.setMockResponse(
            for: url,
            data: responseData,
            response: self.makeHTTPResponse(for: url),
            error: nil
        )

        // When
        Task {
            let response: ResponseMock = try await sut.request(endpoint)

            // Then
            XCTAssertEqual(response.id, expectedResponse.id)
            XCTAssertEqual(response.value, expectedResponse.value)
        }
    }

    func test_request_withNetworkError_shouldThrowNetworkError() {
        // Given
        let sut = self.makeSUT()
        let endpoint = EndpointMock()
        let url = self.makeURL()
        let expectedError = URLError(.notConnectedToInternet)

        MockURLProtocol.setMockResponse(
            for: url,
            data: nil,
            response: nil,
            error: expectedError
        )

        // When/Then
        Task {
            do {
                let _: ResponseMock = try await sut.request(endpoint)
                XCTFail("Expected error to be thrown")
            } catch let error as APIClientError {
                if case let .networkError(underlyingError) = error {
                    XCTAssertEqual((underlyingError as? URLError)?.code, expectedError.code)
                } else {
                    XCTFail("Expected networkError, got \(error)")
                }
            } catch {
                XCTFail("Expected ServiceError, got \(error)")
            }
        }
    }

    func test_request_withNon200StatusCode_shouldThrowStatusCodeError() {
        // Given
        let sut = self.makeSUT()
        let endpoint = EndpointMock()
        let url = self.makeURL()

        MockURLProtocol.setMockResponse(
            for: url,
            data: Data(),
            response: self.makeHTTPResponse(for: url, statusCode: 404),
            error: nil
        )

        // When/Then
        Task {
            do {
                let _: ResponseMock = try await sut.request(endpoint)
                XCTFail("Expected error to be thrown")
            } catch let error as APIClientError {
                if case let .statusCode(code) = error {
                    XCTAssertEqual(code, 404)
                } else {
                    XCTFail("Expected statusCode error, got \(error)")
                }
            } catch {
                XCTFail("Expected ServiceError, got \(error)")
            }
        }
    }

    func test_request_withInvalidResponseData_shouldThrowDecodingError() async {
        // Given
        let sut = self.makeSUT()
        let endpoint = EndpointMock()
        let url = self.makeURL()
        let invalidData = "invalid json".data(using: .utf8)!

        MockURLProtocol.setMockResponse(
            for: url,
            data: invalidData,
            response: self.makeHTTPResponse(for: url),
            error: nil
        )

        // When/Then
        Task {
            do {
                let _: ResponseMock = try await sut.request(endpoint)
                XCTFail("Expected error to be thrown")
            } catch let error as APIClientError {
                if case .decodingFailed = error {
                    // Success
                } else {
                    XCTFail("Expected decodingFailed error, got \(error)")
                }
            } catch {
                XCTFail("Expected ServiceError, got \(error)")
            }
        }
    }
}
