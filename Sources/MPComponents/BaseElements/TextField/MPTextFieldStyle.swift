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

/// Default visual style for `MPTextField` using theme appearance tokens.
package struct MPDefaultTextFieldStyle: MPTextFieldStyle {
    public var id: UUID = .init()
    @Environment(\.checkoutTheme) var theme: MPTheme
    
    /// Returns the appearance configuration for the TextField.
    private var appearance: MPTextFieldAppearance {
        theme.textFields.standard
    }

    public init() {}

    @MainActor
    public func makeBody(configuration: MPTextFieldStyleConfiguration) -> some View {
        let stateAppearance = appearance(for: configuration.state)
        
        VStack(alignment: .leading) {
            
            // Label
            if let label = configuration.label {
                label
                    .body
                    .font(appearance.labelFont.toFont())
                    .foregroundColor(stateAppearance.labelColor)
            }

            // Field
            HStack(spacing: 0) {
                configuration.prefix
                    .frame(maxHeight: .infinity)
               
                configuration
                    .field
                    .font(appearance.textFont.toFont())
                    .foregroundColor(stateAppearance.textColor)
                    .padding(appearance.padding)

                configuration.suffix
                    .frame(maxHeight: .infinity)
            }
            .background(stateAppearance.backgroundColor)
            .cornerRadius(appearance.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: appearance.cornerRadius)
                    .stroke(
                        stateAppearance.borderColor,
                        lineWidth: stateAppearance.borderWidth
                    )
            )
            .frame(maxHeight: 44)

            // Helper text (shown on error states)
            if let helper = configuration.helper {
                HStack(alignment: .center) {
                    if configuration.state.hasError {
                        Image(Logos.errorFilled, bundle: .bundleMP)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundColor(stateAppearance.helperColor)
                    }

                    helper
                        .font(appearance.helperFont.toFont())
                        .foregroundColor(stateAppearance.helperColor)
                    
                }
                .padding(.top, theme.spacings.xnano)
            }
        }
        .animation(.easeInOut(duration: 0.15))
    }

    /// Returns the state-specific appearance for a given TextField state.
    private func appearance(for state: MPTextFieldState) -> MPTextFieldStateAppearance {
        print(state)
        print(appearance.focused.borderWidth)

        switch state {
        case .idle:
            return appearance.idle
        case .focused:
            return appearance.focused
        case .error:
            return appearance.error
        case .focusError:
            return appearance.focusError
        case .readOnly:
            return appearance.readOnly
        case .disabled:
            return appearance.disabled
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
