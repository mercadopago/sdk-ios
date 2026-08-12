//
//  View+ReadOnly.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 21/08/25.
//
import SwiftUI

package extension EnvironmentValues {
    var isReadOnly: Bool {
        get { self[ReadOnlyKey.self] }
        set { self[ReadOnlyKey.self] = newValue }
    }
}

package extension View {
    /// Marks the field as read-only via environment.
    func readOnly(_ isReadOnly: Bool) -> some View {
        environment(\.isReadOnly, isReadOnly)
    }
}

private struct ReadOnlyKey: EnvironmentKey {
    static let defaultValue: Bool = false
}
