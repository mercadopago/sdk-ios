import Foundation
import MPCore

enum ObservedCheckoutErrorFactory {
    static func make(
        from error: any Error,
        location: MercadoPagoCheckoutError.LocationDescription,
        recognizeIntegrationError: Bool = false
    ) -> ObservedCheckoutError {
        if let observed = error as? ObservedCheckoutError {
            return observed
        }
        if let publicError = error as? MercadoPagoCheckoutError {
            return .init(publicError: publicError, input: input(from: publicError))
        }
        guard let apiError = error as? APIClientError else {
            let publicError = MercadoPagoCheckoutError(
                code: .unknown,
                localizedDescription: error.localizedDescription,
                location: location
            )
            return .init(publicError: publicError, input: .init(type: .unknown, code: .exception))
        }

        if recognizeIntegrationError,
           case let .apiError(response) = apiError,
           let errorCode = response.errorCode,
           CheckoutAPIErrorCode.isIntegrationError(errorCode)
        {
            let publicError = MercadoPagoCheckoutError(
                code: .integrationError,
                localizedDescription: response.message,
                userInfo: ["error_code": errorCode, "message": response.message],
                location: location
            )
            return .init(publicError: publicError, input: .init(type: .validation, code: .integration))
        }

        return .init(
            publicError: MercadoPagoCheckoutError(from: apiError, location: location),
            input: input(from: apiError)
        )
    }

    static func validation(_ error: MercadoPagoCheckoutError) -> ObservedCheckoutError {
        .init(publicError: error, input: .init(type: .validation))
    }

    private static func input(from error: APIClientError) -> NativeErrorInput {
        switch error {
        case let .apiError(response):
            let code = response.errorCode.flatMap(CheckoutAPIErrorCode.init(rawValue:))
            if code.map(CheckoutAPIErrorCode.integration.contains) == true {
                return .init(type: .validation, code: .integration)
            }
            if isValidation(code) {
                return .init(type: .validation)
            }
            return .init(type: .service)
        default:
            return error.nativeErrorInput
        }
    }

    private static func input(from error: MercadoPagoCheckoutError) -> NativeErrorInput {
        if error.code == .networkConnectionFailed {
            return .init(type: .request, code: .offline)
        }
        if error.code == .networkTimeout {
            return .init(type: .request, code: .timeout)
        }
        if error.code == .integrationError {
            return .init(type: .validation, code: .integration)
        }

        let apiCode = error.serviceError?.errorCode.flatMap(CheckoutAPIErrorCode.init(rawValue:))
        if apiCode.map(CheckoutAPIErrorCode.integration.contains) == true {
            return .init(type: .validation, code: .integration)
        }
        if isValidation(apiCode) {
            return .init(type: .validation)
        }
        let status = (error.errorUserInfo["status_code"] as? Int)
            .flatMap { (100 ... 599).contains($0) ? $0 : nil }
        if error.code == .serviceError {
            return .init(type: .service, httpStatus: status)
        }
        if error.errorDescription == "invalid_response" {
            if let data = error.errorUserInfo["data"] as? Data, data.isEmpty {
                return .init(type: .request, responseState: .emptyBody)
            }
            return .init(type: .unknown, code: .exception)
        }
        if error.errorDescription?.hasPrefix("Decoding failed:") == true {
            return .init(type: .request, responseState: .decodeFailure)
        }
        return .init(type: .unknown, code: .unknownError)
    }

    private static func isValidation(_ code: CheckoutAPIErrorCode?) -> Bool {
        switch code {
        case .emptyPaymentMethods?, .paymentMethodUnavailable?, .installmentsUnavailable?: true
        default: false
        }
    }
}
