//
//  MercadoPagoSDK.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 11/02/25.
//

import Foundation
import MPAnalytics

public final class MercadoPagoSDK: @unchecked Sendable {
    public static let shared = MercadoPagoSDK()

    private let lock = NSLock()
    private var isInitialized = false

    let siteIDUseCase: FetchSiteIDUseCaseProtocol = FetchSiteIDUseCase()

    public struct Configuration: Sendable {
        let publicKey: String
        let locale: String

        public init(publicKey: String, locale: String = Locale.current.identifier) {
            self.publicKey = publicKey
            self.locale = locale
        }
    }

    var configuration: Configuration?

    typealias Dependency = HasAnalytics

    private let dependencies: Dependency

    private init(dependencies: Dependency = CoreDependencyContainer.shared) {
        self.dependencies = dependencies
    }

    public func initialize(_ configuration: Configuration) {
        verifyCanBeInitialized(configuration)

        self.configuration = configuration
        self.isInitialized = true

        Task(priority: .background) {
            let siteID = await siteIDUseCase.getSiteID(by: configuration.publicKey)

            self.dependencies.analytics.initialize(
                version: MPSDKVersion.version,
                siteID: siteID
            )

            await sendInitializeAnalytics()
        }
    }

    package func getPublicKey() -> String {
        guard let key = configuration?.publicKey else {
            assert(self.configuration?.publicKey.isEmpty ?? true, SDKError.notInitialized.rawValue)
            return ""
        }

        return key
    }
}

private extension MercadoPagoSDK {
    func verifyCanBeInitialized(_ configuration: Configuration) {
        assert(
            !self.isInitialized,
            SDKError.alreadyInitialized.rawValue
        )

        assert(
            !configuration.publicKey.isEmpty,
            SDKError.invalidPublicKey.rawValue
        )
    }

    func sendInitializeAnalytics() async {
        let eventData = MPInicializationEventData(
            locale: self.configuration?.locale ?? "",
            distribution: self.dependencies.analytics.sellerInfo.getDistribution().rawValue,
            minimumVersionApp: self.dependencies.analytics.sellerInfo.getTargetMinimum()
        )

        await self.dependencies.analytics
            .trackEvent("/sdk-native")
            .setEventData(eventData)
            .send()
    }
}
