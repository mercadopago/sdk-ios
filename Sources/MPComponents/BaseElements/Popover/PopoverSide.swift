//
//  PopoverSide.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 08/09/25.
//

import SwiftUI

/// Defines the positioning of popovers relative to their target views.
///
/// `PopoverSide` determines both where the popover appears and the direction
/// of its pointing arrow (if enabled). The enum values are organized to provide
/// mathematical relationships for arrow angle calculations.
///
/// ## Basic Positions
///
/// The four cardinal directions provide standard popover positioning:
/// - `.top`: Popover appears above the target
/// - `.bottom`: Popover appears below the target  
/// - `.left`: Popover appears to the left of the target
/// - `.right`: Popover appears to the right of the target
///
/// ## Corner Positions
///
/// Diagonal positions offer more precise placement:
/// - `.topLeft`: Popover appears above and to the left
/// - `.topRight`: Popover appears above and to the right
/// - `.bottomLeft`: Popover appears below and to the left
/// - `.bottomRight`: Popover appears below and to the right
///
/// ## Special Cases
///
/// - `.center`: Centers the popover without an arrow
///
/// ## Example Usage
///
/// ```swift
/// let config = DefaultPopoverConfig(side: .top, type: .blue)
/// ```
package enum PopoverSide: Int, CaseIterable, Sendable {
    /// Centers the popover over the target without showing an arrow.
    case center = -1
    
    /// Positions the popover to the left of the target.
    case left = 2
    
    /// Positions the popover to the right of the target.
    case right = 6
    
    /// Positions the popover above the target.
    case top = 4
    
    /// Positions the popover below the target.
    case bottom = 0

    /// Positions the popover above and to the left of the target.
    case topLeft = 3
    
    /// Positions the popover above and to the right of the target.
    case topRight = 5
    
    /// Positions the popover below and to the left of the target.
    case bottomLeft = 1
    
    /// Positions the popover below and to the right of the target.
    case bottomRight = 7
    
    /// Calculates the arrow rotation angle for this popover position.
    ///
    /// The raw values are strategically chosen to create proper arrow angles
    /// when multiplied by π/4. Each increment represents a 45-degree rotation.
    ///
    /// - Returns: The arrow angle in radians, or `nil` for center positioning.
    func getArrowAngleRadians() -> Optional<Double> {
        if self == .center { return nil }
        return Double(self.rawValue) * .pi / 4
    }
    
    /// Determines if an arrow should be displayed for this popover position.
    ///
    /// - Returns: `true` for all positions except `.center`, which has no arrow.
    func shouldShowArrow() -> Bool {
        if self == .center { return false }
        return true
    }
}
