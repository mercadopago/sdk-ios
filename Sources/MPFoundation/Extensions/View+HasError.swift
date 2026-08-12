//
//  View+HasError.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 01/08/25.
//
import SwiftUI

/// Environment key for error state
private struct ErrorStateKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

/// Extension to add error state to environment
package extension EnvironmentValues {
    /// Current error state from environment
    var hasError: Bool {
        get { self[ErrorStateKey.self] }
        set { self[ErrorStateKey.self] = newValue }
    }
}

/// View modifier for error state
package extension View {
    /// Applies error state to the view
    /// - Parameter hasError: Whether the view should display error state
    /// - Returns: Modified view with error state applied
    func hasError(_ hasError: Bool) -> some View {
        environment(\.hasError, hasError)
    }
}
