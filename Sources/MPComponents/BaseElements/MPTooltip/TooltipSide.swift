//
//  TooltipSide.swift
//  MPComponents
//

import Foundation

/// Defines the four cardinal positions for tooltip placement relative to the trigger view.
package enum MPTooltipSide: CaseIterable {
    case top
    case bottom
    case left
    case right

    func toPopoverSide() -> PopoverSide {
        switch self {
        case .top: return .top
        case .bottom: return .bottom
        case .left: return .left
        case .right: return .right
        }
    }
}
