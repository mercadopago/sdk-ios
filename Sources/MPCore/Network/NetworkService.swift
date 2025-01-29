import Foundation

package final class NetworkService: NetworkServiceProtocol {
    // MARK: - Properties

    private let session: URLSession

    // MARK: - Initialization

    init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }

    // MARK: - Methods

    package func request<T: Decodable & Sendable>(
        _ endpoint: any RequestEndpoint,
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

private extension NetworkService {
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
                if let apiError = decodeAPIError(from: data) {
                    throw APIClientError.apiError(apiError)
                } else {
                    throw APIClientError.statusCode(httpResponse.statusCode)
                }
            }

            return data
        } catch {
            if let urlError = error as? URLError {
                throw APIClientError.networkError(urlError)
            } else {
                throw APIClientError.requestFailed(error)
            }
        }
    }

    private func decodeAPIError(from data: Data) -> APIErrorResponse? {
        return try? JSONDecoder().decode(APIErrorResponse.self, from: data)
    }
}

// MARK: - Log extension -

private extension NetworkService {
    private func log(_ string: String) {
        #if DEBUG
            print(string)
        #endif
    }
}
