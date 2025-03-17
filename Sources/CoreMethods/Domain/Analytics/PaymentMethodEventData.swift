//
//  PaymentMethodEventData.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 10/03/25.
//
import MPAnalytics

struct PaymentMethodEventData: AnalyticsEventData {
    let issuer: Int?
    let paymentType: String?
    let sizeSecurityCode: Int?
    let cardBrand: String?

    init(
        issuer: Int? = nil,
        paymentType: String? = nil,
        sizeSecurityCode: Int? = nil,
        cardBrand: String? = nil
    ) {
        self.issuer = issuer
        self.paymentType = paymentType
        self.sizeSecurityCode = sizeSecurityCode
        self.cardBrand = cardBrand
    }

    func toDictionary() -> [String: any Sendable] {
        return [
            "card_brand": self.cardBrand ?? "",
            "issuer": self.issuer != nil ? "\(self.issuer ?? 0)" : "",
            "payment_type": self.paymentType ?? "",
            "security_length": self.sizeSecurityCode != nil ? "\(self.sizeSecurityCode ?? 0)" : ""
        ]
    }
}
