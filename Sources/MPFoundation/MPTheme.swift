//
//  MPTheme.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 09/06/25.
//
import SwiftUI
import Foundation

// MARK: - Theme Protocol Definition
public protocol MPTheme: Sendable {
    var colors: MPColors { get set }
    var spacings: MPSpacings { get set }
    var borderRadius: MPBorderRadius { get set }
    var borderWidth: MPBorderWidth { get set }
    var typography: MPTypography { get set }
    
    // Component Appearances
    var buttons: MPButtons { get set }
    var textFields: MPTextFields { get set }
    var toggles: MPToggles { get set }
}

public enum UserInterfaceStyle {
    case automatic
    case lightMode
    case darkMode
}

// MARK: - Color Definitions

/// Background colors for main surfaces and containers
public protocol MPBackgroundColors: Sendable {
    var primary: Color { get set }
    var secondary: Color { get set }
}

/// Surface colors with state variations
public protocol MPSurfaceColors: Sendable {
    var primaryIdle: Color { get set }
    var primaryActive: Color { get set }
    var primaryDisabled: Color { get set }
}

/// Fill colors for shapes and containers
public protocol MPFillColors: Sendable {
    var primary: Color { get set }
    var secondary: Color { get set }
    var inverse: Color { get set }
    var disabled: Color { get set }
    var accentLoud: Color { get set }
    var accentQuiet: Color { get set }
    var defaultOnScroll: Color { get set }
}

/// Border colors
public protocol MPBorderColors: Sendable {
    var primary: Color { get set }
    var accent: Color { get set }
    var inverse: Color { get set }
    var disabled: Color { get set }
}

/// Icon colors
public protocol MPIconColors: Sendable {
    var primary: Color { get set }
    var secondary: Color { get set }
    var accent: Color { get set }
    var inverse: Color { get set }
    var disabled: Color { get set }
}

/// Text colors
public protocol MPTextColors: Sendable {
    var primary: Color { get set }
    var secondary: Color { get set }
    var accent: Color { get set }
    var inverse: Color { get set }
    var disabled: Color { get set }
    var linkIdle: Color { get set }
    var linkActive: Color { get set }
}

/// Brand colors
public protocol MPBrandColors: Sendable {
    var fillLoud: Color { get set }
    var fillQuiet: Color { get set }
    var gradientStart: Color { get set }
    var gradientEnd: Color { get set }
}

/// Feedback colors with fill, text, border and icon variants
public protocol MPFeedbackColors: Sendable {
    // Fill
    var fillInformativeLoud: Color { get set }
    var fillInformativeQuiet: Color { get set }
    var fillPositiveLoud: Color { get set }
    var fillPositiveQuiet: Color { get set }
    var fillCautionLoud: Color { get set }
    var fillCautionQuiet: Color { get set }
    var fillNegativeLoud: Color { get set }
    var fillNegativeQuiet: Color { get set }
    
    // Text
    var textInformativeLoud: Color { get set }
    var textPositiveLoud: Color { get set }
    var textCautionLoud: Color { get set }
    var textNegativeLoud: Color { get set }
    
    // Border
    var borderInformativeLoud: Color { get set }
    var borderPositiveLoud: Color { get set }
    var borderCautionLoud: Color { get set }
    var borderNegativeLoud: Color { get set }
    
    // Icon
    var iconInformativeLoud: Color { get set }
    var iconPositiveLoud: Color { get set }
    var iconCautionLoud: Color { get set }
    var iconNegativeLoud: Color { get set }
}

/// Interactive colors for buttons and interactive elements
public protocol MPInteractiveColors: Sendable {
    // Fill - Loud
    var fillLoudIdle: Color { get set }
    var fillLoudHover: Color { get set }
    var fillLoudActive: Color { get set }
    
    // Fill - Quiet
    var fillQuietIdle: Color { get set }
    var fillQuietHover: Color { get set }
    var fillQuietActive: Color { get set }
    
    // Fill - Mute
    var fillMuteIdle: Color { get set }
    var fillMuteHover: Color { get set }
    var fillMuteActive: Color { get set }
    
    // Border
    var borderIdle: Color { get set }
    var borderActive: Color { get set }
    
    // Icon
    var iconIdle: Color { get set }
    var iconActive: Color { get set }
    var iconIdleAccent: Color { get set }
    var iconActiveAccent: Color { get set }
}

