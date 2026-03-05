import Foundation

protocol URLSessionProtocol: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

package final class NetworkService: NetworkServiceProtocol {
    // MARK: - Properties

    private let session: URLSessionProtocol
    // MARK: - Initialization

    init(session: URLSessionProtocol = URLSession.shared) {
        let urlSessionConfiguration: URLSessionConfiguration = .default
        if let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let diskCacheURL = cachesURL.appendingPathComponent("MPCache")

            // Memory 10 MB e disk 100MB
            let cache = URLCache(
                memoryCapacity: 10 * 1024 * 1024,
                diskCapacity: 100 * 1024 * 1024,
                directory: diskCacheURL
            )
            urlSessionConfiguration.urlCache = cache
        }
        
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
        let session: URLSessionProtocol = self.session

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIClientError.invalidResponse(data)
            }

            guard (200 ... 299).contains(httpResponse.statusCode) else {
                if let apiError = decodeAPIError(from: data) {
                    throw APIClientError.apiError(apiError)
                } else {
                    throw APIClientError.statusCode(httpResponse.statusCode)
                }
            }
            return data
        } catch let error as URLError {
            throw APIClientError.networkError(error)
        } catch let error as APIClientError {
            throw error
        } catch {
            throw APIClientError.requestFailed(error)
        }
    }

    private func decodeAPIError(from data: Data) -> APIErrorResponse? {
        return try? JSONDecoder().decode(APIErrorResponse.self, from: data)
    }
}
