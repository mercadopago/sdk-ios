import Foundation

package enum NativeErrorModule: String, Codable, Sendable {
    case coreMethods = "core_methods"
    case checkout
}

package enum NativeErrorOperation: String, Codable, Sendable, CaseIterable {
    case identificationTypes = "identification_types"
    case installments
    case paymentMethods = "payment_methods"
    case issuers
    case cardTokenization = "card_tokenization"
    case cardFormInitialization = "card_form_initialization"
    case cardFormSubmission = "card_form_submission"
    case cardFormCancellation = "card_form_cancellation"
    case installmentsCancellation = "installments_cancellation"
    case orderSubmission = "order_submission"

    package var module: NativeErrorModule {
        switch self {
        case .identificationTypes, .installments, .paymentMethods, .issuers, .cardTokenization:
            return .coreMethods
        case .cardFormInitialization, .cardFormSubmission, .cardFormCancellation,
             .installmentsCancellation, .orderSubmission:
            return .checkout
        }
    }
}

package enum NativeErrorCategory: String, Codable, Sendable {
    case cancellation
    case inputValidation = "input_validation"
    case network
    case service
    case integration
    case unknown
}

package enum NativeErrorCode: String, Codable, Sendable, CaseIterable {
    case userCancelled = "user_cancelled"
    case requestCancelled = "request_cancelled"
    case inputValidationFailed = "input_validation_failed"
    case connectionUnavailable = "connection_unavailable"
    case requestTimeout = "request_timeout"
    case upstreamRejected = "upstream_rejected"
    case responseContractInvalid = "response_contract_invalid"
    case sdkConfigurationInvalid = "sdk_configuration_invalid"
    case operationFailed = "operation_failed"

    package var category: NativeErrorCategory {
        switch self {
        case .userCancelled, .requestCancelled: .cancellation
        case .inputValidationFailed: .inputValidation
        case .connectionUnavailable: .network
        case .requestTimeout, .upstreamRejected: .service
        case .responseContractInvalid, .sdkConfigurationInvalid: .integration
        case .operationFailed: .unknown
        }
    }

    package var isCritical: Bool {
        switch self {
        case .userCancelled, .requestCancelled, .inputValidationFailed, .connectionUnavailable:
            false
        case .requestTimeout, .upstreamRejected, .responseContractInvalid,
             .sdkConfigurationInvalid, .operationFailed:
            true
        }
    }
}

package enum NativeErrorServiceTarget: String, Codable, Sendable {
    case identificationTypes = "identification_types"
    case installments
    case paymentMethods = "payment_methods"
    case issuers
    case cardTokens = "card_tokens"
    case checkoutInitialization = "checkout_initialization"
    case orders
}

package enum NativeErrorDiagnosticCode: String, Codable, Sendable {
    case cancelled
    case validation
    case offline
    case dnsFailure = "dns_failure"
    case connectionLost = "connection_lost"
    case timeout
    case emptyBody = "empty_body"
    case decodeFailure = "decode_failure"
    case invalidURL = "invalid_url"
    case httpUnauthorized = "http_unauthorized"
    case httpForbidden = "http_forbidden"
}

package enum NativeErrorDeliveryMode: String, Sendable {
    case melidataOnly = "melidata_only"
    case dualWrite = "dual_write"
    case observabilityOnly = "observability_only"

    package var sendsMelidata: Bool { self != .observabilityOnly }
    package var sendsObservability: Bool { self != .melidataOnly }
}
