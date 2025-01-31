import Foundation

package protocol HasNetworkService: Sendable {
    var networkService: NetworkServiceProtocol { get }
}

/// A protocol defining the methods for making API requests.
package protocol NetworkServiceProtocol: Sendable {
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
        _ endpoint: any RequestEndpoint,
        decoder: JSONDecoder
    ) async throws -> T
}

package extension NetworkServiceProtocol {
    @discardableResult
    func request<T: Codable & Sendable>(_ endpoint: RequestEndpoint) async throws -> T {
        try await self.request(endpoint, decoder: JSONDecoder())
    }
}
