//
//  View+Popover.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 08/09/25.
//

import SwiftUI

/// Extensions for adding popover functionality to SwiftUI views.
///
/// These extensions provide convenient methods for attaching popovers to any SwiftUI view.
/// The popover system supports various configuration options, positioning, theming, and animations.
package extension View {
    // MARK: - Basic Popover Methods
    
    /// Adds a popover with default configuration to the view.
    ///
    /// This is the simplest way to add a popover. It uses standard defaults for positioning
    /// (top), theming (blue), and behavior (no animation, with arrow).
    ///
    /// - Parameters:
    ///   - content: A view builder that creates the popover's content.
    /// - Returns: The modified view with popover functionality.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    ///
    /// Button("Info") {
    ///
    /// }
    /// .popover() {
    ///     Text("This provides additional information")
    ///         .foregroundColor(.white)
    /// }
    /// ```
    func popover<PopoverContent: View>(
        isPopoverEnabled: Binding<Bool>,
        @ViewBuilder content: @escaping () -> PopoverContent
    ) -> some View {
        let config: PopoverConfig = DefaultPopoverConfig()
        return modifier(PopoverModifier(isPopoverEnabled: isPopoverEnabled, config: config, content: content))
    }

    /// Adds a popover with custom configuration to the view.
    ///
    /// Use this method when you need full control over popover appearance and behavior.
    /// You can provide any custom configuration that conforms to `PopoverConfig`.
    ///
    /// - Parameters:
    ///   - config: A custom configuration object defining popover behavior and appearance.
    ///   - content: A view builder that creates the popover's content.
    /// - Returns: The modified view with popover functionality.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// @State private var showPopover = false
    /// 
    /// var customConfig = DefaultPopoverConfig()
    /// customConfig.enableAnimation = true
    /// customConfig.showArrow = false
    /// 
    /// Image(systemName: "info.circle")
    ///     .popover(config: customConfig) {
    ///         VStack {
    ///             Text("Custom Popover")
    ///                 .font(.headline)
    ///             Text("With advanced configuration")
    ///                 .font(.caption)
    ///         }
    ///         .foregroundColor(.white)
    ///     }
    /// ```
    func popover<PopoverContent: View>(
        isPopoverEnabled: Binding<Bool>,
        config: PopoverConfig,
        @ViewBuilder content: @escaping () -> PopoverContent
    ) -> some View {
        modifier(PopoverModifier(isPopoverEnabled: isPopoverEnabled, config: config, content: content))
    }

    /// Adds a popover with specific positioning and theming to the view.
    ///
    /// This is a convenient middle-ground method that allows you to specify the most
    /// common customizations (positioning and theme) without creating a full configuration.
    ///
    /// - Parameters:
    ///   - type: The visual theme type for the popover. Defaults to `.blue`.
    ///   - content: A view builder that creates the popover's content.
    /// - Returns: The modified view with popover functionality.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// @State private var showPopover = false
    /// 
    /// Text("Hover target")
    ///     .popover(type: .dark) {
    ///         Text("This popover appears below with dark theme")
    ///             .foregroundColor(.white)
    ///     }
    ///     .onTapGesture {
    ///         showPopover.toggle()
    ///     }
    /// ```
    func popover<PopoverContent: View>(
        isPopoverEnabled: Binding<Bool>,
        type: PopoverType = .white,
        @ViewBuilder content: @escaping () -> PopoverContent
    ) -> some View {
        var config: PopoverConfig = DefaultPopoverConfig()
        config.type = type

        return modifier(PopoverModifier(isPopoverEnabled: isPopoverEnabled, config: config, content: content))
    }
}
