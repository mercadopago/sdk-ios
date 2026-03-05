//
//  HasNetwork.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 06/02/25.
//

/// A protocol that provides access to network functionality.
///
/// Conform to this protocol when a type needs to network.
/// The conforming type should provide access to an network interface implementation.
package protocol HasNetwork: Sendable {
    /// The analytics interface instance used for event tracking.
    var networkService: NetworkServiceProtocol { get }
}
