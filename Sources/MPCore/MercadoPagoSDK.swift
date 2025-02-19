//
//  MercadoPagoSDK.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 11/02/25.
//

import Foundation
import MPAnalytics

/// Main entry point for MercadoPago SDK
public final class MercadoPagoSDK: @unchecked Sendable {
    public static let shared: MercadoPagoSDK = {
        let container = CoreDependencyContainer.shared
        let useCase = FetchSiteIDUseCaseFactory.make(dependencies: container)

        return MercadoPagoSDK(dependencies: container, useCase: useCase)
    }()

    var siteIDUseCase: FetchSiteIDUseCaseProtocol

    private let lock = NSLock()

    /// Configuration options for MercadoPagoSDK
    public struct Configuration: Sendable {
        let publicKey: String
        let locale: String
        let country: MercadoPagoSDK.Country

        /// Initialize SDK configuration
        /// - Parameters:
        ///   - publicKey: Your MercadoPago public key
        ///   - locale: Locale identifier (defaults to system locale)
        public init(
            publicKey: String,
            locale: String = Locale.current.identifier,
            country: Country
        ) {
            self.publicKey = publicKey
            self.locale = locale
            self.country = country
        }
    }

    private(set) var isInitialized = false
    private(set) var configuration: Configuration?
    private(set) var analyticsMonitoringTask: Task<Void, Never>?

    typealias Dependency = HasAnalytics

    private let dependencies: Dependency

    init(dependencies: Dependency, useCase: FetchSiteIDUseCaseProtocol) {
        self.dependencies = dependencies
        self.siteIDUseCase = useCase
    }

    /// Initialize the SDK with required configuration
    /// Should call only once, when app open (AppDelegate, SceneDelegate or @main
    /// - Parameter configuration: SDK configuration options
    public func initialize(_ configuration: Configuration) {
        verifyCanBeInitialized(configuration)

        self.configuration = configuration
        self.isInitialized = true

        self.analyticsMonitoringTask = Task(priority: .background) {
            await self.dependencies.analytics.initialize(
                version: MPSDKVersion.version,
                siteID: configuration.country.getSiteId()
            )

            let siteID = await siteIDUseCase.getSiteID(
                with: configuration.publicKey,
                and: configuration.country
            )

            await self.dependencies.analytics.initialize(
                version: MPSDKVersion.version,
                siteID: siteID
            )

            await sendInitializeAnalyticsEvent()
        }
    }

    /// Get the configured public key
    /// - Returns: The public key string
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

    func sendInitializeAnalyticsEvent() async {
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
