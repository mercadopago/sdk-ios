//
//  DependencyContainer.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 05/02/25.
//

import Foundation
import MPAnalytics

typealias DI = Sendable & HasAnalytics & HasNetwork

package final class CoreDependencyContainer: DI {
    package let networkService: NetworkServiceProtocol

    package let analytics: AnalyticsInterface

    package static let shared = CoreDependencyContainer()

    private init() {
        self.networkService = NetworkService()
        self.analytics = MPAnalytics()
    }
}
