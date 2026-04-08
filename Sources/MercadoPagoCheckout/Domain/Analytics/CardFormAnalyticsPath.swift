import Foundation

enum CardFormAnalyticsPath {
    static let initialize = "/checkout_api_native/checkout/card_form/initialize"
    static let inputValidation = "/checkout_api_native/checkout/card_form/input_validation"
    static let dropdownSelection = "/checkout_api_native/checkout/card_form/dropdown_selection"
    static let submit = "/checkout_api_native/checkout/card_form/submit"
    static let initializeError = "/checkout_api_native/checkout/card_form/initialize_error"
    static let submitError = "/checkout_api_native/checkout/card_form/submit_error"
    static let userCanceledError = "/checkout_api_native/checkout/card_form/user_canceled_error"
}
