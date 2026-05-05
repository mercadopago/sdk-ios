//
//  CheckoutAPIErrorCode.swift
//  MercadoPagoSDK
//

enum CheckoutAPIErrorCode: String {
    case emptyPaymentMethods = "EMPTY_PAYMENT_METHODS"
    case paymentMethodUnavailable = "PAYMENT_METHOD_UNAVAILABLE"
    case installmentsUnavailable = "INSTALLMENTS_UNAVAILABLE"
    case identificationTypeUnavailable = "IDENTIFICATION_TYPE_UNAVAILABLE"
    case unsupportedSite = "UNSUPPORTED_SITE"

    static let binValidation: Set<Self> = [
        .emptyPaymentMethods,
        .paymentMethodUnavailable,
        .installmentsUnavailable,
        .identificationTypeUnavailable
    ]

    static let integration: Set<Self> = [
        .identificationTypeUnavailable,
        .unsupportedSite
    ]

    static func isIntegrationError(_ errorCode: String) -> Bool {
        CheckoutAPIErrorCode(rawValue: errorCode).map(CheckoutAPIErrorCode.integration.contains) == true
    }
}
