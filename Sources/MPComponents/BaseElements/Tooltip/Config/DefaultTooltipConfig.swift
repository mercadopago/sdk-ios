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
    /// A blue-themed tooltip with accent colors.
    ///
    /// This type uses the theme's accent color for the background,
    /// making it ideal for informational content and feature highlights.
    case blue
    
    /// A dark-themed tooltip with high contrast.
    ///
    /// This type uses inverted background colors for better visibility
    /// and contrast, suitable for tooltips that need to stand out.
    case dark
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
    package var width: CGFloat?
    
    /// Optional height constraint. When nil, tooltip sizes to content.
    package var height: CGFloat?

    /// Whether to display the pointing arrow. Defaults to `true`.
    package var showArrow: Bool = true
    
    /// Width of the tooltip arrow. Defaults to 12 points.
    package var arrowWidth: CGFloat = 12
    
    /// Height of the tooltip arrow. Defaults to 6 points.
    package var arrowHeight: CGFloat = 6
    
    /// Style of the tooltip arrow. Defaults to `.default`.
    package var arrowType: ArrowType = .default
    
    /// Whether subtle animations are enabled. Defaults to `false`.
    package var enableAnimation: Bool = false
    
    /// Distance of animation movement. Defaults to 10 points.
    package var animationOffset: CGFloat = 10
    
    /// Duration of each animation cycle. Defaults to 1 second.
    package var animationTime: Double = 1
    
    /// Animation curve for movements. Defaults to `.easeInOut`.
    package var animation: Optional<Animation> = .easeInOut
    
    /// Visual theme type for the tooltip. Defaults to `.blue`.
    package var type: TooltipType = .blue

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
        return theme.borderRadius.s
    }
    
    /// Returns a minimal border width from the design system.
    package func borderWidth(from theme: MPTheme) -> CGFloat {
        return theme.outline.xs
    }
    
    /// Returns a clear border color for borderless tooltips.
    package func borderColor(from theme: MPTheme) -> Color {
        return .clear
    }
    
    /// Returns the appropriate background color based on tooltip type.
    ///
    /// - `.blue`: Uses theme accent color for informational tooltips
    /// - `.dark`: Uses inverted background for high contrast tooltips
    package func backgroundColor(from theme: MPTheme) -> Color {
        switch type {
        case .blue:
            return theme.colors.accent
        case .dark:
            return theme.colors.backgroundInverted
        }
    }
    
    /// Returns a transparent shadow color for minimal visual impact.
    package func shadowColor(from theme: MPTheme) -> Color {
        return .clear
    }
    
    /// Returns a subtle shadow radius from the design system.
    package func shadowRadius(from theme: MPTheme) -> CGFloat {
        return theme.spacings.xxs
    }
    
    /// Returns a minimal downward shadow offset for subtle depth.
    package func shadowOffset(from theme: MPTheme) -> CGPoint {
        return CGPoint(x: 0, y: theme.spacings.xxs/2)
    }
    
    /// Returns consistent medium padding for tooltip content.
    package func contentPadding(from theme: MPTheme) -> EdgeInsets {
        return EdgeInsets(
            top: theme.spacings.m,
            leading: theme.spacings.m,
            bottom: theme.spacings.m,
            trailing: theme.spacings.m
        )
    }
}
