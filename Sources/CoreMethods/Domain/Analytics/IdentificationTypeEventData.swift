//
//  IdentificationTypeEventData.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 28/04/25.
//
#if SWIFT_PACKAGE
    import MPAnalytics
#endif
struct IdentificationTypeEventData: AnalyticsEventData {
    let documentTypes: [String]?

    func toDictionary() -> [String: any Sendable] {
        return [
            "document_types": self.documentTypes ?? []
        ]
    }
}
