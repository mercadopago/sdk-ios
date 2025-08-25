//
//  MPTextFieldStyle.swift
//  Public
//
//  Created by SDK on 20/08/25.
//

import SwiftUI
import MPFoundation

/// A style protocol for `MPTextField` enabling custom skins.
package protocol MPTextFieldStyle: StyleProtocol, Identifiable where Configuration == MPTextFieldStyleConfiguration {}

/// Default visual style for `MPTextField` using theme tokens.
package struct MPDefaultTextFieldStyle: MPTextFieldStyle {
    public var id: UUID = .init()
    @Environment(\.checkoutTheme) var theme: MPTheme
    
    private enum TextRole {
        case label, text, helper
    }

    public init() {}

    @MainActor
    public func makeBody(configuration: MPTextFieldStyleConfiguration) -> some View {
        VStack(alignment: .leading) {
            
            // Title
            if let label = configuration.label {
                label
                    .body
                    .font(theme.typography.body.small.regular)
                    .foregroundColor(textColor(state: configuration.state, role: .label))
                    .padding(.bottom, theme.spacings.xxs)
            }

            
            // Field
            HStack(spacing: theme.spacings.xs) {
                if let prefix = configuration.prefix {
                    prefix
                }
                
                configuration
                    .field
                    .font(theme.typography.body.medium.regular)
                    .foregroundColor(textColor(state: configuration.state, role: .text))
                
                if let suffix = configuration.suffix {
                    suffix
                }
            }
            .padding(theme.spacings.s)
            .background(backgroundColor(for: configuration.state, theme: theme))
            .overlay(
                RoundedRectangle(cornerRadius: theme.borderRadius.xs)
                    .stroke(
                        borderColor(
                            for: configuration.state
                        ),
                        lineWidth: borderWidth(for: configuration.state)
                    )
            )

            if let helper = configuration.helper, configuration.state.hasError {
                HStack(alignment: .center) {
                    Image(Logos.errorFilled, bundle: .bundleMP)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.red)

                    helper
                        .font(theme.typography.body.extraSmallSemibold)
                        .foregroundColor(textColor(state: configuration.state, role: .helper))
                }
            }
        }
        .animation(.easeInOut(duration: 0.15))
    }

    private func textColor(state: MPTextFieldState, role: TextRole) -> Color {
        switch (state, role) {
        case (.disabled, _):
            return theme.colors.textDisabled
        case (.readOnly, _):
            return role == .text ? theme.colors.textSecondary : theme.colors.textSecondary
        case (.error, .helper), (.focusError, .helper), (.error, .label), (.focusError, .label):
            return theme.colors.textNegative
        default:
            return theme.colors.textPrimary
        }
    }

    private func backgroundColor(for state: MPTextFieldState, theme: MPTheme) -> Color {
        switch state {
        case .readOnly:
            return theme.colors.backgroundSecondary
        case .disabled:
            return theme.colors.backgroundTertiary
        default:
            return theme.colors.backgroundPrimary
        }
    }

    private func borderColor(for state: MPTextFieldState) -> Color {
        switch state {
        case .error, .focusError:
            return theme.colors.feedbackNegative
        case .focused:
            return theme.colors.accent
        case .disabled:
            return theme.colors.outlineSecondary
        default:
            return theme.colors.outlinePrimary
        }
    }

    private func borderWidth(for state: MPTextFieldState) -> CGFloat {
        switch state {
        case .focused, .focusError:
            return theme.outline.xs
        default:
            return theme.outline.xxs
        }
    }
}

package extension MPTextFieldStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedMPTextfieldFieldStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedMPTextfieldFieldStyle<Style: MPTextFieldStyle>: View {
    let style: Style
    let configuration: Style.Configuration

    var body: some View {
        style
            .makeBody(configuration: configuration)
    }
}

package extension View {
    /// Sets the style for `MPTextField` within this view hierarchy.
    func mpTextFieldStyle<S: MPTextFieldStyle>(_ style: S) -> some View {
        environment(\.mpTextFieldStyle, style)
    }

}

private struct MPTextFieldStyleKey: @preconcurrency EnvironmentKey {
    @MainActor static var defaultValue: any MPTextFieldStyle = MPDefaultTextFieldStyle()
}

extension EnvironmentValues {
    var mpTextFieldStyle: any MPTextFieldStyle {
        get { self[MPTextFieldStyleKey.self] }
        set { self[MPTextFieldStyleKey.self] = newValue }
    }
}
