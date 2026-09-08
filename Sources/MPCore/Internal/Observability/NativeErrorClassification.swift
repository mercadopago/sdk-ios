import Foundation

package enum NativeErrorInputType: String, Codable, Sendable, CaseIterable {
    case request
    case service
    case validation
    case userCancellation = "user_cancellation"
    case requestCancellation = "request_cancellation"
    case unknown
}

package enum NativeErrorEvidenceCode: String, Codable, Sendable, CaseIterable {
    case cancelled
    case configuration
    case integration
    case invalidURL = "invalid_url"
    case offline
    case dnsFailure = "dns_failure"
    case connectionLost = "connection_lost"
    case timeout
    case emptyBody = "empty_body"
    case exception
    case unknownError = "unknown_error"
    case httpUnauthorized = "http_unauthorized"
    case httpForbidden = "http_forbidden"
}

package enum NativeErrorResponseState: String, Codable, Sendable, CaseIterable {
    case emptyBody = "empty_body"
    case decodeFailure = "decode_failure"
}

package struct NativeErrorInput: Sendable, Equatable {
    package let type: NativeErrorInputType
    package let code: NativeErrorEvidenceCode?
    package let httpStatus: Int?
    package let responseState: NativeErrorResponseState?
    package let requestCorrelationID: String?

    package init(
        type: NativeErrorInputType,
        code: NativeErrorEvidenceCode? = nil,
        httpStatus: Int? = nil,
        responseState: NativeErrorResponseState? = nil,
        requestCorrelationID: String? = nil
    ) {
        self.type = type
        self.code = code
        self.httpStatus = httpStatus.flatMap { (100...599).contains($0) ? $0 : nil }
        self.responseState = responseState
        self.requestCorrelationID = requestCorrelationID.flatMap(Self.safeCorrelationID)
    }

    private static func safeCorrelationID(_ value: String) -> String? {
        let allowed = CharacterSet(
            charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789._:-"
        )
        guard (1...128).contains(value.utf8.count),
              value.unicodeScalars.allSatisfy(allowed.contains) else {
            return nil
        }
        return value
    }
}

package enum NativeErrorClassifier {
    package static func classify(
        operation: NativeErrorOperation,
        input: NativeErrorInput
    ) -> ClassifiedNativeError {
        let code = outputCode(for: input)
        return ClassifiedNativeError(
            operation: operation,
            code: code,
            statusCode: input.httpStatus,
            requestCorrelationID: input.requestCorrelationID,
            serviceTarget: serviceTarget(for: operation),
            diagnosticCode: diagnosticCode(for: input, outputCode: code)
        )
    }

    private static func outputCode(for input: NativeErrorInput) -> NativeErrorCode {
        if input.type == .userCancellation { return .userCancelled }
        if input.type == .requestCancellation || input.code == .cancelled { return .requestCancelled }
        if isConfiguration(input) { return .sdkConfigurationInvalid }
        if input.type == .validation { return .inputValidationFailed }
        if input.responseState != nil || input.code == .emptyBody { return .responseContractInvalid }
        if isConnection(input.code) { return .connectionUnavailable }
        if input.code == .timeout || input.httpStatus == 408 || input.httpStatus == 504 {
            return .requestTimeout
        }
        if input.type == .request || input.type == .service { return .upstreamRejected }
        return .operationFailed
    }

    private static func isConfiguration(_ input: NativeErrorInput) -> Bool {
        switch input.code {
        case .configuration?, .integration?, .invalidURL?, .httpUnauthorized?, .httpForbidden?:
            return true
        default:
            return input.httpStatus == 401 || input.httpStatus == 403
        }
    }

    private static func isConnection(_ code: NativeErrorEvidenceCode?) -> Bool {
        switch code {
        case .offline?, .dnsFailure?, .connectionLost?: true
        default: false
        }
    }

    private static func diagnosticCode(
        for input: NativeErrorInput,
        outputCode: NativeErrorCode
    ) -> NativeErrorDiagnosticCode? {
        if outputCode == .userCancelled || outputCode == .requestCancelled { return .cancelled }
        if input.code == .invalidURL { return .invalidURL }
        if input.code == .httpUnauthorized || input.httpStatus == 401 { return .httpUnauthorized }
        if input.code == .httpForbidden || input.httpStatus == 403 { return .httpForbidden }
        if outputCode == .inputValidationFailed { return .validation }
        if let responseState = input.responseState {
            return responseState == .emptyBody ? .emptyBody : .decodeFailure
        }
        if input.code == .emptyBody { return .emptyBody }
        switch input.code {
        case .offline?: return .offline
        case .dnsFailure?: return .dnsFailure
        case .connectionLost?: return .connectionLost
        case .timeout?: return .timeout
        default: return input.httpStatus == 408 || input.httpStatus == 504 ? .timeout : nil
        }
    }

    private static func serviceTarget(for operation: NativeErrorOperation) -> NativeErrorServiceTarget? {
        switch operation {
        case .identificationTypes: .identificationTypes
        case .installments: .installments
        case .paymentMethods: .paymentMethods
        case .issuers: .issuers
        case .cardFormInitialization: .checkoutInitialization
        case .orderSubmission: .orders
        case .cardTokenization, .cardFormSubmission, .cardFormCancellation, .installmentsCancellation: nil
        }
    }
}
