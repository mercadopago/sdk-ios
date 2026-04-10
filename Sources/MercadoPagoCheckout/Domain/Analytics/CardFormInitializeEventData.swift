import MPAnalytics

struct CardFormInitializeEventData: AnalyticsEventData {
    let checkoutType: String
    let appearance: String
    let sellerCustomization: [String]
    let allowedPaymentTypes: [String]
    let allowedPaymentMethods: [String]

    func toDictionary() -> [String: any Sendable] {
        [
            "checkout_type": self.checkoutType,
            "appearance": self.appearance,
            "seller_customization": self.sellerCustomization,
            "allowed_payment_types": self.allowedPaymentTypes,
            "allowed_payment_methods": self.allowedPaymentMethods
        ]
    }
}
