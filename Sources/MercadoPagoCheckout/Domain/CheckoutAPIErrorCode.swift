//
//  CheckoutAPIErrorCode.swift
//  MercadoPagoSDK
//

enum CheckoutAPIErrorCode {
    enum Integration: String {
        case identificationTypeUnavailable = "IDENTIFICATION_TYPE_UNAVAILABLE"
        case unsupportedSite = "UNSUPPORTED_SITE"
    }

    enum Acceptance: String {
        case emptyPaymentMethods = "EMPTY_PAYMENT_METHODS"
        case paymentMethodUnavailable = "PAYMENT_METHOD_UNAVAILABLE"
    }
}
