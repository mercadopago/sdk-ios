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

    func toDictionary() -> [String: any Sendable] {
        return [
            "transaction_amount": self.amount != nil ? "\(self.amount ?? 0)" : "",
            "payment_type": self.paymentType ?? ""
        ]
    }
}
