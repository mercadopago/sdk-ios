//
//  MPLightTheme.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 10/06/25.
//
import SwiftUI

// MARK: - MPLightTheme Implementation
public struct MPLightTheme: MPTheme {
    public var colors: MPColors
    public var spacings: MPSpacings
    public var borderRadius: MPBorderRadius
    public var borderWidth: MPBorderWidth
    public var outline: MPOutline
    public var typography: MPTypography
    
    // Component Appearances
    public var buttons: MPButtons
    public var textFields: MPTextFields

    public init(
        colors: MPColors,
        spacings: MPSpacings,
        borderRadius: MPBorderRadius,
        borderWidth: MPBorderWidth,
        outline: MPOutline,
        typography: MPTypography,
        buttons: MPButtons,
        textFields: MPTextFields
    ) {
        self.colors = colors
        self.spacings = spacings
        self.borderRadius = borderRadius
        self.borderWidth = borderWidth
        self.outline = outline
        self.typography = typography
        self.buttons = buttons
        self.textFields = textFields
    }
    
    @MainActor
    public init() {
        self.colors = LightColors()
        self.spacings = LightSpacings()
        self.borderRadius = LightBorderRadius()
        self.borderWidth = LightBorderWidth()
        self.outline = LightOutline()
        self.typography = LightTypography()
        
        self.buttons = MPButtons(
            colors: colors,
            radios: borderRadius,
            outlines: outline,
            spacings: spacings,
            typography: typography
        )
        self.textFields = MPTextFields(
            colors: colors,
            borderRadius: borderRadius,
            borderWidth: borderWidth,
            spacings: spacings,
            typography: typography
        )
    }
}

// MARK: - Color Implementations

public struct LightBackgroundColors: MPBackgroundColors {
    public var primary = Color(hex: 0xFFFFFF)
    public var secondary = Color(hex: 0xE7E9F3)
}

public struct LightFillColors: MPFillColors {
    public var primary = Color(hex: 0xFFFFFF)
    public var secondary = Color(hex: 0xD0D4E6)
    public var inverse = Color(hex: 0x282834)
    public var disabled = Color(hex: 0xD0D4E6)
    public var accentLoud = Color(hex: 0x434CE4)
    public var accentQuiet = Color(hex: 0xE9F1FF)
}

public struct LightTextColorTokens: MPTextColorTokens {
    public var primary = Color(hex: 0x282834)
    public var secondary = Color(hex: 0x646587)
    public var accent = Color(hex: 0x434CE4)
    public var inverse = Color(hex: 0xFFFFFF)
    public var disabled = Color(hex: 0x9C9EBF)
    public var linkIdle = Color(hex: 0x9C9EBF)
    public var linkActive = Color(hex: 0x272C96)
}

public struct LightInteractiveColors: MPInteractiveColors {
    // Fill
    public var fillLoudIdle = Color(hex: 0x434CE4)
    public var fillLoudHover = Color(hex: 0x353AC5)
    public var fillLoudActive = Color(hex: 0x272C96)
    public var fillQuietIdle = Color(hex: 0xE9F1FF)
    public var fillQuietHover = Color(hex: 0xDEE9FF)
    public var fillQuietActive = Color(hex: 0xC6D8FF)
    public var fillMuteIdle = Color(hex: 0xFFFFFF, alpha: 0)
    public var fillMuteHover = Color(hex: 0xE9F1FF)
    public var fillMuteActive = Color(hex: 0xDEE9FF)
    
    // Border
    public var borderIdle = Color(hex: 0x8788AB)
    public var borderActive = Color(hex: 0x434CE4)
    
    // Icon
    public var iconIdle = Color(hex: 0x646587)
    public var iconActive = Color(hex: 0x282834)
    public var iconIdleAccent = Color(hex: 0x434CE4)
    public var iconActiveAccent = Color(hex: 0x272C96)
}

public struct LightFeedbackColorTokens: MPFeedbackColorTokens {
    // Fill
    public var fillPositiveLoud = Color(hex: 0x1F8923)
    public var fillPositiveQuiet = Color(hex: 0xDEFADE)
    
