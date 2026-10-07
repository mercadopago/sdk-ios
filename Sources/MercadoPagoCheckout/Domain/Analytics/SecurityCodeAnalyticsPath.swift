enum SecurityCodeAnalyticsPath {
    static let initialize = "/checkout_api_native/checkout/payment_brick/cvv"
    static let submit = "/checkout_api_native/checkout/payment_brick/cvv_continue"
    static let submitError = "/checkout_api_native/checkout/payment_brick/cvv_continue_error"
    static let userCanceledError = "/checkout_api_native/checkout/payment_brick/cvv_back"
}
