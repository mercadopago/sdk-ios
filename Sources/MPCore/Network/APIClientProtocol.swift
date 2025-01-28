import Foundation

package protocol HasAPIClient: Sendable {
    var networkService: APIClientProtocol { get }
}

/// A protocol defining the methods for making API requests.
package protocol APIClientProtocol: Sendable {
    /// Sends a request to the specified endpoint and decodes the response into a given type.
    ///
    /// - Parameters:
    ///   - endpoint: The endpoint to request.
    ///   - decoder: The `JSONDecoder` to use for decoding the response.
    /// - Returns: The decoded response of type `T`.
    /// - Throws: An error if the request fails or if decoding fails.
    /// - Note: The type `T` must conform to `Codable` and `Sendable`.
    ///
    func request<T: Codable & Sendable>(
        _ endpoint: any APIEndpointProtocol,
        decoder: JSONDecoder
    ) async throws -> T
}

package extension APIClientProtocol {
    @discardableResult
    func request<T: Codable & Sendable>(_ endpoint: any APIEndpointProtocol) async throws -> T {
        try await self.request(endpoint, decoder: JSONDecoder())
    }
}
