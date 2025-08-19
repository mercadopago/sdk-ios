//
//  ApplePayEventData.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 19/08/25.
//
#if SWIFT_PACKAGE
    import MPAnalytics
#endif

struct ApplePayEventData: AnalyticsEventData {
    let typeWallet: String = "applepay"

    func toDictionary() -> [String: any Sendable] {
        return [
            "type_wallet": self.typeWallet,
        ]
    }
}
