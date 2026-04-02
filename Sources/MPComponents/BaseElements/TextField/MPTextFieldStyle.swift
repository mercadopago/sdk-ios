//
//  MPTextFieldStyle.swift
//  Public
//
//  Created by SDK on 20/08/25.
//

import MPFoundation
import SwiftUI

/// A style protocol for `MPTextField` enabling custom skins.
package protocol MPTextFieldStyle: StyleProtocol, Identifiable where Configuration == MPTextFieldStyleConfiguration {}

/// Default visual style for `MPTextField` using theme appearance tokens.
package struct MPDefaultTextFieldStyle: MPTextFieldStyle {
    public var id: UUID = .init()
    @Environment(\.checkoutTheme) var theme: MPTheme

    @State private var isPopoverPresented = false

    /// Returns the appearance configuration for the TextField.
    private var appearance: MPTextFieldAppearance {
        self.theme.textFields.standard
    }

    public init() {}

    @MainActor
    public func makeBody(configuration: MPTextFieldStyleConfiguration) -> some View {
        let stateAppearance = self.appearance(for: configuration.state)

        VStack(alignment: .leading) {
            // Label
            if let label = configuration.label {
                self.labelContent(
                    label: label,
                    popoverText: configuration.popoverText,
                    appearance: self.appearance,
                    stateAppearance: stateAppearance
                )
            }

            // Field
            HStack(spacing: 0) {
                configuration.prefix
                    .frame(maxHeight: .infinity)

                configuration
                    .field
                    .font(self.appearance.textFont.toFont())
                    .foregroundColor(stateAppearance.textColor)
                    .padding(self.appearance.padding)

                configuration.suffix
                    .frame(maxHeight: .infinity)
            }
            .frame(height: 48)
            .background(stateAppearance.backgroundColor)
            .cornerRadius(self.appearance.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: self.appearance.cornerRadius)
                    .stroke(
                        stateAppearance.borderColor,
                        lineWidth: stateAppearance.borderWidth
                    )
            )

            // Helper text
            if let helper = configuration.helper {
                Helper(helper, self.helperTone(for: configuration))
                    .helperStyle(self.helperStyle(for: configuration))
                    .padding(.top, self.theme.spacings.paddings.xnano)
            }
        }
        .animation(.easeInOut(duration: 0.15))
    }

    @MainActor
    private func labelContent(
        label: MPTextFieldStyleConfiguration.Label,
        popoverText: String?,
        appearance: MPTextFieldAppearance,
        stateAppearance: MPTextFieldStateAppearance
    ) -> some View {
        HStack {
            label
                .body
                .font(appearance.labelFont.toFont())
                .foregroundColor(stateAppearance.labelColor)

            if let popoverText {
                self.popoverButton(textPopover: popoverText)
            }
        }
    }

    @MainActor
    private func popoverButton(textPopover: String) -> some View {
        Button(action: {
            self.isPopoverPresented = true
        }) {
            MPIcon(
                systemName: Logos.questionMark,
                size: .small,
                color: .accent,
                isDecorative: true
            )
        }
        .accessibility(label: Text(MPStrings.Common.Accessibility.TextField.moreInfo))
        .buttonStyle(.plain)
        .popover(isPresented: self.$isPopoverPresented) {
            Text(textPopover)
                .textStyle(.bodyMedium(colorType: .secondary))
        }
    }

    /// Returns the state-specific appearance for a given TextField state.
    private func appearance(for state: MPTextFieldState) -> MPTextFieldStateAppearance {
        switch state {
        case .idle:
            return self.appearance.idle
        case .focused:
            return self.appearance.focused
        case .error:
            return self.appearance.error
        case .focusError:
            return self.appearance.focusError
        case .readOnly:
            return self.appearance.readOnly
        case .disabled:
            return self.appearance.disabled
        }
    }

    private func helperTone(for config: MPTextFieldStyleConfiguration) -> HelperTone {
        switch config.state {
        case .focusError, .error:
            return .negative
        default:
            return .none
        }
    }

    private func helperStyle(for config: MPTextFieldStyleConfiguration) -> HelperDefaultStyle {
        switch config.state {
        case .focusError, .error:
            return .loud()
        default:
            return .quiet()
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
        self.style
            .makeBody(configuration: self.configuration)
    }
}

package extension View {
    /// Sets the style for `MPTextField` within this view hierarchy.
    func mpTextFieldStyle(_ style: some MPTextFieldStyle) -> some View {
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
