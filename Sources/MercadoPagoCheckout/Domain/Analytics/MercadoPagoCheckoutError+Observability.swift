import MPCore

extension MercadoPagoCheckoutError {
    static func classifiedUserCancellation(operation: NativeErrorOperation) -> ClassifiedNativeError {
        ClassifiedNativeError(
            operation: operation,
            code: .userCancelled,
            diagnosticCode: .cancelled
        )
    }

    func classifiedNativeError(
        operation: NativeErrorOperation,
        explicitCancellation: Bool = false
    ) -> ClassifiedNativeError {
        if explicitCancellation {
            return Self.classifiedUserCancellation(operation: operation)
        }
        if code == .networkConnectionFailed {
            return makeClassification(operation: operation, code: .connectionUnavailable, diagnostic: .offline)
        }
        if code == .networkTimeout {
            return makeClassification(operation: operation, code: .requestTimeout, diagnostic: .timeout)
        }

        let apiCode = serviceError?.errorCode.flatMap(CheckoutAPIErrorCode.init(rawValue:))
        if code == .integrationError || apiCode.map(CheckoutAPIErrorCode.integration.contains) == true {
            return makeClassification(operation: operation, code: .sdkConfigurationInvalid)
        }
        if Self.isValidationCode(apiCode) {
            return makeClassification(operation: operation, code: .inputValidationFailed, diagnostic: .validation)
        }

        let statusCode = (errorUserInfo["status_code"] as? Int)
            .flatMap { (100...599).contains($0) ? $0 : nil }
        if code == .serviceError {
            switch statusCode {
            case 408, 504:
                return makeClassification(operation: operation, code: .requestTimeout, statusCode: statusCode, diagnostic: .timeout)
            case 401:
                return makeClassification(operation: operation, code: .sdkConfigurationInvalid, statusCode: statusCode, diagnostic: .httpUnauthorized)
            case 403:
                return makeClassification(operation: operation, code: .sdkConfigurationInvalid, statusCode: statusCode, diagnostic: .httpForbidden)
            default:
                return makeClassification(operation: operation, code: .upstreamRejected, statusCode: statusCode)
            }
        }

        if errorDescription == "invalid_response" {
            return makeClassification(operation: operation, code: .responseContractInvalid, diagnostic: .emptyBody)
        }
        if errorDescription?.hasPrefix("Decoding failed:") == true {
            return makeClassification(operation: operation, code: .responseContractInvalid, diagnostic: .decodeFailure)
        }
        return makeClassification(operation: operation, code: .operationFailed)
    }

    private static func isValidationCode(_ code: CheckoutAPIErrorCode?) -> Bool {
        switch code {
        case .emptyPaymentMethods?, .paymentMethodUnavailable?, .installmentsUnavailable?: true
        default: false
        }
    }

    private func makeClassification(
        operation: NativeErrorOperation,
        code: NativeErrorCode,
        statusCode: Int? = nil,
        diagnostic: NativeErrorDiagnosticCode? = nil
    ) -> ClassifiedNativeError {
        let serviceTarget: NativeErrorServiceTarget? = switch operation {
        case .cardFormInitialization: .checkoutInitialization
        case .orderSubmission: .orders
        default: nil
        }
        return ClassifiedNativeError(
            operation: operation,
            code: code,
            statusCode: statusCode,
            serviceTarget: serviceTarget,
            diagnosticCode: diagnostic
        )
    }
}
