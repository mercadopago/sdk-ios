//
//  MockURLSession.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 30/01/25.
//
import Foundation
@testable import MPCore

package final class MockURLSession: URLSessionProtocol {
    package actor Mock {
        var data: Data?
        var response: URLResponse?
        var error: Error?

        package func setData(_ data: Data) {
            self.data = data
        }

        package func setResponse(_ response: URLResponse) {
            self.response = response
        }

        package func setError(_ error: Error) {
            self.error = error
        }
    }

    package init() {}

    package let mock = Mock()

    package func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = await mock.error {
            throw error
        }

        if let data = await mock.data, let response = await mock.response {
            return (data, response)
        }

        return (Data(), HTTPURLResponse(url: request.url ?? URL(string: "http://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
    }
}
