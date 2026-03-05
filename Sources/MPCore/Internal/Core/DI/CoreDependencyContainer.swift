//
//  CoreDependencyContainer.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 05/02/25.
//

import Foundation
#if SWIFT_PACKAGE
    import MPAnalytics
#endif

package protocol HasNoDependency: Sendable {}


/// Protocol combining core SDK dependencies for analytics and networking
typealias DI = Sendable & HasNoDependency & HasAnalytics & HasNetwork & HasFingerPrint

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

    package let fingerPrint: FingerPrintProtocol

    /// Shared singleton instance of the container
    package static let shared = CoreDependencyContainer()

    /// Private initializer configuring default services
    package init(
        networkService: NetworkServiceProtocol = NetworkService()
    ) {
        self.networkService = networkService
        self.fingerPrint = FingerPrint()
    }
}
