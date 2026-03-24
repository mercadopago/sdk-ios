//
//  MPFooterStyle.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 24/11/25.
//
import MPFoundation
import SwiftUI

/// A style protocol for `MPFooter` enabling custom skins.
package protocol MPFooterStyle: StyleProtocol, Identifiable where Configuration == MPFooterStyleConfiguration {}

/// Default visual style for `MPFooter` using theme tokens.
package struct MPDefaultFooterStyle: MPFooterStyle {
    package var id: UUID = .init()

    @Environment(\.checkoutTheme) var theme: MPTheme
    @Environment(\.isEnabled) private var isEnabled: Bool
    @Environment(\.mpHeaderIsScrollable) private var isScrollable: Bool

    package init() {}

    @MainActor
    package func makeBody(configuration: MPFooterStyleConfiguration) -> some View {
        if self.isEnabled {
            VStack(spacing: 0) {
                // Content area
                VStack(spacing: self.theme.spacings.xmicro) {
                    // Summary line
                    configuration.summaryLine
                        .padding(.top, self.theme.spacings.xtiny)

                    // Description line (if present)
                    if configuration.hasDescription {
                        configuration.descriptionLine
                    } else {
                        Color.clear
                            .frame(height: self.theme.spacings.xtiny)
                    }

                    if let button = configuration.button {
                        button
                            .mpButtonStyle(variant: .loud)
                            .padding(.top, configuration.hasDescription ? self.theme.spacings.micro : 0)
                            .padding(.bottom, self.theme.spacings.xtiny)
                    }
                }
                .padding(.horizontal, self.theme.spacings.xtiny)
                .background(self.theme.colors.background.primary)
                .background(
                    self.theme.colors.background.primary
                        .shadow(
                            color: self.isScrollable ? Color.black.opacity(0.1) : .clear,
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
        self.style.makeBody(configuration: self.configuration)
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
    func mpFooterStyle(_ style: some MPFooterStyle) -> some View {
        environment(\.mpFooterStyle, style)
    }
}
