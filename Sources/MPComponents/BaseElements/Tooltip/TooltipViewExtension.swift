//
//  TooltipViewExtension.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 08/09/25.
//

import SwiftUI

// MARK: - with `enabled: Bool`
package extension View {
    // Only enable parameter accessible
    func tooltip<TooltipContent: View>(
        _ enabled: Binding<Bool> = .constant(false),
        @ViewBuilder content: @escaping () -> TooltipContent
    ) -> some View {
        let config: TooltipConfig = DefaultTooltipConfig()

        return modifier(TooltipModifier(enabled: enabled, config: config, content: content))
    }

    // Only enable and config available
    func tooltip<TooltipContent: View>(
        _ enabled: Binding<Bool>,
        config: TooltipConfig,
        @ViewBuilder content: @escaping () -> TooltipContent
    ) -> some View {
        modifier(TooltipModifier(enabled: enabled, config: config, content: content))
    }

    // Enable and side are available
    func tooltip<TooltipContent: View>(
        _ enabled: Binding<Bool>,
        side: TooltipSide,
        type: TooltipType = .blue,
        @ViewBuilder content: @escaping () -> TooltipContent
    ) -> some View {
        var config: TooltipConfig = DefaultTooltipConfig()
        config.side = side
        config.type = type

        return modifier(TooltipModifier(enabled: enabled, config: config, content: content))
    }
}

