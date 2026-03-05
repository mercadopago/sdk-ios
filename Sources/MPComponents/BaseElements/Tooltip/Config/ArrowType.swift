//
//  ArrowType.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 08/09/25.
//

import SwiftUI

/// Defines the visual style of the tooltip arrow.
///
/// The arrow type determines how the tooltip's arrow is rendered and styled.
/// Currently, only the default arrow style is supported, but this enum provides
/// extensibility for future arrow variations.
///
/// ## Example Usage
///
/// ```swift
/// let config = DefaultTooltipConfig()
/// config.arrowType = .default
/// ```
package enum ArrowType: Sendable {
    /// The default arrow style with a triangular shape.
    ///
    /// This renders a simple triangle that points toward the element
    /// the tooltip is attached to. The arrow automatically adjusts
    /// its rotation based on the tooltip's `TooltipSide` position.
    case `default`
}
