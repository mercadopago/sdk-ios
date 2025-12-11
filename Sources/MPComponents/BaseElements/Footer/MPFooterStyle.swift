//
//  MPFooterStyle.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 24/11/25.
//
import SwiftUI
import MPFoundation

/// A style protocol for `MPFooter` enabling custom skins.
package protocol MPFooterStyle: StyleProtocol, Identifiable where Configuration == MPFooterStyleConfiguration {}

/// Default visual style for `MPFooter` using theme tokens.
package struct MPDefaultFooterStyle: MPFooterStyle {
    package var id: UUID = .init()
    
    @Environment(\.checkoutTheme) var theme: MPTheme
    
    package init() {}
    
    @MainActor
    package func makeBody(configuration: MPFooterStyleConfiguration) -> some View {
        VStack(spacing: 0) {
            // Content area
            VStack(spacing: theme.spacings.xs) {
                // Summary line
                configuration.summaryLine
                    .padding(.horizontal, theme.spacings.m)
                    .padding(.top, theme.spacings.m)
                
                // Description line (if present)
                if configuration.hasDescription {
                    configuration.descriptionLine
                        .padding(.horizontal, theme.spacings.m)
                        .padding(.bottom, theme.spacings.m)
                } else {
                    Color.clear
                        .frame(height: theme.spacings.m)
                }
            }
            .background(theme.colors.backgroundPrimary)
            .background(
            theme.colors.backgroundPrimary
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: 8, x: 0, y: -4
                )
                .mask(
                    Rectangle()
                        .padding(.top, -20)
                )
            )
        }
    }
}

// MARK: - Style Resolution
package extension MPFooterStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedMPFooterStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedMPFooterStyle<Style: MPFooterStyle>: View {
    let style: Style
    let configuration: Style.Configuration
    
    var body: some View {
        style.makeBody(configuration: configuration)
    }
}

// MARK: - Environment
private struct MPFooterStyleKey: @preconcurrency EnvironmentKey {
    @MainActor
    static var defaultValue: any MPFooterStyle = MPDefaultFooterStyle()
}

extension EnvironmentValues {
    var mpFooterStyle: any MPFooterStyle {
        get { self[MPFooterStyleKey.self] }
        set { self[MPFooterStyleKey.self] = newValue }
    }
}

package extension View {
    /// Sets the style for `MPFooter` within this view hierarchy.
    ///
    /// - Parameter style: The `MPFooterStyle` to apply.
    func mpFooterStyle<S: MPFooterStyle>(_ style: S) -> some View {
        environment(\.mpFooterStyle, style)
    }
}
