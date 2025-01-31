//
//  RequestEndpointTests.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 29/01/25.
//
@testable import MPCore
import XCTest

final class RequestEndpointTests: XCTestCase {
    func test_urlRequest_withValidParameters_shouldCreateCorrectRequest() {
        // Given
        let endpoint = EndpointMock()

        // When
        let request = endpoint.urlRequest

        // Then
        XCTAssertEqual(request?.httpMethod, "GET")
        XCTAssertTrue(request?.url?.absoluteString.contains("https://api.test.com/v1/test?public_key=") ?? false)
    }

    func test_urlRequest_withQueryParameters_shouldAddToURL() {
        // Given
        var endpoint = EndpointMock()
        endpoint.urlParams = ["key": "value"]

        // When
        let request = endpoint.urlRequest

        // Then
        XCTAssertTrue(request?.url?.absoluteString.contains("key=value") ?? false)
    }
}
