//
//  TooltipSide.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 08/09/25.
//

import SwiftUI

/// Defines the positioning of tooltips relative to their target views.
///
/// `TooltipSide` determines both where the tooltip appears and the direction
/// of its pointing arrow (if enabled). The enum values are organized to provide
/// mathematical relationships for arrow angle calculations.
///
/// ## Basic Positions
///
/// The four cardinal directions provide standard tooltip positioning:
/// - `.top`: Tooltip appears above the target
/// - `.bottom`: Tooltip appears below the target  
/// - `.left`: Tooltip appears to the left of the target
/// - `.right`: Tooltip appears to the right of the target
///
/// ## Corner Positions
///
/// Diagonal positions offer more precise placement:
/// - `.topLeft`: Tooltip appears above and to the left
/// - `.topRight`: Tooltip appears above and to the right
/// - `.bottomLeft`: Tooltip appears below and to the left
/// - `.bottomRight`: Tooltip appears below and to the right
///
/// ## Special Cases
///
/// - `.center`: Centers the tooltip without an arrow
///
/// ## Example Usage
///
/// ```swift
/// let config = DefaultTooltipConfig(side: .top, type: .blue)
/// ```
package enum TooltipSide: Int, CaseIterable, Sendable {
    /// Centers the tooltip over the target without showing an arrow.
    case center = -1
    
    /// Positions the tooltip to the left of the target.
    case left = 2
    
    /// Positions the tooltip to the right of the target.
    case right = 6
    
    /// Positions the tooltip above the target.
    case top = 4
    
    /// Positions the tooltip below the target.
    case bottom = 0

    /// Positions the tooltip above and to the left of the target.
    case topLeft = 3
    
    /// Positions the tooltip above and to the right of the target.
    case topRight = 5
    
    /// Positions the tooltip below and to the left of the target.
    case bottomLeft = 1
    
    /// Positions the tooltip below and to the right of the target.
    case bottomRight = 7
    
    /// Calculates the arrow rotation angle for this tooltip position.
    ///
    /// The raw values are strategically chosen to create proper arrow angles
    /// when multiplied by π/4. Each increment represents a 45-degree rotation.
    ///
    /// - Returns: The arrow angle in radians, or `nil` for center positioning.
    func getArrowAngleRadians() -> Optional<Double> {
        if self == .center { return nil }
        return Double(self.rawValue) * .pi / 4
    }
    
    /// Determines if an arrow should be displayed for this tooltip position.
    ///
    /// - Returns: `true` for all positions except `.center`, which has no arrow.
    func shouldShowArrow() -> Bool {
        if self == .center { return false }
        return true
    }
}
