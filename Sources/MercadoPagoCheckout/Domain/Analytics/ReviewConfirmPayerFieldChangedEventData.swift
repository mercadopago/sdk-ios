//
//  ReviewConfirmPayerFieldChangedEventData.swift
//  MercadoPagoSDK
//

import MPAnalytics

struct ReviewConfirmPayerFieldChangedEventData: AnalyticsEventData {
    let changedField: String

    func toDictionary() -> [String: any Sendable] {
        ["changed_field": self.changedField]
    }
}
