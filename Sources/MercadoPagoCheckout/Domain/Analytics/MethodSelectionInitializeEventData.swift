//
//  MethodSelectionInitializeEventData.swift
//  MercadoPagoSDK
//

import MPAnalytics

struct MethodSelectionInitializeEventData: AnalyticsEventData {
    let optionsCount: Int
    let selectionType: String

    func toDictionary() -> [String: any Sendable] {
        [
            "options_count": self.optionsCount,
            "selection_type": self.selectionType
        ]
    }
}
