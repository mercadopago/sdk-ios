//
//  DefaultTooltipConfig.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 08/09/25.
//

import SwiftUI
import MPFoundation

/// Visual theme styles available for tooltips.
///
/// The tooltip type determines the overall color scheme and visual appearance.
/// Each type provides a different aesthetic suitable for various use cases.
package enum TooltipType: CaseIterable, Sendable {
    case white
}

/// Default implementation of `TooltipConfig` with sensible defaults.
///
/// `DefaultTooltipConfig` provides a ready-to-use tooltip configuration that
/// works well for most scenarios. It includes reasonable defaults for positioning,
/// sizing, animation, and theming while remaining fully customizable.
///
package struct DefaultTooltipConfig: TooltipConfig {
    // MARK: - Default Values
    
    /// Default tooltip positioning relative to target view. Defaults to `.top`.
    package var side: TooltipSide = .top
    
    /// Default margin between tooltip and target view. Defaults to 8 points.
    package var margin: CGFloat = 8
    
    /// Default z-index for proper layering. Defaults to 10000.
    package var zIndex: Double = 10000
    
    /// Optional width constraint. When nil, tooltip sizes to content.
    package var width: CGFloat? = 246
    
    /// Optional height constraint. When nil, tooltip sizes to content.
    package var height: CGFloat? = 112

    /// Whether to display the pointing arrow. Defaults to `true`.
    package var showArrow: Bool = true
    
    /// Width of the tooltip arrow. Defaults to 12 points.
    package var arrowWidth: CGFloat = 12
    
    /// Height of the tooltip arrow. Defaults to 6 points.
    package var arrowHeight: CGFloat = 6
    
    /// Style of the tooltip arrow. Defaults to `.default`.
    package var arrowType: ArrowType = .default
    
    /// Visual theme type for the tooltip. Defaults to `.blue`.
    package var type: TooltipType = .white

    // MARK: - Initializers
    
    /// Creates a default tooltip configuration.
    ///
    /// Uses standard defaults suitable for most tooltip scenarios.
    package init() {}

    /// Creates a tooltip configuration with specific positioning and theme.
    ///
    /// - Parameters:
    ///   - side: The side where the tooltip should appear relative to its target.
    ///   - type: The visual theme type for the tooltip.
    package init(side: TooltipSide, type: TooltipType) {
        self.side = side
        self.type = type
    }
    
    // MARK: - Theme Integration Methods
    
    /// Returns the standard border radius from the design system.
    package func borderRadius(from theme: MPTheme) -> CGFloat {
        return theme.borderRadius.medium
    }
    
    /// Returns a minimal border width from the design system.
    package func borderWidth(from theme: MPTheme) -> CGFloat {
        return theme.borderWidth.small
    }
    
    /// Returns the appropriate background color based on tooltip type.
    ///
    /// - `.blue`: Uses theme accent color for informational tooltips
    /// - `.dark`: Uses inverted background for high contrast tooltips
    package func backgroundColor(from theme: MPTheme) -> Color {
        switch type {
        case .white:
            return theme.colors.fill.primary
        }
    }
    
    /// Returns consistent medium padding for tooltip content.
    package func contentPadding(from theme: MPTheme) -> EdgeInsets {
        return EdgeInsets(
            top: theme.spacings.micro,
            leading: theme.spacings.micro,
            bottom: theme.spacings.micro,
            trailing: theme.spacings.micro
        )
    }
}
