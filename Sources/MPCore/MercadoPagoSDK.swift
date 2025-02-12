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

    public struct Configuration {
        let publicKey: String
        let locale: String = Locale.current.identifier
    }

    var configuration: Configuration?

    typealias Dependency = HasAnalytics & HasNetwork

    private let dependencies: Dependency

    private init(dependencies: Dependency = CoreDependencyContainer.shared) {
        self.dependencies = dependencies
    }

    public func initialize(_ configuration: Configuration) throws {
        if self.isInitialized {
            throw SDKError.alreadyInitialized
        }

        guard !configuration.publicKey.isEmpty else {
            throw SDKError.invalidPublicKey
        }

        Task {
            // TODO: Fazer use case, cachear retorno do site (guardar na keychain ?) se der tudo errado retorna unknown
            let data: SiteIDEntry = try await dependencies.networkService.request(CoreAPIEndpoint.getSiteID)

            self.dependencies.analytics.initialize(
                version: MPSDKVersion.version,
                siteID: data.siteID
            )

            await sendInitializeAnalytics()
        }
        self.configuration = configuration
        self.isInitialized = true
    }

    func getPublicKey() throws -> String {
        guard let key = configuration?.publicKey else {
            throw SDKError.notInitialized
        }

        return key
    }
}

private extension MercadoPagoSDK {
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
