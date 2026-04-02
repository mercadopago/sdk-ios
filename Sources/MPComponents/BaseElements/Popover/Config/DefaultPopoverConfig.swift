//
//  DefaultPopoverConfig.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 08/09/25.
//

import MPFoundation
import SwiftUI

/// Visual theme styles available for popovers.
///
/// The popover type determines the overall color scheme and visual appearance.
/// Each type provides a different aesthetic suitable for various use cases.
package enum PopoverType: CaseIterable {
    case white
}

/// Default implementation of `PopoverConfig` with sensible defaults.
///
/// `DefaultPopoverConfig` provides a ready-to-use popover configuration that
/// works well for most scenarios. It includes reasonable defaults for positioning,
/// sizing, animation, and theming while remaining fully customizable.
///
package struct DefaultPopoverConfig: PopoverConfig {
    // MARK: - Default Values

    /// Default popover positioning relative to target view. Defaults to `.top`.
    package var side: PopoverSide = .top

    /// Default margin between popover and target view. Defaults to 8 points.
    package var margin: CGFloat = 8

    /// Maximum width constraint. Popover will size to content up to this limit.
    /// When nil, popover has no width constraint.
    package var maxWidth: CGFloat? = 246

    /// Maximum height constraint. Popover will size to content up to this limit.
    /// When nil (default), popover height is determined by content.
    package var maxHeight: CGFloat?

    /// Whether to display the pointing arrow. Defaults to `true`.
    package var showArrow = true

    /// Width of the popover arrow. Defaults to 12 points.
    package var arrowWidth: CGFloat = 12

    /// Height of the popover arrow. Defaults to 6 points.
    package var arrowHeight: CGFloat = 6

    /// Style of the popover arrow. Defaults to `.default`.
    package var arrowType: PopoverArrowType = .default

    /// Visual theme type for the popover. Defaults to `.blue`.
    package var type: PopoverType = .white

    // MARK: - Initializers

    /// Creates a default popover configuration.
    ///
    /// Uses standard defaults suitable for most popover scenarios.
    package init() {}

    /// Creates a popover configuration with specific positioning and theme.
    ///
    /// - Parameters:
    ///   - side: The side where the popover should appear relative to its target.
    ///   - type: The visual theme type for the popover.
    package init(side: PopoverSide, type: PopoverType) {
        self.side = side
        self.type = type
    }

    package init(side: PopoverSide, type: PopoverType, maxWidth: CGFloat? = 246) {
        self.side = side
        self.type = type
        self.maxWidth = maxWidth
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

    /// Returns the appropriate background color based on popover type.
    ///
    /// - `.blue`: Uses theme accent color for informational popovers
    /// - `.dark`: Uses inverted background for high contrast popovers
    package func backgroundColor(from theme: MPTheme) -> Color {
        switch self.type {
        case .white:
            return theme.colors.fill.primary
        }
    }

    /// Returns consistent medium padding for popover content.
    package func contentPadding(from theme: MPTheme) -> EdgeInsets {
        return EdgeInsets(
            top: theme.spacings.paddings.xtiny,
            leading: theme.spacings.paddings.xtiny,
            bottom: theme.spacings.paddings.xtiny,
            trailing: theme.spacings.paddings.xtiny
        )
    }
}
