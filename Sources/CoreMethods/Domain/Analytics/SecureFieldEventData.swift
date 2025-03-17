//
//  SecureFieldEventData.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 14/03/25.
//
import MPAnalytics

struct SecureFieldEventData: AnalyticsEventData {
    let field: FieldType?
    let frameworkUI: FrameworkType?

    enum FieldType: String, Encodable {
        case cardNumber
        case expirationDate
        case securityCode
    }

    func toDictionary() -> [String: any Sendable] {
        return [
            "field": self.field?.rawValue ?? "",
            "framework_ui": self.frameworkUI?.rawValue ?? "",
            "is_development": self.isDevelopment
        ]
    }
}
