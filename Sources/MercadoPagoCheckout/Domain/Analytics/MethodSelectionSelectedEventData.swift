//
//  MethodSelectionSelectedEventData.swift
//  MercadoPagoSDK
//

import MPAnalytics

struct MethodSelectionSelectedEventData: AnalyticsEventData {
    let paymentMethodId: String
    let selectionType: String

    func toDictionary() -> [String: any Sendable] {
        [
            "payment_method_id": self.paymentMethodId,
            "selection_type": self.selectionType
        ]
    }
}
