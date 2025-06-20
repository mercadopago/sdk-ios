//
//  ThemeProvider.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 11/06/25.
//
import SwiftUI

/// A SwiftUI view that injects a visual theme (`Theme`) into the environment based on the system color scheme.
///
/// Use `ThemeProvider` to wrap your app or specific view hierarchies and enable access to the current theme
/// via `@Environment(\.MPTheme)`. It automatically switches between light and dark theme variants.
@MainActor
package struct ThemeProvider<Content: View>: View {

    /// Reads the system color scheme (light or dark).
    @Environment(\.colorScheme) var colorScheme

    /// The theme used when the system is in light mode.
    private let lightTheme: MPTheme

    /// The theme used when the system is in dark mode.
    private let darkTheme: MPTheme

    private let style: UserInterfaceStyle

    /// The content view to wrap in the themed environment.
    private let content: () -> Content
    

    /// Initializes a `ThemeProvider` with optional light and dark themes.
    ///
    /// - Parameters:
    ///   - light: The theme to apply in light mode. Defaults to `MPLightTheme`.
    ///   - dark: The theme to apply in dark mode. Defaults to `MPLightTheme`.
    ///   - content: The root view that will inherit the themed environment.
    package init(
        light: MPTheme,
        dark: MPTheme,
        style: UserInterfaceStyle = .automatic,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.lightTheme = light
        self.darkTheme = dark
        self.style = style
        self.content = content
    }
  
    /// The view body that injects the current theme into the environment
    /// based on the active color scheme.
    package var body: some View {

        return content()
          .environment(\.checkoutTheme, currentTheme)
          .preferredColorScheme(resolvedColorScheme)
          .animation(.easeInOut, value: colorScheme)
          .loadMPFonts()
    }
    
    private var currentTheme: MPTheme {
        switch style {
        case .lightMode:
            return lightTheme
        case .darkMode:
            return darkTheme
        case .automatic:
            return (colorScheme == .dark) ? darkTheme : lightTheme
        }
    }

    private var resolvedColorScheme: ColorScheme? {
        switch style {
        case .lightMode:
            return .light
        case .darkMode:
            return .dark
        case .automatic:
            return nil
        }
    }
}


package struct CheckoutThemeKey: @preconcurrency EnvironmentKey {
    @MainActor
    package static let defaultValue: MPTheme = MPLightTheme()
}


package extension EnvironmentValues {
    
    /// The current `CheckoutThemeKey` instance injected into the environment.
    ///
    /// This is used by all  components to access colors, shapes, typography, and spacing.
    ///
    /// Set by wrapping your app or view in a `ThemeProvider`.
    var checkoutTheme: MPTheme {
        get { self[CheckoutThemeKey.self] }
        set { self[CheckoutThemeKey.self] = newValue }
    }
}
