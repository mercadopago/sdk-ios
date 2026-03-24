//
//  Focused+Compatible13.swift
//  MercadoPagoSDK
//
//  Created by MercadoPago on 23/03/26.
//

import SwiftUI

extension View {
    func mpFocused(_ isFocused: Binding<Bool>) -> some View {
        modifier(FocusedModifier(isFocused: isFocused))
    }
}

// MARK: - ViewModifier

private struct FocusedModifier: ViewModifier {
    @Binding var isFocused: Bool

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            FocusedWrappedView(isFocused: self.$isFocused, content: content)
        }
    }
}

// MARK: - iOS 15+ wrapper

@available(iOS 15.0, *)
private struct FocusedWrappedView<Content: View>: View {
    @Binding var isFocused: Bool
    @FocusState private var internalFocus: Bool
    let content: Content

    var body: some View {
        if #available(iOS 17.0, *) {
            self.content
                .focused(self.$internalFocus)
                .onChange(of: self.isFocused) { _, newValue in self.internalFocus = newValue }
                .onChange(of: self.internalFocus) { _, newValue in self.isFocused = newValue }
        } else {
            self.content
                .focused(self.$internalFocus)
                .onChange(of: self.isFocused) { newValue in self.internalFocus = newValue }
                .onChange(of: self.internalFocus) { newValue in self.isFocused = newValue }
        }
    }
}
