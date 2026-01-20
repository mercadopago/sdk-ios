//
//  PopoverConfig.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 08/09/25.
//

import SwiftUI
import MPFoundation

/// Configuration protocol for popover appearance and behavior.
///
/// The `PopoverConfig` protocol defines all customizable aspects of a popover,
/// including positioning, sizing, styling, animations, and theming. Implement this
/// protocol to create custom popover configurations with different visual styles
/// and behaviors.
///
/// ## Default Implementation
///
/// The SDK provides `DefaultPopoverConfig` as a standard implementation with
/// sensible defaults for most use cases.
///
/// ```swift
/// let config = DefaultPopoverConfig(side: .top, type: .blue)
/// ```
///
/// ## Custom Configuration
///
/// Create custom configurations by conforming to this protocol:
///
/// ```swift
/// struct CustomPopoverConfig: PopoverConfig {
///     var side: PopoverSide = .bottom
///     var type: PopoverType = .dark
///     // ... implement required properties and methods
/// }
/// ```
package protocol PopoverConfig: Sendable {
    // MARK: - Positioning and Layout
    
    /// The side where the popover should appear relative to its target view.
    ///
    /// This determines both the popover's position and the arrow direction.
    /// Common values include `.top`, `.bottom`, `.left`, `.right`, and diagonal
    /// combinations like `.topLeft`, `.bottomRight`.
    var side: PopoverSide { get set }
    
    /// The minimum distance between the popover and its target view, in points.
    ///
    /// This margin ensures the popover doesn't appear too close to the target,
    /// providing better visual separation and readability.
    var margin: CGFloat { get set }
    
    /// The z-index for popover layering in the view hierarchy.
    ///
    /// Higher values ensure the popover appears above other UI elements.
    /// The default value (10000) should be sufficient for most use cases.
    var zIndex: Double { get set }
    
    // MARK: - Size Configuration
    
    /// The preferred width of the popover content, in points.
    ///
    /// If `nil`, the popover will size itself based on its content.
    /// Setting a specific width constrains the popover to that size,
    /// with text wrapping as needed.
    var width: CGFloat? { get set }
    
    /// The preferred height of the popover content, in points.
    ///
    /// If `nil`, the popover will size itself based on its content.
    /// Setting a specific height constrains the popover to that size.
    var height: CGFloat? { get set }

    // MARK: - Arrow Configuration
    
    /// Whether to display the pointing arrow on the popover.
    ///
    /// When `true`, an arrow points from the popover toward its target view.
    /// The arrow direction is determined by the `side` property.
    var showArrow: Bool { get set }
    
    /// The width of the popover arrow, in points.
    ///
    /// This affects the arrow's base width. The arrow shape is triangular,
    /// so this represents the width of the triangle's base.
    var arrowWidth: CGFloat { get set }
    
    /// The height of the popover arrow, in points.
    ///
    /// This affects how far the arrow extends from the popover body
    /// toward the target view.
    var arrowHeight: CGFloat { get set }
    
    /// The visual style of the popover arrow.
    ///
    /// Currently supports `.default` style, which renders a simple triangle.
    /// This property allows for future arrow style variations.
    var arrowType: PopoverArrowType { get set }
    
    // MARK: - Visual Style
    
    /// The visual theme type for the popover.
    ///
    /// This determines the popover's color scheme and overall appearance.
    /// Common values include `.blue` for informational popovers and
    /// `.dark` for high-contrast display.
    var type: PopoverType { get set }
    
    // MARK: - Theme-based Styling Methods
    
    /// Returns the border radius for the popover based on the current theme.
    ///
    /// - Parameter theme: The current `MPTheme` providing design system values.
    /// - Returns: The corner radius value in points.
    func borderRadius(from theme: MPTheme) -> CGFloat
    
    /// Returns the border width for the popover based on the current theme.
    ///
    /// - Parameter theme: The current `MPTheme` providing design system values.
    /// - Returns: The border width value in points, or 0 for no border.
    func borderWidth(from theme: MPTheme) -> CGFloat
    
    /// Returns the background color for the popover based on the current theme.
    ///
    /// - Parameter theme: The current `MPTheme` providing design system colors.
    /// - Returns: The `Color` to use for the popover background.
    func backgroundColor(from theme: MPTheme) -> Color
        
    /// Returns the content padding for the popover based on the current theme.
    ///
    /// - Parameter theme: The current `MPTheme` providing design system spacing values.
    /// - Returns: `EdgeInsets` defining the internal padding for popover content.
    func contentPadding(from theme: MPTheme) -> EdgeInsets
}
