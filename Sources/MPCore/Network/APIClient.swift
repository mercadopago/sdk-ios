package import Foundation

package final class APIClient: APIClientProtocol {
    // MARK: - Properties

    private let session: URLSession

    // MARK: - Initialization

    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - Methods

    package func request<T: Decodable & Sendable>(
        _ endpoint: any APIEndpointProtocol,
        decoder: JSONDecoder
    ) async throws -> T {
        guard let request = endpoint.urlRequest else {
            throw APIClientError.invalidURL
        }

        let data = try await performRequest(request)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIClientError.decodingFailed(error)
        }
    }
}

// MARK: - Private extensions -

private extension APIClient {
    @discardableResult
    private func performRequest(
        _ request: URLRequest
    ) async throws -> Data {
        // Configure session
        let session: URLSession = self.session

        do {
            // Perform the network request
            let (data, response) = try await session.data(for: request)

            // Ensure the response is an HTTP URL response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIClientError.invalidResponse(data)
            }

            log("Received HTTP response: \(httpResponse)")

            guard (200 ... 299).contains(httpResponse.statusCode) else {
                throw APIClientError.statusCode(httpResponse.statusCode)
            }

            return data
        } catch {
            // Handle specific errors
            if let urlError = error as? URLError {
                throw APIClientError.networkError(urlError)
            } else {
                throw APIClientError.requestFailed(error)
            }
        }
    }
}

// MARK: - Log extension -

private extension APIClient {
    private func log(_ string: String) {
        #if DEBUG
            print(string)
        #endif
    }
}
