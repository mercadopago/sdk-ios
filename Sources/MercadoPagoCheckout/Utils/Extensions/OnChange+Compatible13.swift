//
//  OnChange+Compatible13.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 24/02/26.
//

import SwiftUI
import Combine

extension View {
    @_disfavoredOverload
    @usableFromInline
    func mpOnChange<V: Equatable>(
        of value: V,
        perform action: @escaping (V) -> Void
    ) -> some View {
        modifier(OnChangeModifier(value: value, action: action))
    }
}

struct OnChangeModifier<V: Equatable>: ViewModifier {
    let value: V
    let action: (V) -> Void
    @State private var previous: V

    init(value: V, action: @escaping (V) -> Void) {
        self.value = value
        self.action = action
        self._previous = State(initialValue: value)
    }

    func body(content: Content) -> some View {
        if #available(iOS 14.0, *) {
            content.onChange(of: value, perform: action)
        } else {
            content.onReceive(Just(value)) { newValue in
                if newValue != previous {
                    previous = newValue
                    action(newValue)
                }
            }
        }
    }
}
