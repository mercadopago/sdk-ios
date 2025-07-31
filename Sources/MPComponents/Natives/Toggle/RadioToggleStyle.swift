//
//  RadioToggleStyle.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 31/07/25.
//
import SwiftUI
import MPFoundation

// MARK: - Radio Button State

/// Available visual states for the radio button
package enum RadioButtonState {
    /// Normal state - allows interaction
    case idle
    /// Disabled state - does not allow interaction
    case disabled
    /// Error state - indicates validation failed
    case error
}

// MARK: - Radio Toggle Style

/// Custom ToggleStyle that renders a radio button with visual states
/// 
/// Usage example:
/// ```swift
/// Toggle("Option", isOn: $isSelected)
///     .toggleStyle(.radio(state: .idle))
/// ```
package struct RadioToggleStyle: ToggleStyle {
    @Environment(\.checkoutTheme) var theme: MPTheme
    
    /// Current visual state of the radio button
    private let state: RadioButtonState
    
    /// Initializes the style with a specific state
    /// - Parameter state: Visual state of the radio button (default: .idle)
    package init(state: RadioButtonState = .idle) {
        self.state = state
    }
    
    package func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            Button(action: {
                if state != .disabled {
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
                        // Inner circle filled when selected
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
            .disabled(state == .disabled)
            
            configuration.label
                .opacity(state == .disabled ? 0.6 : 1.0)
        }
    }
    
    // MARK: - Private Methods
    
    /// Returns the border color based on state and selection
    private func strokeColor(isOn: Bool) -> Color {
        switch state {
        case .idle:
            return isOn ? theme.colors.accent : theme.colors.textSecondary
        case .disabled:
            return theme.colors.textDisabled
        case .error:
            return theme.colors.textNegative
        }
    }
    
    /// Returns the inner fill color based on state
    private func fillColor(isOn: Bool) -> Color {
        switch state {
        case .idle:
            return theme.colors.accent
        case .disabled:
            return theme.colors.textDisabled
        case .error:
            return theme.colors.textNegative
        }
    }
}

// MARK: - Extension

/// Convenience extension to use RadioToggleStyle
package extension ToggleStyle where Self == RadioToggleStyle {
    /// Radio button with idle state (default)
    static var radio: Self { Self() }
    
    /// Radio button with specific state
    /// - Parameter state: Desired visual state
    static func radio(state: RadioButtonState) -> Self { Self(state: state) }
}
