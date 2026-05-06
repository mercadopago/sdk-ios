//
//  View+Tooltip.swift
//  MPComponents
//

import SwiftUI

package extension View {
    // MARK: - With explicit isPresented binding

    func mpTooltip(
        config: MPTooltipConfig,
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        modifier(MPTooltipModifier(config: config, isPresented: isPresented, content: content))
    }

    func mpTooltip(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        modifier(MPTooltipModifier(config: MPDefaultTooltipConfig(), isPresented: isPresented, content: content))
    }

    // MARK: - Convenience (no binding) — wraps in a tap-aware container

    func mpTooltip(
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        _MPTooltipTapContainer(trigger: self, config: MPDefaultTooltipConfig(), tooltipContent: content)
    }

    func mpTooltip(
        config: MPTooltipConfig,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        _MPTooltipTapContainer(trigger: self, config: config, tooltipContent: content)
    }
}

// MARK: - _MPTooltipTapContainer

private struct _MPTooltipTapContainer<Trigger: View, TooltipContent: View>: View {
    @State private var isPresented = false
    let trigger: Trigger
    let config: MPTooltipConfig
    let tooltipContent: () -> TooltipContent

    var body: some View {
        self.trigger
            .contentShape(Rectangle())
            .onTapGesture { self.isPresented = true }
            .modifier(MPTooltipModifier(config: self.config, isPresented: self.$isPresented, content: self.tooltipContent))
    }
}
