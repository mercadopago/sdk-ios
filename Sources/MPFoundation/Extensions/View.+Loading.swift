//
//  View.+Loading.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 22/12/25.
//
import SwiftUI

package extension EnvironmentValues {
    var isLoading: Bool {
        get { self[LoadingKey.self] }
        set { self[LoadingKey.self] = newValue }
    }
}

package extension View {
    /// Marks the compoent as loading state via environment.
    func isLoading(_ isLoading: Bool) -> some View {
        environment(\.isLoading, isLoading)
    }
}

private struct LoadingKey: EnvironmentKey {
    static let defaultValue = false
}
