//
//  View+Popover.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 08/09/25.
//

import SwiftUI

package extension View {
    // MARK: - With explicit isPresented binding

    // The caller controls when the popover opens — the trigger view's action toggles isPresented.

    func popover(
        config: PopoverConfig,
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        modifier(PopoverModifier(config: config, isPresented: isPresented, content: content))
    }

    func popover(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        modifier(PopoverModifier(config: DefaultPopoverConfig(), isPresented: isPresented, content: content))
    }

    // MARK: - Convenience (no binding) — wraps in a tap-aware container

    func popover(
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        _MPPopoverTapContainer(trigger: self, config: DefaultPopoverConfig(), popoverContent: content)
    }

    func popover(
        config: PopoverConfig,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        _MPPopoverTapContainer(trigger: self, config: config, popoverContent: content)
    }
}

// MARK: - _MPPopoverTapContainer

// Owns the @State for isPresented and handles the tap — the trigger's action opens the popover.

private struct _MPPopoverTapContainer<Trigger: View, PopoverContent: View>: View {
    @State private var isPresented = false
    let trigger: Trigger
    let config: PopoverConfig
    let popoverContent: () -> PopoverContent

    var body: some View {
        self.trigger
            .contentShape(Rectangle())
            .onTapGesture { self.isPresented = true }
            .modifier(PopoverModifier(config: self.config, isPresented: self.$isPresented, content: self.popoverContent))
    }
}
