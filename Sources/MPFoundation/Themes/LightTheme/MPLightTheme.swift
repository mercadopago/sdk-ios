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
    public var borderWidth: MPBorderWidth = LightBorderWidth()
    public var typography: MPTypography = LightTypography()
    
    // Component Appearances
    public var buttons: MPButtons
    public var textFields: MPTextFields
    public var toggles: MPToggles

    public init(
        colors: MPColors,
        spacings: MPSpacings,
        borderRadius: MPBorderRadius,
        borderWidth: MPBorderWidth,
        typography: MPTypography,
        buttons: MPButtons,
        textFields: MPTextFields,
        toggles: MPToggles
    ) {
        self.colors = colors
        self.spacings = spacings
        self.borderRadius = borderRadius
        self.borderWidth = borderWidth
        self.typography = typography
        self.buttons = buttons
        self.textFields = textFields
        self.toggles = toggles
    }
    
    public init() {
        self.buttons = MPButtons(
            colors: colors,
            radios: borderRadius,
            widths: borderWidth,
            spacings: spacings,
            typography: typography
        )
        self.textFields = MPTextFields(
            colors: colors,
            radios: borderRadius,
            widths: borderWidth,
            spacings: spacings,
            typography: typography
        )
        self.toggles = MPToggles(
            colors: colors,
            widths: borderWidth
        )
    }
}

// MARK: - Background Colors
public struct LightBackgroundColors: MPBackgroundColors {
    public var primary = Color(hex: 0xFFFFFF)
    public var secondary = Color(hex: 0xE7E9F3)
    
    public init() {}
}

// MARK: - Surface Colors
public struct LightSurfaceColors: MPSurfaceColors {
    public var primaryIdle = Color(hex: 0xFFFFFF)
    public var primaryActive = Color(hex: 0xE7E9F3)
    public var primaryDisabled = Color(hex: 0xFFFFFF, alpha: 0)
    
    public init() {}
}

// MARK: - Fill Colors
public struct LightFillColors: MPFillColors {
    public var primary = Color(hex: 0xFFFFFF)
    public var secondary = Color(hex: 0xD0D4E6)
    public var inverse = Color(hex: 0x282834)
    public var disabled = Color(hex: 0xD0D4E6)
    public var accentLoud = Color(hex: 0x434CE4)
    public var accentQuiet = Color(hex: 0xE9F1FF)
    public var defaultOnScroll = Color(hex: 0xFFFFFF, alpha: 0.98)
    
    public init() {}
}

// MARK: - Border Colors
public struct LightBorderColors: MPBorderColors {
    public var primary = Color(hex: 0xD0D4E6)
    public var accent = Color(hex: 0x434CE4)
    public var inverse = Color(hex: 0xFFFFFF)
    public var disabled = Color(hex: 0xB5B9D4)
    
    public init() {}
}

// MARK: - Icon Colors
public struct LightIconColors: MPIconColors {
    public var primary = Color(hex: 0x282834)
    public var secondary = Color(hex: 0x646587)
    public var accent = Color(hex: 0x434CE4)
    public var inverse = Color(hex: 0xFFFFFF)
    public var disabled = Color(hex: 0x9C9EBF)
    
    public init() {}
}

// MARK: - Text Colors
public struct LightTextColors: MPTextColors {
    public var primary = Color(hex: 0x282834)
    public var secondary = Color(hex: 0x646587)
    public var accent = Color(hex: 0x434CE4)
    public var inverse = Color(hex: 0xFFFFFF)
    public var disabled = Color(hex: 0x9C9EBF)
    public var linkIdle = Color(hex: 0x434CE4)
    public var linkActive = Color(hex: 0x272C96)
    
    public init() {}
}

// MARK: - Brand Colors
public struct LightBrandColors: MPBrandColors {
    public var fillLoud = Color(hex: 0xFFE600)
    public var fillQuiet = Color(hex: 0xFFF394)
    public var gradientStart = Color(hex: 0xF9C200)
    public var gradientEnd = Color(hex: 0xFFE600)
    
    public init() {}
}

// MARK: - Feedback Colors
public struct LightFeedbackColors: MPFeedbackColors {
    // Fill
    public var fillInformativeLoud = Color(hex: 0x434CE4)
    public var fillInformativeQuiet = Color(hex: 0xE9F1FF)
    public var fillPositiveLoud = Color(hex: 0x1F8923)
    public var fillPositiveQuiet = Color(hex: 0xDEFADE)
    public var fillCautionLoud = Color(hex: 0xD74009)
    public var fillCautionQuiet = Color(hex: 0xFFEDC7)
    public var fillNegativeLoud = Color(hex: 0xC4031D)
    public var fillNegativeQuiet = Color(hex: 0xFFE5E9)
    
