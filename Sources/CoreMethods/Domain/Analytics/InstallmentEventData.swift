//
//  InstallmentEventData.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 10/03/25.
//

import MPAnalytics

struct InstallmentEventData: AnalyticsEventData {
    let amount: Double?
    let paymentType: String?
    let bin: String?

    func toDictionary() -> [String: String] {
        return [
            "bin": self.bin ?? "",
            "issuer": self.amount != nil ? "\(self.amount ?? 0)" : "",
            "payment_type": self.paymentType ?? ""
        ]
    }
}
