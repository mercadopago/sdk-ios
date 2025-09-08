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
        _ enabled: Bool = true,
        @ViewBuilder content: @escaping () -> TooltipContent
    ) -> some View {
        let config: TooltipConfig = DefaultTooltipConfig.shared

        return modifier(TooltipModifier(enabled: enabled, config: config, content: content))
    }

    // Only enable and config available
    func tooltip<TooltipContent: View>(
        _ enabled: Bool = true,
        config: TooltipConfig,
        @ViewBuilder content: @escaping () -> TooltipContent
    ) -> some View {
        modifier(TooltipModifier(enabled: enabled, config: config, content: content))
    }

    // Enable and side are available
    func tooltip<TooltipContent: View>(
        _ enabled: Bool = true,
        side: TooltipSide,
        @ViewBuilder content: @escaping () -> TooltipContent
    ) -> some View {
        var config = DefaultTooltipConfig.shared
        config.side = side

        return modifier(TooltipModifier(enabled: enabled, config: config, content: content))
    }
    
    // Enable, side and config parameters available
    func tooltip<TooltipContent: View>(
        _ enabled: Bool = true,
        side: TooltipSide,
        config: TooltipConfig,
        @ViewBuilder content: @escaping () -> TooltipContent
    ) -> some View {
        var config = config
        config.side = side

        return modifier(TooltipModifier(enabled: enabled, config: config, content: content))
    }
}

