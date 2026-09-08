import Foundation
import MPCore

extension CoreMethods {
    static func nativeErrorInput(from error: any Error) -> NativeErrorInput {
        if error is CancellationError {
            return .init(type: .requestCancellation, code: .cancelled)
        }
        if let urlError = error as? URLError {
            return nativeErrorInput(from: urlError)
        }
        if let coreError = error as? CoreMethodsError {
            switch coreError {
            case .binIsEmpty, .securityCodeInvalid, .cardNumberInvalid, .expirationDateInvalid:
                return .init(type: .validation)
            case .errorGettingEphemeralKey:
                return .init(type: .unknown, code: .unknownError)
            }
        }
        guard let apiError = error as? APIClientError else {
            return .init(type: .unknown, code: .exception)
        }
        switch apiError {
        case .invalidURL, .urlRequestIsEmpty:
            return .init(type: .request, code: .invalidURL)
        case .invalidResponse:
            return .init(type: .request, responseState: .emptyBody)
        case .decodingFailed:
            return .init(type: .request, responseState: .decodeFailure)
        case let .requestFailed(underlying), let .networkError(underlying):
            return nativeErrorInput(from: underlying)
        case let .notExpectedHttpResponseCode(status), let .statusCode(status):
            return .init(type: .service, httpStatus: status)
        case .apiError:
            return .init(type: .service)
        }
    }

    private static func nativeErrorInput(from error: URLError) -> NativeErrorInput {
        switch error.code {
        case .cancelled:
            return .init(type: .requestCancellation, code: .cancelled)
        case .timedOut:
            return .init(type: .request, code: .timeout)
        case .notConnectedToInternet:
            return .init(type: .request, code: .offline)
        case .dnsLookupFailed, .cannotFindHost:
            return .init(type: .request, code: .dnsFailure)
        case .networkConnectionLost, .cannotConnectToHost:
            return .init(type: .request, code: .connectionLost)
        default:
            return .init(type: .unknown, code: .exception)
        }
    }
}
