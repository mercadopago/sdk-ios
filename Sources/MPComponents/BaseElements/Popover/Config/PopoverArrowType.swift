//
//  PopoverArrowType.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 08/09/25.
//

import SwiftUI

/// Defines the visual style of the popover arrow.
///
/// The arrow type determines how the popover's arrow is rendered and styled.
/// Currently, only the default arrow style is supported, but this enum provides
/// extensibility for future arrow variations.
///
/// ## Example Usage
///
/// ```swift
/// let config = DefaultPopoverConfig()
/// config.arrowType = .default
/// ```
package enum PopoverArrowType: Sendable {
    /// The default arrow style with a triangular shape.
    ///
    /// This renders a simple triangle that points toward the element
    /// the popover is attached to. The arrow automatically adjusts
    /// its rotation based on the popover's `PopoverSide` position.
    case `default`
}
