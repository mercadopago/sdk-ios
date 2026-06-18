import MPAnalytics

struct CardFormInitializeEventData: AnalyticsEventData {
    let checkoutType: String
    let appearance: String
    let sellerCustomization: [String]
    let excludedPaymentTypes: [String]
    let excludedPaymentMethods: [String]
    let orderId: String

    func toDictionary() -> [String: any Sendable] {
        [
            "checkout_type": self.checkoutType,
            "appearance": self.appearance,
            "seller_customization": self.sellerCustomization,
            "excluded_payment_types": self.excludedPaymentTypes,
            "excluded_payment_methods": self.excludedPaymentMethods,
            "order_id": self.orderId
        ]
    }
}
