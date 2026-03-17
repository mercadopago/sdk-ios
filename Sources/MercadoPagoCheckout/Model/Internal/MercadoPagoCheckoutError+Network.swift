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
                    localizedDescription: "No internet connection.",
                    location: location
                )
            case .timedOut:
                self.init(
                    code: .networkTimeout,
                    localizedDescription: "The request timed out.",
                    location: location
                )
            default:
                self.init(
                    code: .unknown,
                    localizedDescription: underlying.localizedDescription,
                    location: location
                )
            }
        case let .apiError(error):
            self.init(
                code: .serviceError,
                localizedDescription: "An error occurred. Check the error_code for more details.",
                userInfo: ["error_code": error.code],
                location: location
            )
        case let .statusCode(status):
            self.init(
                code: .serviceError,
                localizedDescription: "An error occurred. Check the status_code for more details.",
                userInfo: ["status_code": status],
                location: location
            )
        case .invalidURL:
            self.init(
                code: .unknown,
                localizedDescription: "Invalid URL.",
                location: location
            )
        case let .invalidResponse(data):
            self.init(
                code: .unknown,
                localizedDescription: "invalid_response",
                userInfo: ["data": data],
                location: location
            )
        case let .decodingFailed(error):
            self.init(
                code: .unknown,
                localizedDescription: error.localizedDescription,
                location: location
            )
        case let .requestFailed(error):
            self.init(
                code: .unknown,
                localizedDescription: error.localizedDescription,
                location: location
            )
        case let .notExpectedHttpResponseCode(code: status):
            self.init(
                code: .unknown,
                localizedDescription: "Not expected HTTP response code: \(status)",
                location: location
            )
        case .urlRequestIsEmpty:
            self.init(
                code: .unknown,
                localizedDescription: "URL request is empty",
                location: location
            )
        }
    }
}
