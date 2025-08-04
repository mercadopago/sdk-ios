//
//  RadioToggleStyle.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 31/07/25.
//
import SwiftUI
import MPFoundation

// MARK: - Radio Toggle Style

/// Custom ToggleStyle that renders a radio button with visual states
/// 
/// Usage example:
/// ```swift
/// Toggle("Option", isOn: $isSelected)
///     .toggleStyle(.radio)
///     .disabled(false)
///     .hasError(false)
/// ```
package struct RadioToggleStyle: ToggleStyle {
    @Environment(\.checkoutTheme) var theme: MPTheme
    
    @Environment(\.isEnabled) private var isEnabled: Bool
    @Environment(\.hasError) private var hasError: Bool
    
    package func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            Button(action: {
                if isEnabled {
                    configuration.isOn.toggle()
                }
            }) {
                Circle()
                    .stroke(
                        strokeColor(isOn: configuration.isOn),
                        lineWidth: 2
                    )
                    .frame(width: 16, height: 16)
                    .overlay(
                        Circle()
                            .fill(
                                fillColor(
                                    isOn: configuration.isOn
                                )
                            )
                            .frame(width: 9, height: 9)
                            .opacity(
                                configuration.isOn ? 1 : 0
                            )
                    )
            }
            .buttonStyle(PlainButtonStyle())
            
            configuration.label
                .opacity(!isEnabled ? 0.6 : 1.0)
        }
    }
    
    private func strokeColor(isOn: Bool) -> Color {
        if !isEnabled {
            return theme.colors.textDisabled
        }

        if hasError {
            return theme.colors.textNegative
        }

        return isOn ? theme.colors.accent : theme.colors.textSecondary
    }

    /// Returns the inner fill color based on state
    private func fillColor(isOn: Bool) -> Color {
        if !isEnabled {
            return theme.colors.textDisabled
        }

        if hasError {
            return theme.colors.textNegative
        }

        return theme.colors.accent
    }
}

// MARK: - Extension

/// Convenience extension to use RadioToggleStyle
package extension ToggleStyle where Self == RadioToggleStyle {
    static var radio: Self { Self() }
}


#Preview {
    Toggle("Label", isOn: .constant(true))
        .toggleStyle(.radio)
}


