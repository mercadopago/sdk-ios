//
//  PaymentMethodEventData.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 10/03/25.
//
import MPAnalytics

struct PaymentMethodEventData: AnalyticsEventData {
    var issuer: Int?
    var paymentType: String?
    var sizeSecurityCode: Int?
    var cardBrand: String?

    func toDictionary() -> [String: String] {
        return [
            "card_brand": self.cardBrand ?? "",
            "issuer": self.issuer != nil ? "\(self.issuer ?? 0)" : "",
            "payment_type": self.paymentType ?? "",
            "size_security_code": self.sizeSecurityCode != nil ? "\(self.sizeSecurityCode ?? 0)" : ""
        ]
    }
}
