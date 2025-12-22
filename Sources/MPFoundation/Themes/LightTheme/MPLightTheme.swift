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
    
    // Appearance Components
    public var buttons: MPButtons

    public init(
        colors: MPColors,
        spacings: MPSpacings,
        borderRadius: MPBorderRadius,
        outline: MPOutline,
        typography: MPTypography,
        buttons: MPButtons
    ) {
        self.colors = colors
        self.spacings = spacings
        self.borderRadius = borderRadius
        self.outline = outline
        self.typography = typography
        self.buttons = buttons
    }
    
    public init() {
        self.buttons = MPButtons(colors: colors, radios: borderRadius, outlines: outline, spacings: spacings, typography: typography)
    }
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
    
    public init() {}
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
    
    public init() {}
}

public struct LightBorderRadius: MPBorderRadius {
    public var xxs: CGFloat = 4.0
    public var xs: CGFloat = 6.0
    public var s: CGFloat = 16.0
    
    public init() {}
}

public struct LightOutline: MPOutline {
    public var xxs: CGFloat = 1.0
    public var xs: CGFloat = 2.0
    
    public init() {}
}
// swiftlint:enable identifier_name

@MainActor
package enum FontName: String {
    case semiBold = "ProximaNova-SemiBold"
    case regular = "ProximaNova-Regular"

    private static var hasRegistered = false

    public static func registerCustomFonts() {
        guard !hasRegistered else { return }

        let fontFileNames = ["\(FontName.semiBold.rawValue).ttf", "\(FontName.regular.rawValue).ttf"]

        for fontFileName in fontFileNames {
            guard let url = Bundle.module.url(forResource: fontFileName, withExtension: nil) else {
                continue
            }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }

        hasRegistered = true
    }
}

extension View {
    package func loadMPFonts() -> some View {
        FontName.registerCustomFonts()
        return self
    }
}

fileprivate extension Font {
    static func custom(_ name: FontName, size: CGFloat) -> Font {
        .custom(name.rawValue, size: size)
    }
}

// MARK: - Typography
public struct LightTypography: MPTypography {
    
    public var heading = MPHeadingStyle(
        size10: MPFontStyle(
            regular: .custom(.regular, size: 10),
            semibold: .custom(.semiBold, size: 10),
            bold: .custom(.bold, size: 10)
        ),
        size12: MPFontStyle(
            regular: .custom(.regular, size: 12),
            semibold: .custom(.semiBold, size: 12),
            bold: .custom(.bold, size: 12)
        ),
        size14: MPFontStyle(
            regular: .custom(.regular, size: 14),
            semibold: .custom(.semiBold, size: 14),
            bold: .custom(.bold, size: 14)
        ),
        size16: MPFontStyle(
            regular: .custom(.regular, size: 16),
            semibold: .custom(.semiBold, size: 16),
            bold: .custom(.bold, size: 16)
        ),
        size18: MPFontStyle(
            regular: .custom(.regular, size: 18),
            semibold: .custom(.semiBold, size: 18),
            bold: .custom(.bold, size: 18)
        ),
        size20: MPFontStyle(
            regular: .custom(.regular, size: 20),
            semibold: .custom(.semiBold, size: 20),
            bold: .custom(.bold, size: 20)
        ),
        size24: MPFontStyle(
            regular: .custom(.regular, size: 24),
            semibold: .custom(.semiBold, size: 24),
            bold: .custom(.semiBold, size: 24)
        ),
        size28: MPFontStyle(
            regular: .custom(.regular, size: 28),
            semibold: .custom(.semiBold, size: 28),
            bold: .custom(.bold, size: 28)
        ),
        size32: MPFontStyle(
            regular: .custom(.regular, size: 32),
            semibold: .custom(.semiBold, size: 32),
            bold: .custom(.bold, size: 32)
        ),
        size40: MPFontStyle(
            regular: .custom(.regular, size: 40),
            semibold: .custom(.semiBold, size: 40),
            bold: .custom(.bold, size: 40)
        ),
        size48: MPFontStyle(
            regular: .custom(.regular, size: 48),
            semibold: .custom(.semiBold, size: 48),
            bold: .custom(.bold, size: 48)
        ),
        size56: MPFontStyle(
            regular: .custom(.regular, size: 56),
            semibold: .custom(.semiBold, size: 56),
            bold: .custom(.bold, size: 56)
        )
    )

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
    
    public init() {}
}