    // Text
    public var textInformativeLoud = Color(hex: 0x434CE4)
    public var textPositiveLoud = Color(hex: 0x1F8923)
    public var textCautionLoud = Color(hex: 0xD74009)
    public var textNegativeLoud = Color(hex: 0xC4031D)
    
    // Border
    public var borderInformativeLoud = Color(hex: 0x5C70FA)
    public var borderPositiveLoud = Color(hex: 0x14A919)
    public var borderCautionLoud = Color(hex: 0xF05705)
    public var borderNegativeLoud = Color(hex: 0xED314A)
    
    // Icon
    public var iconInformativeLoud = Color(hex: 0x434CE4)
    public var iconPositiveLoud = Color(hex: 0x1F8923)
    public var iconCautionLoud = Color(hex: 0xD74009)
    public var iconNegativeLoud = Color(hex: 0xC4031D)
    
    public init() {}
}

// MARK: - Interactive Colors
public struct LightInteractiveColors: MPInteractiveColors {
    // Fill - Loud
    public var fillLoudIdle = Color(hex: 0x434CE4)
    public var fillLoudHover = Color(hex: 0x353AC5)
    public var fillLoudActive = Color(hex: 0x272C96)
    
    // Fill - Quiet
    public var fillQuietIdle = Color(hex: 0xE9F1FF)
    public var fillQuietHover = Color(hex: 0xDEE9FF)
    public var fillQuietActive = Color(hex: 0xC6D8FF)
    
    // Fill - Mute
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
    
    public init() {}
}

// MARK: - Aggregated Colors
public struct LightColors: MPColors {
    public var background: MPBackgroundColors = LightBackgroundColors()
    public var surface: MPSurfaceColors = LightSurfaceColors()
    public var fill: MPFillColors = LightFillColors()
    public var border: MPBorderColors = LightBorderColors()
    public var icon: MPIconColors = LightIconColors()
    public var text: MPTextColors = LightTextColors()
    public var brand: MPBrandColors = LightBrandColors()
    public var feedback: MPFeedbackColors = LightFeedbackColors()
    public var interactive: MPInteractiveColors = LightInteractiveColors()
    public var transparent = Color(hex: 0xFFFFFF, alpha: 0)
    
    public init() {}
}

// MARK: - Spacings
public struct LightSpacings: MPSpacings {
    public var none: CGFloat = 0.0
    public var pico: CGFloat = 2.0
    public var xnano: CGFloat = 4.0
    public var nano: CGFloat = 6.0
    public var xmicro: CGFloat = 8.0
    public var micro: CGFloat = 12.0
    public var xtiny: CGFloat = 16.0
    public var tiny: CGFloat = 20.0
    public var xsmall: CGFloat = 24.0
    public var small: CGFloat = 32.0
    public var medium: CGFloat = 40.0
    public var large: CGFloat = 48.0
    public var xlarge: CGFloat = 56.0
    public var huge: CGFloat = 64.0
    public var xhuge: CGFloat = 72.0
    public var mega: CGFloat = 80.0
    public var xmega: CGFloat = 84.0
    
    public init() {}
}

// MARK: - Border Radius
public struct LightBorderRadius: MPBorderRadius {
    public var none: CGFloat = 0.0
    public var tiny: CGFloat = 4.0
    public var xsmall: CGFloat = 6.0
    public var small: CGFloat = 8.0
    public var medium: CGFloat = 12.0
    public var large: CGFloat = 16.0
    public var xlarge: CGFloat = 20.0
    public var full: CGFloat = 9999.0
    
    public init() {}
}

// MARK: - Border Width
public struct LightBorderWidth: MPBorderWidth {
    public var none: CGFloat = 0.0
    public var small: CGFloat = 1.0
    public var medium: CGFloat = 2.0
    public var large: CGFloat = 3.0
    public var xlarge: CGFloat = 4.0
    
    public init() {}
}

// MARK: - Font Registration
@MainActor
package enum FontName: String {
    case bold = "Inter-Bold"
    case semiBold = "Inter-SemiBold"
    case regular = "Inter-Regular"
    
    private static var hasRegistered = false

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
