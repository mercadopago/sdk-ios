//
//  MockURLSession.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 30/01/25.
//
import Foundation
@testable import MPCore

final class MockURLSession: URLSessionProtocol {
    actor Mock {
        var data: Data?
        var response: URLResponse?
        var error: Error?

        func setData(_ data: Data) {
            self.data = data
        }

        func setResponse(_ response: URLResponse) {
            self.response = response
        }

        func setError(_ error: Error) {
            self.error = error
        }
    }

    let mock = Mock()

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = await mock.error {
            throw error
        }

        if let data = await mock.data, let response = await mock.response {
            return (data, response)
        }

        return (Data(), HTTPURLResponse(url: request.url ?? URL(string: "http://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
    }
}
