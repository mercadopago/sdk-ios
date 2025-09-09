//
//  View+Tooltip.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 08/09/25.
//

import SwiftUI

/// Extensions for adding tooltip functionality to SwiftUI views.
///
/// These extensions provide convenient methods for attaching tooltips to any SwiftUI view.
/// The tooltip system supports various configuration options, positioning, theming, and animations.
package extension View {
    // MARK: - Basic Tooltip Methods
    
    /// Adds a tooltip with default configuration to the view.
    ///
    /// This is the simplest way to add a tooltip. It uses standard defaults for positioning
    /// (top), theming (blue), and behavior (no animation, with arrow).
    ///
    /// - Parameters:
    ///   - content: A view builder that creates the tooltip's content.
    /// - Returns: The modified view with tooltip functionality.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    ///
    /// Button("Info") {
    ///
    /// }
    /// .tooltip() {
    ///     Text("This provides additional information")
    ///         .foregroundColor(.white)
    /// }
    /// ```
    func tooltip<TooltipContent: View>(
        @ViewBuilder content: @escaping () -> TooltipContent
    ) -> some View {
        let config: TooltipConfig = DefaultTooltipConfig()
        return modifier(TooltipModifier(config: config, content: content))
    }

    /// Adds a tooltip with custom configuration to the view.
    ///
    /// Use this method when you need full control over tooltip appearance and behavior.
    /// You can provide any custom configuration that conforms to `TooltipConfig`.
    ///
    /// - Parameters:
    ///   - config: A custom configuration object defining tooltip behavior and appearance.
    ///   - content: A view builder that creates the tooltip's content.
    /// - Returns: The modified view with tooltip functionality.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// @State private var showTooltip = false
    /// 
    /// var customConfig = DefaultTooltipConfig()
    /// customConfig.enableAnimation = true
    /// customConfig.showArrow = false
    /// 
    /// Image(systemName: "info.circle")
    ///     .tooltip(config: customConfig) {
    ///         VStack {
    ///             Text("Custom Tooltip")
    ///                 .font(.headline)
    ///             Text("With advanced configuration")
    ///                 .font(.caption)
    ///         }
    ///         .foregroundColor(.white)
    ///     }
    /// ```
    func tooltip<TooltipContent: View>(
        config: TooltipConfig,
        @ViewBuilder content: @escaping () -> TooltipContent
    ) -> some View {
        modifier(TooltipModifier(config: config, content: content))
    }

    /// Adds a tooltip with specific positioning and theming to the view.
    ///
    /// This is a convenient middle-ground method that allows you to specify the most
    /// common customizations (positioning and theme) without creating a full configuration.
    ///
    /// - Parameters:
    ///   - type: The visual theme type for the tooltip. Defaults to `.blue`.
    ///   - content: A view builder that creates the tooltip's content.
    /// - Returns: The modified view with tooltip functionality.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// @State private var showTooltip = false
    /// 
    /// Text("Hover target")
    ///     .tooltip(type: .dark) {
    ///         Text("This tooltip appears below with dark theme")
    ///             .foregroundColor(.white)
    ///     }
    ///     .onTapGesture {
    ///         showTooltip.toggle()
    ///     }
    /// ```
    func tooltip<TooltipContent: View>(
        type: TooltipType = .blue,
        @ViewBuilder content: @escaping () -> TooltipContent
    ) -> some View {
        var config: TooltipConfig = DefaultTooltipConfig()
        config.type = type

        return modifier(TooltipModifier(config: config, content: content))
    }
}
