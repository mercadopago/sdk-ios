//
//  NetworkServiceTests.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 29/01/25.
//

import CommonTests
@testable import MPCore
import XCTest

private extension NetworkServiceTests {
    typealias SUT = (
        sut: NetworkService,
        session: MockURLSession
    )

    func makeSUT(file _: StaticString = #filePath, line _: UInt = #line) -> SUT {
        let session = MockURLSession()
        let sut = NetworkService(session: session)

        return (sut, session)
    }

    private func makeSuccessResponse(url: URL = URL(string: "http://example.com")!) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    private func makeErrorResponse(statusCode: Int, url: URL = URL(string: "http://example.com")!) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

class NetworkServiceTests: XCTestCase {
    func test_request_whenCalledWithRightResponse_shouldReceivedSucess() async throws {
        let (sut, session) = self.makeSUT()
        let endpoint = EndpointMock()
        let mockData = Data("""
        {
            "success": true,
        }
        """.utf8)
        let mockResponse = HTTPURLResponse(url: URL(string: "http://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        await session.mock.setData(mockData)
        await session.mock.setResponse(mockResponse)

        do {
            let result: MockResponse = try await sut.request(endpoint)
            XCTAssertTrue(result == MockResponse(sucess: true))
        } catch {
            print(error)
        }
    }

    func test_request_whenResponseIsNotHTTP_shouldThrowInvalidResponse() async {
        // Given
        let (sut, session) = self.makeSUT()
        let endpoint = EndpointMock()
        let mockData = Data()
        let invalidResponse = URLResponse()

        // When
        await session.mock.setData(mockData)
        await session.mock.setResponse(invalidResponse)

        // Then
        do {
            let _: MockResponse = try await sut.request(endpoint)
            XCTFail("Expected error but got success")
        } catch let error as APIClientError {
            XCTAssertEqual(String(describing: error), String(describing: APIClientError.invalidResponse(mockData)))
        } catch {
            XCTFail("Expected APIClientError but got \(error)")
        }
    }

    func test_request_whenStatusCodeIs4xx_shouldThrowAPIError() async {
        // Given
        let (sut, session) = self.makeSUT()
        let endpoint = EndpointMock()
        let mockData = Data("""
        {
            "code": "invalid_request",
            "message": "The request is invalid"
        }
        """.utf8)

        // When
        await session.mock.setData(mockData)
        await session.mock.setResponse(self.makeErrorResponse(statusCode: 400))

        // Then
        do {
            let _: MockResponse = try await sut.request(endpoint)
            XCTFail("Expected error but got success")
        } catch let error as APIClientError {
            if case let .apiError(apiError) = error {
                XCTAssertEqual(apiError.code, "invalid_request")
                XCTAssertEqual(apiError.message, "The request is invalid")
            } else {
                XCTFail("Expected APIError but got different APIClientError: \(error)")
            }
        } catch {
            XCTFail("Expected APIClientError but got \(error)")
        }
    }

    func test_request_whenStatusCodeIs5xx_shouldThrowStatusCode() async {
        // Given
        let (sut, session) = self.makeSUT()
        let endpoint = EndpointMock()
        let mockData = Data()

        // When
        await session.mock.setData(mockData)
        await session.mock.setResponse(self.makeErrorResponse(statusCode: 500))

        // Then
        do {
            let _: MockResponse = try await sut.request(endpoint)
            XCTFail("Expected error but got success")
        } catch let error as APIClientError {
            if case let .statusCode(code) = error {
                XCTAssertEqual(code, 500)
            } else {
                XCTFail("Expected status code error but got different APIClientError: \(error)")
            }
        } catch {
            XCTFail("Expected APIClientError but got \(error)")
        }
    }

    func test_request_whenNetworkErrorOccurs_shouldThrowNetworkError() async {
        // Given
        let (sut, session) = self.makeSUT()
        let endpoint = EndpointMock()
        let mockError = URLError(.notConnectedToInternet)

        // When
        await session.mock.setError(mockError)

        // Then
        do {
            let _: MockResponse = try await sut.request(endpoint)
            XCTFail("Expected error but got success")
        } catch let error as APIClientError {
            if case let .networkError(urlError as URLError) = error {
                XCTAssertEqual(urlError.code, .notConnectedToInternet)
            } else {
                XCTFail("Expected network error but got different APIClientError: \(error)")
            }
        } catch {
            XCTFail("Expected APIClientError but got \(error)")
        }
    }

    func test_request_whenDecodingFails_shouldThrowDecodingError() async {
        // Given
        let (sut, session) = self.makeSUT()
        let endpoint = EndpointMock()
        let invalidJSON = Data("""
        {
            "success": "not_a_boolean"
        }
        """.utf8)

        // When
        await session.mock.setData(invalidJSON)
        await session.mock.setResponse(self.makeSuccessResponse())

        // Then
        do {
            let _: MockResponse = try await sut.request(endpoint)
            XCTFail("Expected error but got success")
        } catch let error as APIClientError {
            if case let .decodingFailed(decodingError) = error {
                XCTAssertTrue(decodingError is DecodingError)
                if let typeMismatch = decodingError as? DecodingError {
                    XCTAssertNotNil(typeMismatch)
                }
            } else {
                XCTFail("Expected decoding error but got different APIClientError: \(error)")
            }
        } catch {
            XCTFail("Expected APIClientError but got \(error)")
        }
    }
}
