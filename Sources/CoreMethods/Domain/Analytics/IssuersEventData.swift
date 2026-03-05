//
//  IssuersEventData.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 24/03/25.
//

#if SWIFT_PACKAGE
    import MPAnalytics
#endif
struct IssuersEventData: AnalyticsEventData {
    let issuers: [String]

    func toDictionary() -> [String: any Sendable] {
        return [
            "issuers": self.issuers
        ]
    }
}
