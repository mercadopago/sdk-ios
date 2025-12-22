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
        let appearance = theme.textFields.standard
        
        VStack(alignment: .leading) {
            
            // Title
            if let label = configuration.label {
                label
                    .body
                    .font(theme.typography.body.small.regular)
                    .foregroundColor(labelColor(state: configuration.state, appearance: appearance))
                    .padding(.bottom, theme.spacings.xnano)
            }

            
            // Field
            HStack(spacing: 0) {
                configuration.prefix
                    .frame(maxHeight: .infinity)
               
                configuration
                    .field
                    .font(theme.typography.body.medium.regular)
                    .foregroundColor(textColor(state: configuration.state, appearance: appearance))
                    .padding(theme.spacings.micro)

                
                configuration.suffix
                    .frame(maxHeight: .infinity)
            }
            .background(backgroundColor(for: configuration.state, appearance: appearance))
            .cornerRadius(appearance.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: appearance.cornerRadius)
                    .stroke(
                        borderColor(for: configuration.state, appearance: appearance),
                        lineWidth: borderWidth(for: configuration.state, appearance: appearance)
                    )
            )

            if let helper = configuration.helper, configuration.state.hasError {
                HStack(alignment: .center) {
                    Image(Logos.errorFilled, bundle: .bundleMP)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundColor(appearance.helperColorError)

                    helper
                        .font(theme.typography.body.extraSmallSemibold)
                        .foregroundColor(appearance.helperColorError)
                }
            }
        }
        .animation(.easeInOut(duration: 0.15))
    }

    private func labelColor(state: MPTextFieldState, appearance: MPTextFieldAppearance) -> Color {
        switch state {
        case .disabled:
            return appearance.labelColorDisabled
        case .error, .focusError:
            return appearance.labelColorError
        default:
            return appearance.labelColor
        }
    }

    private func textColor(state: MPTextFieldState, appearance: MPTextFieldAppearance) -> Color {
        switch state {
        case .disabled:
            return appearance.textColorDisabled
        case .readOnly:
            return appearance.textColorReadOnly
        default:
            return appearance.textColor
        }
    }

    private func backgroundColor(for state: MPTextFieldState, appearance: MPTextFieldAppearance) -> Color {
        switch state {
        case .readOnly:
            return appearance.backgroundColorReadOnly
        case .disabled:
            return appearance.backgroundColorDisabled
        case .error, .focusError:
            return appearance.backgroundColorError
        case .focused:
            return appearance.backgroundColorFocused
        default:
            return appearance.backgroundColor
        }
    }

    private func borderColor(for state: MPTextFieldState, appearance: MPTextFieldAppearance) -> Color {
        switch state {
        case .error, .focusError:
            return appearance.borderColorError
        case .focused:
            return appearance.borderColorFocused
        case .disabled:
            return appearance.borderColorDisabled
        default:
            return appearance.borderColor
        }
    }

    private func borderWidth(for state: MPTextFieldState, appearance: MPTextFieldAppearance) -> CGFloat {
        switch state {
        case .focused, .focusError:
            return appearance.borderWidthFocused
        default:
            return appearance.borderWidth
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
