//
//  TooltipConfig.swift
//  MPComponents
//

/// Configuration protocol for tooltip placement.
package protocol MPTooltipConfig: Sendable {
    /// The side where the tooltip should appear relative to the trigger view.
    var side: MPTooltipSide { get set }
}