/// Main color protocol aggregating all color categories
public protocol MPColors: Sendable {
    var background: MPBackgroundColors { get set }
    var surface: MPSurfaceColors { get set }
    var fill: MPFillColors { get set }
    var border: MPBorderColors { get set }
    var icon: MPIconColors { get set }
    var text: MPTextColors { get set }
    var brand: MPBrandColors { get set }
    var feedback: MPFeedbackColors { get set }
    var interactive: MPInteractiveColors { get set }
    var transparent: Color { get set }
}

// MARK: - Spacing Definitions

/// Spacing tokens for paddings and gaps
public protocol MPSpacings: Sendable {
    var none: CGFloat { get set }
    var pico: CGFloat { get set }
    var xnano: CGFloat { get set }
    var nano: CGFloat { get set }
    var xmicro: CGFloat { get set }
    var micro: CGFloat { get set }
    var xtiny: CGFloat { get set }
    var tiny: CGFloat { get set }
    var xsmall: CGFloat { get set }
    var small: CGFloat { get set }
    var medium: CGFloat { get set }
    var large: CGFloat { get set }
    var xlarge: CGFloat { get set }
    var huge: CGFloat { get set }
    var xhuge: CGFloat { get set }
    var mega: CGFloat { get set }
    var xmega: CGFloat { get set }
}

// MARK: - Border Radius Definitions

/// Border radius tokens
public protocol MPBorderRadius: Sendable {
    var none: CGFloat { get set }
    var tiny: CGFloat { get set }
    var xsmall: CGFloat { get set }
    var small: CGFloat { get set }
    var medium: CGFloat { get set }
    var large: CGFloat { get set }
    var xlarge: CGFloat { get set }
    var full: CGFloat { get set }
}

// MARK: - Border Width Definitions

/// Border width tokens
public protocol MPBorderWidth: Sendable {
    var none: CGFloat { get set }
    var small: CGFloat { get set }
    var medium: CGFloat { get set }
    var large: CGFloat { get set }
    var xlarge: CGFloat { get set }
}

// MARK: - Typography Definitions

public struct MPFontStyle: Sendable {
    public var regular: Font
    public var semibold: Font
    public var bold: Font
    
    public init(regular: Font, semibold: Font, bold: Font) {
        self.regular = regular
        self.semibold = semibold
        self.bold = bold
    }
    
    public init(regular: Font, semibold: Font) {
        self.regular = regular
        self.semibold = semibold
        self.bold = semibold
    }
}

public struct MPHeadingStyle: Sendable {
    public var size10: MPFontStyle
    public var size12: MPFontStyle
    public var size14: MPFontStyle
    public var size16: MPFontStyle
    public var size18: MPFontStyle
    public var size20: MPFontStyle
    public var size24: MPFontStyle
    public var size28: MPFontStyle
    public var size32: MPFontStyle
    public var size40: MPFontStyle
    public var size48: MPFontStyle
    public var size56: MPFontStyle
    
    public init(
        size10: MPFontStyle,
        size12: MPFontStyle,
        size14: MPFontStyle,
        size16: MPFontStyle,
        size18: MPFontStyle,
        size20: MPFontStyle,
        size24: MPFontStyle,
        size28: MPFontStyle,
        size32: MPFontStyle,
        size40: MPFontStyle,
        size48: MPFontStyle,
        size56: MPFontStyle
    ) {
        self.size10 = size10
        self.size12 = size12
        self.size14 = size14
        self.size16 = size16
        self.size18 = size18
        self.size20 = size20
        self.size24 = size24
        self.size28 = size28
        self.size32 = size32
        self.size40 = size40
        self.size48 = size48
        self.size56 = size56
    }
}

public struct MPTitleStyle: Sendable {
    public var smallSemibold: Font
    
    public init(smallSemibold: Font) {
        self.smallSemibold = smallSemibold
    }
}

public struct MPBodyStyle: Sendable {
    public var medium: MPFontStyle
    public var small: MPFontStyle
    public var extraSmallSemibold: Font
    
    public init(medium: MPFontStyle, small: MPFontStyle, extraSmallSemibold: Font) {
        self.medium = medium
        self.small = small
        self.extraSmallSemibold = extraSmallSemibold
    }
}

public protocol MPTypography: Sendable {
    var heading: MPHeadingStyle { get }
    var title: MPTitleStyle { get }
    var body: MPBodyStyle { get }
}
