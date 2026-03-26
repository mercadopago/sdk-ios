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

    func popover<PopoverContent: View>(
        config: PopoverConfig,
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> PopoverContent
    ) -> some View {
        modifier(PopoverModifier(config: config, isPresented: isPresented, content: content))
    }

    func popover<PopoverContent: View>(
        type: PopoverType = .white,
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> PopoverContent
    ) -> some View {
        var config: PopoverConfig = DefaultPopoverConfig()
        config.type = type
        return modifier(PopoverModifier(config: config, isPresented: isPresented, content: content))
    }

    func popover<PopoverContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> PopoverContent
    ) -> some View {
        modifier(PopoverModifier(config: DefaultPopoverConfig(), isPresented: isPresented, content: content))
    }

    // MARK: - Convenience (no binding) — wraps in a tap-aware container

    func popover<PopoverContent: View>(
        @ViewBuilder content: @escaping () -> PopoverContent
    ) -> some View {
        _MPPopoverTapContainer(trigger: self, config: DefaultPopoverConfig(), popoverContent: content)
    }

    func popover<PopoverContent: View>(
        config: PopoverConfig,
        @ViewBuilder content: @escaping () -> PopoverContent
    ) -> some View {
        _MPPopoverTapContainer(trigger: self, config: config, popoverContent: content)
    }

    func popover<PopoverContent: View>(
        type: PopoverType = .white,
        @ViewBuilder content: @escaping () -> PopoverContent
    ) -> some View {
        var config: PopoverConfig = DefaultPopoverConfig()
        config.type = type
        return _MPPopoverTapContainer(trigger: self, config: config, popoverContent: content)
    }
}

// MARK: - _MPPopoverTapContainer
// Owns the @State for isPresented and handles the tap — the trigger's action opens the popover.
// This mirrors the Andes pattern where the consumer controls isPresented via their button action.

private struct _MPPopoverTapContainer<Trigger: View, PopoverContent: View>: View {
    @State private var isPresented = false
    let trigger: Trigger
    let config: PopoverConfig
    let popoverContent: () -> PopoverContent

    var body: some View {
        trigger
            .contentShape(Rectangle())
            .onTapGesture { isPresented = true }
            .modifier(PopoverModifier(config: config, isPresented: $isPresented, content: popoverContent))
    }
}
