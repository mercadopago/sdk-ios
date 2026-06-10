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
    @Environment(\.mpHeaderIsScrollable) private var isScrollable: Bool
    @State private var isKeyboardVisible = false

    package init() {}

    @MainActor
    package func makeBody(configuration: MPFooterStyleConfiguration) -> some View {
        VStack(spacing: 0) {
            VStack(spacing: self.theme.spacings.xmicro) {
                if !self.isKeyboardVisible {
                    configuration.summaryLine

                    if configuration.hasDescription {
                        configuration.descriptionLine
                    }
                }

                if let button = configuration.button {
                    button
                        .mpButtonStyle(variant: .loud)
                        .padding(.top, (!self.isKeyboardVisible && configuration.hasDescription) ? self.theme.spacings.micro : 0)
                        .padding(.bottom, self.theme.spacings.xtiny)
                }
            }
            .padding(.horizontal, self.theme.spacings.xtiny)
            .padding(.top, self.theme.spacings.xtiny)
            .background(self.theme.colors.background.primary)
            .background(
                self.theme.colors.background.primary
                    .shadow(
                        color: self.isScrollable ? Color.black.opacity(0.1) : .clear,
                        radius: 4, x: 0, y: -2
                    )
                    .mask(
                        Rectangle()
                            .padding(.top, -20)
                    )
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            self.isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            self.isKeyboardVisible = false
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
