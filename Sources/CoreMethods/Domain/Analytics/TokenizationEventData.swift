//
//  TokenizationEventData.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 19/03/25.
//
import MPAnalytics

struct TokenizationEventData: AnalyticsEventData {
    let isSaveCard: Bool
    let documentType: String

    func toDictionary() -> [String: any Sendable] {
        return [
            "is_saved_card": self.isSaveCard,
            "document_type": self.documentType
        ]
    }
}
