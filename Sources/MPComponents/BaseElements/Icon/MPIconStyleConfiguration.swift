//
//  MPIconStyleConfiguration.swift
//  MercadoPagoSDK
//
//  Created by Codex on 05/02/25.
//

import SwiftUI
import MPFoundation

package struct MPIconStyleConfiguration: Sendable {
    package let source: MPIconSource
    package let size: MPIconSize
    package let color: MPIconColor
    package let weight: MPIconWeight
    
    package init(
        source: MPIconSource,
        size: MPIconSize,
        color: MPIconColor,
        weight: MPIconWeight
    ) {
        self.source = source
        self.size = size
        self.color = color
        self.weight = weight
    }
}

package enum MPIconSource: Sendable, Equatable {
    case system(name: String)
    case asset(name: String)
}

package enum MPIconSize: CGFloat, Sendable, CaseIterable {
    case micro = 12
    case small = 16
    case medium = 20
    case large = 24
    case xlarge = 32
    
    var dimension: CGFloat { rawValue }
}

package enum MPIconWeight: Sendable {
    case regular
    case medium
    case semibold
    case bold
    
    var fontWeight: Font.Weight {
        switch self {
        case .regular:
            return .regular
        case .medium:
            return .medium
        case .semibold:
            return .semibold
        case .bold:
            return .bold
        }
    }
}

package enum MPIconColor: Sendable {
    case primary
    case secondary
    case accent
    case inverse
    case disabled
    
    func color(from theme: MPTheme) -> Color {
        switch self {
        case .primary:
            return theme.colors.icon.primary
        case .secondary:
            return theme.colors.icon.secondary
        case .accent:
            return theme.colors.icon.accent
        case .inverse:
            return theme.colors.icon.inverse
        case .disabled:
            return theme.colors.icon.disabled
        }
    }
}