    public var fillNegativeLoud = Color(hex: 0xC4031D)
    public var fillNegativeQuiet = Color(hex: 0xFFE5E9)
    
    public var fillCautionLoud = Color(hex: 0xD74009)
    public var fillCautionQuiet = Color(hex: 0xFFEDC7)
    
    public var fillInformativeLoud = Color(hex: 0x434CE4)
    public var fillInformativeQuiet = Color(hex: 0xE9F1FF)
    
    // Text
    public var textPositiveLoud = Color(hex: 0x1F8923)
    public var textNegativeLoud = Color(hex: 0xC4031D)
    public var textCautionLoud = Color(hex: 0xD74009)
    public var textInformativeLoud = Color(hex: 0x434CE4)
    
    // Border
    public var borderPositiveLoud = Color(hex: 0x14A919)
    public var borderNegativeLoud = Color(hex: 0xED314A)
    public var borderCautionLoud = Color(hex: 0xF5A623)
    public var borderInformativeLoud = Color(hex: 0x5C70FA)
}

public struct LightBorderColorTokens: MPBorderColorTokens {
    public var primary = Color(hex: 0xD0D4E6)
    public var accent = Color(hex: 0x434CE4)
    public var inverse = Color(hex: 0xFFFFF)
    public var disabled = Color(hex: 0xB5B9D4)
}

public struct LightSurfaceColors: MPSurfaceColors {
    public var idle = Color(hex: 0xFFFFFF)
    public var active = Color(hex: 0xE7E9F3)
    public var disabled = Color(hex: 0xFFFFFF).opacity(0)
}

public struct LightIconColors: MPIconColors {
    public var primary = Color(hex: 0x282834)
    public var secondary = Color(hex: 0x646587)
    public var accent = Color(hex: 0x434CE4)
    public var inverse = Color(hex: 0xFFFFFF)
    public var disabled = Color(hex: 0x9C9EBF)
}

public struct LightColors: MPColors {
    public var background: MPBackgroundColors = LightBackgroundColors()
    public var fill: MPFillColors = LightFillColors()
    public var text: MPTextColorTokens = LightTextColorTokens()
    public var border: MPBorderColorTokens = LightBorderColorTokens()
    public var surface: MPSurfaceColors = LightSurfaceColors()
    public var icon: MPIconColors = LightIconColors()
    public var interactive: MPInteractiveColors = LightInteractiveColors()
    public var feedback: MPFeedbackColorTokens = LightFeedbackColorTokens()
    
    // Legacy tokens
    public var accent = Color(hex: 0x3483FA)
    public var accentFirstVariant = Color(hex: 0x2968c8)
    public var accentSecondVariant = Color(hex: 0x1f4e96)
    public var accentYellow = Color(hex: 0xffe600)
    public var accentPositive = Color(hex: 0x00a650)
    public var accentNegative = Color(hex: 0xf23d4f)
    public var backgroundPrimary = Color(hex: 0xffffff)
    public var backgroundSecondary = Color(hex: 0xf5f5f5)
    public var backgroundTertiary = Color(hex: 0xededed)
    public var backgroundInverted = Color(hex: 0x1a1a1a)
    public var textPrimary = Color(hex: 0x1a1a1a)
    public var textSecondary = Color(hex: 0x737373)
    public var textAccent = Color(hex: 0x3483fa)
    public var textDisabled = Color(hex: 0xbfbfbf)
    public var textNegative = Color(hex: 0xf23d4f)
    public var textInverted = Color(hex: 0xffffff)
    public var secondary = Color(hex: 0xe3edfb)
    public var secondaryFirstVariant = Color(hex: 0xd9e7fa)
    public var secondarySecondVariant = Color(hex: 0xc6dcf7)
    public var outlinePrimary = Color(hex: 0xbfbfbf)
    public var outlineSecondary = Color(hex: 0xe5e5e5)
    public var feedbackPositive = Color(hex: 0x00a650)
    public var feedbackNegative = Color(hex: 0xf23d4f)
    public var feedbackPositiveSecondary = Color(hex: 0xdcede4)
    
