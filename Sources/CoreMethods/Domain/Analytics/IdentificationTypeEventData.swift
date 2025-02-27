//
//  IdentificationTypeEventData.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 25/02/25.
//
import MPAnalytics

struct IdentificationTypeEventData: AnalyticsEventData {
    let error: String?

    init(error: String?) {
        self.error = error
    }

    func toDictionary() -> [String: String] {
        if let error {
            return [
                "error": error
            ]
        } else {
            return [:]
        }
    }
}
