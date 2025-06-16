//
//  MPLightTheme.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 10/06/25.
//


import SwiftUI

// MARK: - MPLightTheme Implementation
public struct MPLightTheme: MPTheme {
    public var colors: MPColors = LightColors()
    public var spacings: MPSpacings = LightSpacings()
    public var borderRadius: MPBorderRadius = LightBorderRadius()
    public var outline: MPOutline = LightOutline()
    public var typography: MPTypography = LightTypography()
    
    public init(
        colors: MPColors,
        spacings: MPSpacings,
        borderRadius: MPBorderRadius,
        outline: MPOutline,
        typography: MPTypography
    ) {
        self.colors = colors
        self.spacings = spacings
        self.borderRadius = borderRadius
        self.outline = outline
        self.typography = typography
    }
    
    public init() {}
}

public struct LightColors: MPColors {
    // Accent
    public var accent = Color(hex: 0x3483FA)
    public var accentFirstVariant = Color(hex: 0x2968c8)
    public var accentSecondVariant = Color(hex: 0x1f4e96)
    public var accentYellow = Color(hex: 0xffe600)
    public var accentPositive = Color(hex: 0x00a650)
    public var accentNegative = Color(hex: 0xf23d4f)

    // Background
    public var backgroundPrimary = Color(hex: 0xffffff)
    public var backgroundSecondary = Color(hex: 0xf5f5f5)
    public var backgroundTertiary = Color(hex: 0xededed)
    public var backgroundInverted = Color(hex: 0x1a1a1a)

    // Text
    public var textPrimary = Color(hex: 0x1a1a1a)
    public var textSecondary = Color(hex: 0x737373)
    public var textAccent = Color(hex: 0x3483fa)
    public var textDisabled = Color(hex: 0xbfbfbf)
    public var textNegative = Color(hex: 0xf23d4f)
    public var textInverted = Color(hex: 0xffffff)
    
    // Secondary
    public var secondary = Color(hex: 0xe3edfb)
    public var secondaryFirstVariant = Color(hex: 0xd9e7fa)
    public var secondarySecondVariant = Color(hex: 0xc6dcf7)

    // Outline
    public var outlinePrimary = Color(hex: 0xbfbfbf)
    public var outlineSecondary = Color(hex: 0xe5e5e5)
    
    // Feedback
    public var feedbackPositive = Color(hex: 0x00a650)
    public var feedbackNegative = Color(hex: 0xf23d4f)
    public var feedbackPositiveSecondary = Color(hex: 0xdcede4)
}

// swiftlint:disable identifier_name
public struct LightSpacings: MPSpacings {
    public var xxs: CGFloat = 4.0
    public var xs: CGFloat = 8.0
    public var s: CGFloat = 12.0
    public var m: CGFloat = 16.0
    public var l: CGFloat = 20.0
    public var xl: CGFloat = 24.0
    public var xxl: CGFloat = 32.0
}

public struct LightBorderRadius: MPBorderRadius {
    public var xxs: CGFloat = 4.0
    public var xs: CGFloat = 6.0
    public var s: CGFloat = 16.0
}

public struct LightOutline: MPOutline {
    public var xxs: CGFloat = 1.0
    public var xs: CGFloat = 2.0
}

// swiftlint:enable identifier_name

fileprivate enum FontName: String {
    case semiBold = "ProximaNova-SemiBold"
    case regular = "ProximaNova-Regular"
}

fileprivate extension Font {
    static func custom(_ name: FontName, size: CGFloat) -> Font {
        .custom(name.rawValue, size: size)
    }
}

public struct LightTypography: MPTypography {

    public var title = MPTitleStyle(
        smallSemibold: .custom(.semiBold, size: 20)
    )

    public var body = MPBodyStyle(
        medium: MPFontStyle(
            regular: .custom(.regular, size: 16),
            semibold: .custom(.semiBold, size: 16)
        ),
        small: MPFontStyle(
            regular: .custom(.regular, size: 14),
            semibold: .custom(.semiBold, size: 14)
        ),
        extraSmallSemibold: .custom(.semiBold, size: 12)
    )
}
