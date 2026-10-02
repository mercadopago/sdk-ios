//
//  ReviewConfirmAnalyticsPath.swift
//  MercadoPagoSDK
//

enum ReviewConfirmAnalyticsPath {
    static let initialize = "/checkout_api_native/checkout/review_confirm"
    static let continuePayment = "/checkout_api_native/checkout/review_confirm_continue"
    static let back = "/checkout_api_native/checkout/review_confirm_back"
    static let paymentMethodChanged = "/checkout_api_native/checkout/review_confirm_payment_method_changed"
    static let payerFieldChanged = "/checkout_api_native/checkout/review_confirm_payer_field_changed"
}
