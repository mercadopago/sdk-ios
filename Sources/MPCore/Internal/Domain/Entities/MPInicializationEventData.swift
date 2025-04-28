//
//  MPInicializationEventData.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 12/02/25.
//

#if SWIFT_PACKAGE
    import MPAnalytics
#endif

struct MPInicializationEventData: AnalyticsEventData {
    let locale: String
    let distribution: String
    let minimumVersionApp: String
    let publicKey: String
    let sdkVersion: String

    func toDictionary() -> [String: any Sendable] {
        return [
            "locale": self.locale,
            "distribution": self.distribution,
            "min_version": self.minimumVersionApp,
            "public_key": self.publicKey,
            "developer_mode": isDevelopment,
            "sdk_version": self.sdkVersion
        ]
    }
}
