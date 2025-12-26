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
    var outline: MPOutline { get set }
    var typography: MPTypography { get set }
    
    var buttons: MPButtons { get set }
}

public enum UserInterfaceStyle {
    case automatic
    case lightMode
    case darkMode
}

// MARK: - Color Protocols

public protocol MPBackgroundColors: Sendable {
    var primary: Color { get }
    var secondary: Color { get }
}

public protocol MPFillColors: Sendable {
    var primary: Color { get }
    var secondary: Color { get }
    var inverse: Color { get }
    var disabled: Color { get }
    var accentLoud: Color { get }
    var accentQuiet: Color { get }
}

public protocol MPTextColorTokens: Sendable {
    var primary: Color { get }
    var secondary: Color { get }
    var accent: Color { get }
    var inverse: Color { get }
    var disabled: Color { get }
    var linkIdle: Color { get }
    var linkActive: Color { get }
}

public protocol MPInteractiveColors: Sendable {
    // Fill
    var fillLoudIdle: Color { get }
    var fillLoudHover: Color { get }
    var fillLoudActive: Color { get }
    var fillQuietIdle: Color { get }
    var fillQuietHover: Color { get }
    var fillQuietActive: Color { get }
    var fillMuteIdle: Color { get }
    var fillMuteHover: Color { get }
    var fillMuteActive: Color { get }
    
    // Border
    var borderIdle: Color { get }
    var borderActive: Color { get }
    
    // Icon
    var iconIdle: Color { get }
    var iconActive: Color { get }
    var iconIdleAccent: Color { get }
    var iconActiveAccent: Color { get }
}

public protocol MPFeedbackColorTokens: Sendable {
    // Fill
    var fillPositiveLoud: Color { get }
    var fillPositiveQuiet: Color { get }
    var fillNegativeLoud: Color { get }
    var fillNegativeQuiet: Color { get }
    var fillCautionLoud: Color { get }
    var fillCautionQuiet: Color { get }
    var fillInformativeLoud: Color { get }
    var fillInformativeQuiet: Color { get }
    
    // Text
    var textPositiveLoud: Color { get }
    var textNegativeLoud: Color { get }
    var textCautionLoud: Color { get }
    var textInformativeLoud: Color { get }
    
    // Border
    var borderPositiveLoud: Color { get }
    var borderNegativeLoud: Color { get }
    var borderCautionLoud: Color { get }
    var borderInformativeLoud: Color { get }
}

public protocol MPBorderColorTokens: Sendable {
    var primary: Color { get }
    var accent: Color { get }
    var inverse: Color { get }
    var disabled: Color { get }
}

// MARK: - Color Definitions
public protocol MPColors: Sendable {
    // New tokens
    var background: MPBackgroundColors { get }
    var fill: MPFillColors { get }
    var text: MPTextColorTokens { get }
    var border: MPBorderColorTokens { get }
    var interactive: MPInteractiveColors { get }
    var feedback: MPFeedbackColorTokens { get }
    
    // Legacy tokens
    var accent: Color { get set }
    var accentFirstVariant: Color { get set }
    var accentSecondVariant: Color { get set }
    var accentYellow: Color { get set }
    var accentPositive: Color { get set }
    var accentNegative: Color { get set }
    var backgroundPrimary: Color { get set }
    var backgroundSecondary: Color { get set }
    var backgroundTertiary: Color { get set }
    var backgroundInverted: Color { get set }
    var textPrimary: Color { get set }
    var textSecondary: Color { get set }
    var textAccent: Color { get set }
    var textDisabled: Color { get set }
    var textNegative: Color { get set }
    var textInverted: Color { get set }
    var secondary: Color { get set }
    var secondaryFirstVariant: Color { get set }
    var secondarySecondVariant: Color { get set }
    var outlinePrimary: Color { get set }
    var outlineSecondary: Color { get set }
    var feedbackPositive: Color { get set }
    var feedbackNegative: Color { get set }
    var feedbackPositiveSecondary: Color { get set }
}

// MARK: - Spacing Definitions
public protocol MPSpacings: Sendable {
    // New tokens (Andes X)
    var none: CGFloat { get }
    var pico: CGFloat { get }
    var xnano: CGFloat { get }
    var nano: CGFloat { get }
    var xmicro: CGFloat { get }
    var micro: CGFloat { get }
    var xtiny: CGFloat { get }
    var tiny: CGFloat { get }
    var xsmall: CGFloat { get }
    var small: CGFloat { get }
    var medium: CGFloat { get }
    var large: CGFloat { get }
    var xlarge: CGFloat { get }
    var huge: CGFloat { get }
    
    // swiftlint:disable identifier_name
    // Legacy tokens
    var xxs: CGFloat { get set }
    var xs: CGFloat { get set }
    var s: CGFloat { get set }
    var m: CGFloat { get set }
    var l: CGFloat { get set }
    var xl: CGFloat { get set }
    var xxl: CGFloat { get set }
    // swiftlint:enable identifier_name
}

// MARK: - Border Radius Definitions
public protocol MPBorderRadius: Sendable {
    // New tokens (Andes X)
    var none: CGFloat { get }
    var tiny: CGFloat { get }
    var xsmall: CGFloat { get }
    var small: CGFloat { get }
    var medium: CGFloat { get }
    var large: CGFloat { get }
    var xlarge: CGFloat { get }
    var full: CGFloat { get }
    
    // swiftlint:disable identifier_name
    // Legacy tokens
    var xxs: CGFloat { get set }
    var xs: CGFloat { get set }
    var s: CGFloat { get set }
    // swiftlint:enable identifier_name
}

// MARK: - Border Width Definitions
public protocol MPBorderWidth: Sendable {
    var none: CGFloat { get }
    var small: CGFloat { get }
    var medium: CGFloat { get }
    var large: CGFloat { get }
    var xlarge: CGFloat { get }
}

// swiftlint:disable identifier_name
// MARK: - Outline Definitions (Legacy)
public protocol MPOutline: Sendable {
    var xxs: CGFloat { get set }
    var xs: CGFloat { get set }
}
// swiftlint:enable identifier_name

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

public struct MPTitleStyle: Sendable {
    public var smallSemibold: Font
}

public struct MPBodyStyle: Sendable {
    public var medium: MPFontStyle
    public var small: MPFontStyle
    public var extraSmallSemibold: Font
}

public protocol MPTypography: Sendable {
    var title: MPTitleStyle { get }
    var body: MPBodyStyle { get }
}
