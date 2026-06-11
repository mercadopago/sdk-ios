//
//  AccessibilityIDPrefix.swift
//  MPComponents
//
import SwiftUI

private struct AccessibilityIDPrefixKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

package extension EnvironmentValues {
    /// Identifier prefix applied by MP components to their main element
    /// (sub-elements derive ids by appending a role, e.g. `"\(prefix).tooltip"`).
    var accessibilityIDPrefix: String? {
        get { self[AccessibilityIDPrefixKey.self] }
        set { self[AccessibilityIDPrefixKey.self] = newValue }
    }
}

package extension View {
    /// Sets the accessibility-identifier prefix for the nearest component.
    func accessibilityIDPrefix(_ prefix: String) -> some View {
        environment(\.accessibilityIDPrefix, prefix)
    }
}
