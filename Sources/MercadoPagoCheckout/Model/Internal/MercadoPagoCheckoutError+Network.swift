//
//  MercadoPagoCheckoutError+Network.swift
//  MercadoPagoSDK
//
import Foundation
import MPCore

extension MercadoPagoCheckoutError {
    private static func decodingErrorDescription(from error: Error) -> String {
        guard let decodingError = error as? DecodingError else {
            return error.localizedDescription
        }
        switch decodingError {
        case let .keyNotFound(key, context):
            let path = (context.codingPath + [key]).map(\.stringValue).joined(separator: ".")
            return "Decoding failed: missing key '\(path)'."
        case let .typeMismatch(type, context):
            let path = context.codingPath.map(\.stringValue).joined(separator: ".")
            return "Decoding failed: type mismatch at '\(path)' — expected \(type)."
        case let .valueNotFound(type, context):
            let path = context.codingPath.map(\.stringValue).joined(separator: ".")
            return "Decoding failed: null value at '\(path)' — expected \(type)."
        case let .dataCorrupted(context):
            let path = context.codingPath.map(\.stringValue).joined(separator: ".")
            return "Decoding failed: corrupted data at '\(path)' — \(context.debugDescription)."
        @unknown default:
            return error.localizedDescription
        }
    }

    private static func decodingUserInfo(from error: Error) -> [String: Any] {
        guard let decodingError = error as? DecodingError else { return [:] }
        let context: DecodingError.Context?
        var failedKey: String?
        switch decodingError {
        case let .keyNotFound(key, ctx):
            context = ctx
            failedKey = key.stringValue
        case let .typeMismatch(_, ctx):
            context = ctx
        case let .valueNotFound(_, ctx):
            context = ctx
        case let .dataCorrupted(ctx):
            context = ctx
        @unknown default:
            context = nil
        }
        guard let context else { return [:] }
        var path = context.codingPath.map(\.stringValue).joined(separator: ".")
        if let key = failedKey {
            path = path.isEmpty ? key : "\(path).\(key)"
        }
        var info: [String: Any] = ["decoding_path": path]
        if let key = failedKey { info["decoding_failed_key"] = key }
        return info
    }

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
                userInfo: ["error_code": error.code, "message": error.message],
                location: location,
                serviceError: error
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
                localizedDescription: Self.decodingErrorDescription(from: error),
                userInfo: Self.decodingUserInfo(from: error),
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