    public init() {}
}

// MARK: - Spacing Implementation

public struct LightSpacings: MPSpacings {
    public var none: CGFloat = 0
    public var pico: CGFloat = 2
    public var xnano: CGFloat = 4
    public var nano: CGFloat = 6
    public var xmicro: CGFloat = 8
    public var micro: CGFloat = 12
    public var xtiny: CGFloat = 16
    public var tiny: CGFloat = 20
    public var xsmall: CGFloat = 24
    public var small: CGFloat = 32
    public var medium: CGFloat = 40
    public var large: CGFloat = 48
    public var xlarge: CGFloat = 56
    public var huge: CGFloat = 64
    
    // swiftlint:disable identifier_name
    // Legacy tokens
    public var xxs: CGFloat = 4.0
    public var xs: CGFloat = 8.0
    public var s: CGFloat = 12.0
    public var m: CGFloat = 16.0
    public var l: CGFloat = 20.0
    public var xl: CGFloat = 24.0
    public var xxl: CGFloat = 32.0
    // swiftlint:enable identifier_name
    
    public init() {}
}

// MARK: - Border Radius Implementation

public struct LightBorderRadius: MPBorderRadius {
    public var none: CGFloat = 0
    public var tiny: CGFloat = 4
    public var xsmall: CGFloat = 6
    public var small: CGFloat = 8
    public var medium: CGFloat = 12
    public var large: CGFloat = 16
    public var xlarge: CGFloat = 20
    public var full: CGFloat = 9999
    
    // swiftlint:disable identifier_name
    // Legacy tokens
    public var xxs: CGFloat = 4.0
    public var xs: CGFloat = 6.0
    public var s: CGFloat = 16.0
    // swiftlint:enable identifier_name
    
    public init() {}
}

// MARK: - Border Width Implementation

public struct LightBorderWidth: MPBorderWidth {
    public var none: CGFloat = 0
    public var small: CGFloat = 1
    public var medium: CGFloat = 2
    public var large: CGFloat = 3
    public var xlarge: CGFloat = 4
    
    public init() {}
}

// MARK: - Outline Implementation
public struct LightOutline: MPOutline {
    public var xxs: CGFloat = 1.0
    public var xs: CGFloat = 2.0
    
    public init() {}
}

// MARK: - Font Registration


package enum FontName: String {
    case bold = "Inter-Bold"
    case semiBold = "Inter-SemiBold"
    case regular = "Inter-Regular"

    @MainActor
    private static var hasRegistered = false

    @MainActor
    public static func registerCustomFonts() {
        guard !hasRegistered else { return }

        let fontFileNames = [
            "\(FontName.bold.rawValue).ttf",
            "\(FontName.semiBold.rawValue).ttf",
            "\(FontName.regular.rawValue).ttf"
        ]

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

extension UIFont {
    static func custom(_ name: FontName, size: CGFloat) -> UIFont {
        UIFont(name: name.rawValue, size: size)!
    }
    
    package func toFont() -> Font {
        return Font(self)
    }
}


public struct LightTypography: MPTypography {
    
    public var heading: MPHeadingStyle
    
    public var body: MPBodyStyle

    @MainActor
    public init() {
        FontName.registerCustomFonts()
        
        self.heading = .init(
            huge: .custom(.bold, size: 24),
            medium: .custom(.bold, size: 16)
        )
        
        self.body = .init(
            large: .init(
                default: .custom(.regular, size: 18),
                emphasis: .custom(.bold, size: 16)
            ),
            medium: .init(
                default: .custom(.regular, size: 14),
                emphasis: .custom(.semiBold, size: 14),
                title: .custom(.semiBold, size: 14)
            ),
            small: .init(
                default: .custom(.regular, size: 12),
                emphasis: .custom(.semiBold, size: 12)
            )
        )
    }
}
