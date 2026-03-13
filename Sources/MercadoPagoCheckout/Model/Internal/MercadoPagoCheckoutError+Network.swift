//
//  MercadoPagoCheckoutError+Network.swift
//  MercadoPagoSDK
//
import Foundation
import MPCore

extension MercadoPagoCheckoutError {
    init(from error: APIClientError, location: LocationDescription) {
        switch error {
        case let .networkError(underlying):
            let urlError = underlying as? URLError
            switch urlError?.code {
            case .notConnectedToInternet,
                 .cannotFindHost,
                 .cannotConnectToHost,
                 .dnsLookupFailed,
                 .internationalRoamingOff,
                 .dataNotAllowed,
                 .callIsActive,
                 .networkConnectionLost:
                self.init(
                    code: .networkConnectionFailed,
                    _localizedDescription: "No internet connection.",
                    location: location
                )
            case .timedOut:
                self.init(
                    code: .networkTimeout,
                    _localizedDescription: "The request timed out.",
                    location: location
                )
            default:
                self.init(
                    code: .unknown,
                    _localizedDescription: underlying.localizedDescription,
                    location: location
                )
            }
        case let .apiError(error):
            self.init(
                code: .serviceError,
                _localizedDescription: "An error occurred. Check the error_code for more details.",
                _userInfo: ["error_code": error.code],
                location: location
            )
        case let .statusCode(status):
            self.init(
                code: .serviceError,
                _localizedDescription: "An error occurred. Check the status_code for more details.",
                _userInfo: ["status_code": status],
                location: location
            )
        case .invalidURL:
            self.init(
                code: .unknown,
                _localizedDescription: "Invalid URL.",
                location: location
            )
        case let .invalidResponse(data):
            self.init(
                code: .unknown,
                _localizedDescription: "invalid_response",
                _userInfo: ["data": data],
                location: location
            )
        case let .decodingFailed(error):
            self.init(
                code: .unknown,
                _localizedDescription: error.localizedDescription,
                location: location
            )
        case let .requestFailed(error):
            self.init(
                code: .unknown,
                _localizedDescription: error.localizedDescription,
                location: location
            )
        case let .notExpectedHttpResponseCode(code: status):
            self.init(
                code: .unknown,
                _localizedDescription: "Not expected HTTP response code: \(status)",
                location: location
            )
        case .urlRequestIsEmpty:
            self.init(
                code: .unknown,
                _localizedDescription: "URL request is empty",
                location: location
            )
        }
    }
}
