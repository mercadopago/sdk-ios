import Foundation
import MPCore

extension CoreMethods {
    static func classifiedNativeError(
        from error: any Error,
        operation: NativeErrorOperation
    ) -> ClassifiedNativeError {
        let result = classify(error)
        return ClassifiedNativeError(
            operation: operation,
            code: result.code,
            statusCode: result.statusCode,
            serviceTarget: serviceTarget(for: operation),
            diagnosticCode: result.diagnosticCode
        )
    }

    private static func classify(
        _ error: any Error
    ) -> (code: NativeErrorCode, statusCode: Int?, diagnosticCode: NativeErrorDiagnosticCode?) {
        if error is CancellationError {
            return (.requestCancelled, nil, .cancelled)
        }
        if let urlError = error as? URLError {
            return classify(urlError)
        }
        if let coreError = error as? CoreMethodsError {
            switch coreError {
            case .binIsEmpty, .securityCodeInvalid, .cardNumberInvalid, .expirationDateInvalid:
                return (.inputValidationFailed, nil, .validation)
            case .errorGettingEphemeralKey:
                return (.operationFailed, nil, nil)
            }
        }
        guard let apiError = error as? APIClientError else {
            return (.operationFailed, nil, nil)
        }
        switch apiError {
        case .invalidURL, .urlRequestIsEmpty:
            return (.sdkConfigurationInvalid, nil, .invalidURL)
        case .invalidResponse:
            return (.responseContractInvalid, nil, .emptyBody)
        case .decodingFailed:
            return (.responseContractInvalid, nil, .decodeFailure)
        case let .requestFailed(underlying), let .networkError(underlying):
            return classify(underlying)
        case let .notExpectedHttpResponseCode(status), let .statusCode(status):
            return classify(statusCode: status)
        case .apiError:
            return (.upstreamRejected, nil, nil)
        }
    }

    private static func classify(
        _ error: URLError
    ) -> (code: NativeErrorCode, statusCode: Int?, diagnosticCode: NativeErrorDiagnosticCode?) {
        switch error.code {
        case .cancelled:
            return (.requestCancelled, nil, .cancelled)
        case .timedOut:
            return (.requestTimeout, nil, .timeout)
        case .notConnectedToInternet:
            return (.connectionUnavailable, nil, .offline)
        case .dnsLookupFailed, .cannotFindHost:
            return (.connectionUnavailable, nil, .dnsFailure)
        case .networkConnectionLost, .cannotConnectToHost:
            return (.connectionUnavailable, nil, .connectionLost)
        default:
            return (.operationFailed, nil, nil)
        }
    }

    private static func classify(
        statusCode: Int
    ) -> (code: NativeErrorCode, statusCode: Int?, diagnosticCode: NativeErrorDiagnosticCode?) {
        let safeStatus = (100...599).contains(statusCode) ? statusCode : nil
        switch statusCode {
        case 408, 504:
            return (.requestTimeout, safeStatus, .timeout)
        case 401:
            return (.sdkConfigurationInvalid, safeStatus, .httpUnauthorized)
        case 403:
            return (.sdkConfigurationInvalid, safeStatus, .httpForbidden)
        default:
            return (.upstreamRejected, safeStatus, nil)
        }
    }

    private static func serviceTarget(for operation: NativeErrorOperation) -> NativeErrorServiceTarget? {
        switch operation {
        case .identificationTypes: .identificationTypes
        case .installments: .installments
        case .paymentMethods: .paymentMethods
        case .issuers: .issuers
        case .cardTokenization: nil
        default: nil
        }
    }
}
