//
//  MPCheckoutAppearance.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 09/06/25.
//

import MPFoundation

/// Visual appearance settings for the checkout flow.
///
/// Controls which color scheme is applied and provides the theme configuration
/// for light and dark modes via ``Configuration``.
public struct MPCheckoutAppearance: Sendable {
    /// The preferred user interface style for the checkout flow.
    ///
    /// Defaults to `.automatic`, which follows the device setting.
    public var style: MercadoPagoUserInterfaceStyle

    /// The theme configuration holding light and dark mode themes.
    public var themeConfiguration: Configuration

    /// Creates a new appearance configuration.
    ///
    /// - Parameters:
    ///   - style: The preferred user interface style. Defaults to `.automatic`.
    ///   - theme: The theme configuration for light and dark modes.
    @MainActor
    public init(
        style: MercadoPagoUserInterfaceStyle = .automatic,
        theme: Configuration = Configuration()
    ) {
        self.style = style
        self.themeConfiguration = theme
    }

    /// Theme configuration for the checkout flow.
    ///
    /// Holds the ``MPTheme`` instances used in light and dark modes.
    public struct Configuration: Sendable {
        /// The theme applied when the interface is in light mode.
        public var light: MPTheme

        /// The theme applied when the interface is in dark mode.
        public var dark: MPTheme

        /// Creates a new theme configuration.
        ///
        /// - Parameters:
        ///   - light: The theme for light mode. Defaults to `MPLightTheme` when `nil`.
        ///   - dark: The theme for dark mode. Defaults to `MPLightTheme` when `nil`.
        @MainActor
        public init(
            light: MPTheme? = nil,
            dark: MPTheme? = nil
        ) {
            self.light = light ?? MPLightTheme()
            self.dark = dark ?? MPLightTheme()
        }
    }
}
