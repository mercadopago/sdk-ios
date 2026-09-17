import Foundation

package extension NativeErrorInput {
    init(urlError: URLError) {
        switch urlError.code {
        case .cancelled:
            self.init(type: .requestCancellation, code: .cancelled)
        case .timedOut:
            self.init(type: .request, code: .timeout)
        case .notConnectedToInternet:
            self.init(type: .request, code: .offline)
        case .dnsLookupFailed, .cannotFindHost:
            self.init(type: .request, code: .dnsFailure)
        case .networkConnectionLost, .cannotConnectToHost:
            self.init(type: .request, code: .connectionLost)
        default:
            self.init(type: .unknown, code: .exception)
        }
    }
}

package extension APIClientError {
    var nativeErrorInput: NativeErrorInput {
        switch self {
        case .invalidURL, .urlRequestIsEmpty:
            return .init(type: .request, code: .invalidURL)
        case let .invalidResponse(data):
            if data.isEmpty {
                return .init(type: .request, responseState: .emptyBody)
            }
            return .init(type: .unknown, code: .exception)
        case .decodingFailed:
            return .init(type: .request, responseState: .decodeFailure)
        case let .requestFailed(error), let .networkError(error):
            if error is CancellationError {
                return .init(type: .requestCancellation, code: .cancelled)
            }
            guard let urlError = error as? URLError else {
                return .init(type: .unknown, code: .exception)
            }
            return .init(urlError: urlError)
        case let .notExpectedHttpResponseCode(status), let .statusCode(status):
            return .init(type: .service, httpStatus: status)
        case .apiError:
            return .init(type: .service)
        }
    }
}
