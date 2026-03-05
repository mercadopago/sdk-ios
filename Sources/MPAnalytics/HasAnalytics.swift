///
///  HasAnalytics.swift
///  MercadoPagoSDK-iOS
///
///  Created by Guilherme Prata Costa on 03/01/25.
///  Copyright © 2024 Mercado Pago. All rights reserved.
///
/// A protocol that provides access to analytics functionality.
///
/// Conform to this protocol when a type needs to track analytics events.
/// The conforming type should provide access to an analytics interface implementation.
package protocol HasAnalytics: Sendable {
    /// The analytics interface instance used for event tracking.
    var analytics: AnalyticsInterface { get }
}
