//
//  DefaultTooltipConfig.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 08/09/25.
//


import SwiftUI
import MPFoundation

package enum TooltipType {
    case blue
    case dark
}

package struct DefaultTooltipConfig: TooltipConfig {
    package var side: TooltipSide = .top
    package var margin: CGFloat = 8
    package var zIndex: Double = 10000
    
    package var width: CGFloat?
    package var height: CGFloat?

    package var showArrow: Bool = true
    package var arrowWidth: CGFloat = 12
    package var arrowHeight: CGFloat = 6
    package var arrowType: ArrowType = .default
    
    package var enableAnimation: Bool = false
    package var animationOffset: CGFloat = 10
    package var animationTime: Double = 1
    package var animation: Optional<Animation> = .easeInOut
    
    package var type: TooltipType = .blue

    package init() {}

    package init(side: TooltipSide, type: TooltipType) {
        self.side = side
        self.type = type
    }
    
    // MARK: - Theme-based methods
    
    package func borderRadius(from theme: MPTheme) -> CGFloat {
        return theme.borderRadius.s
    }
    
    package func borderWidth(from theme: MPTheme) -> CGFloat {
        return theme.outline.xs
    }
    
    package func borderColor(from theme: MPTheme) -> Color {
        return .clear
    }
    
    package func backgroundColor(from theme: MPTheme) -> Color {
        switch type {
        case .blue:
            return theme.colors.accent
        case .dark:
            return theme.colors.backgroundInverted
        }
    }
    
    package func shadowColor(from theme: MPTheme) -> Color {
        return theme.colors.outlineSecondary.opacity(0.0)
    }
    
    package func shadowRadius(from theme: MPTheme) -> CGFloat {
        return theme.spacings.xxs
    }
    
    package func shadowOffset(from theme: MPTheme) -> CGPoint {
        return CGPoint(x: 0, y: theme.spacings.xxs/2)
    }
    
    package func contentPadding(from theme: MPTheme) -> EdgeInsets {
        return EdgeInsets(
            top: theme.spacings.m,
            leading: theme.spacings.m,
            bottom: theme.spacings.m,
            trailing: theme.spacings.m
        )
    }
}
