//
//  CoreDependencyContainer.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 05/02/25.
//

import Foundation
import MPAnalytics

/// Protocol combining core SDK dependencies for analytics and networking
typealias DI = Sendable & HasAnalytics & HasNetwork & HasKeyChain

/// Main dependency container managing SDK services
///
/// Example usage:
/// ```swift
/// class Example {
///     typealias Dependency = HasNetwork
///     let dependencies: Dependency
///
///     init(dependencies: Dependency = CoreDependencyContainer.shared) {
///         self.dependencies = dependencies
///     }
///
///     func exampleCall() {
///        dependencies.networkService...
///     }
/// }
/// ```
package final class CoreDependencyContainer: DI {
    /// Network service for handling API requests
    package let networkService: NetworkServiceProtocol

    /// Analytics service for tracking SDK events
    package var analytics: AnalyticsInterface {
        return MPAnalytics()
    }

    package let keyChainService: KeyChainManagerProtocol

    /// Shared singleton instance of the container
    package static let shared = CoreDependencyContainer()

    /// Private initializer configuring default services
    package init(
        networkService: NetworkServiceProtocol = NetworkService(),
        keyChainService: KeyChainManagerProtocol = KeychainManager()
    ) {
        self.networkService = networkService
        self.keyChainService = keyChainService
    }
}
